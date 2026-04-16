import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/vault_session.dart';
export 'models/vault_session.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// Vault format v3  (SharedPreferences key "fstudy_vault")
///
/// {
///   "version"     : 3,
///   "salt"        : `"<base64 32 bytes>"`,  ← Argon2id salt (public)
///   "wrapped_key" : `"<base64>"`,           ← AES-256-GCM(KEK, vaultKey)
///                                           nonce(12) | vaultKey(32) | mac(16)
///   "box"         : `"<base64>"`            ← AES-256-GCM(vaultKey, JSON accounts)
///                                           nonce(12) | ciphertext | mac(16)
/// }
///
/// Security layers
/// ───────────────
/// 1. Random 32-byte VAULT KEY  – the key that actually encrypts your data.
///    • Stored as-is in the OS secure keystore via flutter_secure_storage
///      (Android Keystore System / iOS Keychain + Secure Enclave).
///    • Also stored encrypted (wrapped) in SharedPreferences as a recovery
///      path in case the secure storage entry is lost.
///
/// 2. KEY ENCRYPTION KEY (KEK)  – Argon2id(masterPassword, salt)
///    • Only used to wrap / unwrap the vault key.
///    • Never used to touch the vault data directly.
  /// Memory: 128 MiB | iterations: 3 | parallelism: 1
///
/// 3. AES-256-GCM  – authenticated encryption for both the wrapped key and
///    the vault data, with a fresh random nonce on every write.
///
/// Threat model improvements over v2
/// ──────────────────────────────────
/// • Vault key is hardware-protected: even a root/RAM dump cannot extract it
///   directly (Android Keystore, Secure Enclave).
/// • Key rotation is O(1): only re-wrap the vault key, never re-encrypt data.
/// • saveAccounts() runs in O(encrypt) time — no Argon2id on every save.
/// • Nonce reuse is impossible (Random.secure() + 96-bit nonce space).
///
/// Note: on Web, flutter_secure_storage uses localStorage (not hardware-
/// backed). Security on Web degrades to Argon2id-only protection (same as v2).
/// ══════════════════════════════════════════════════════════════════════════

class VaultService {
  VaultService._();

  // ── constants ─────────────────────────────────────────────────────────────

  static const _prefKey = 'fstudy_vault';
  static const _secureKey = 'fstudy_vault_key';
  static const _version = 3;

  // Brute-force protection keys (stored in secure storage)
  static const _failCountKey = 'fstudy_vault_fail_count';
  static const _lockUntilKey = 'fstudy_vault_lock_until';

  // Max consecutive failures before lockout; each failure doubles the delay
  // starting at 5 s → 10 s → 20 s → … → capped at 1 h.
  static const _maxFailsBeforeLock = 3;
  static const _baseLockSeconds = 5;
  static const _maxLockSeconds = 3600;

  // ── crypto primitives ─────────────────────────────────────────────────────

  // On Web (WASM/JS), 128 MiB Argon2id is impractically slow due to
  // single-threaded JS execution. Use lighter params on Web while keeping
  // strong params on native (where the OS keystore adds a hardware layer).
  static final _argon2 = kIsWeb
      ? Argon2id(
          memory: 16384, // 16 MiB — usable on Web
          parallelism: 1,
          iterations: 2,
          hashLength: 32,
        )
      : Argon2id(
          memory: 131072, // 128 MiB — OWASP minimum for high-value secrets
          parallelism: 1,
          iterations: 3,
          hashLength: 32,
        );

  static final _aesGcm = AesGcm.with256bits();

  // ── Brute-force helpers ───────────────────────────────────────────────────

  /// Returns the remaining lockout duration, or [Duration.zero] if not locked.
  static Future<Duration> getLockoutRemaining() async {
    final raw = await _secure.read(key: _lockUntilKey);
    if (raw == null) return Duration.zero;
    final until = DateTime.tryParse(raw);
    if (until == null) return Duration.zero;
    final remaining = until.difference(DateTime.now());
    return remaining > Duration.zero ? remaining : Duration.zero;
  }

  static Future<int> _readFailCount() async {
    final raw = await _secure.read(key: _failCountKey);
    return int.tryParse(raw ?? '0') ?? 0;
  }

  static Future<void> _recordFailure() async {
    final count = await _readFailCount() + 1;
    await _secure.write(key: _failCountKey, value: count.toString());

    if (count >= _maxFailsBeforeLock) {
      // Exponential backoff: baseLockSeconds * 2^(extra failures)
      final extra = count - _maxFailsBeforeLock;
      final seconds = (_baseLockSeconds * (1 << extra)).clamp(0, _maxLockSeconds);
      final until = DateTime.now().add(Duration(seconds: seconds));
      await _secure.write(key: _lockUntilKey, value: until.toIso8601String());
    }
  }

  static Future<void> _clearFailures() async {
    await Future.wait([
      _secure.delete(key: _failCountKey),
      _secure.delete(key: _lockUntilKey),
    ]);
  }

  // ── OS secure keystore ────────────────────────────────────────────────────

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── shared-prefs helpers ──────────────────────────────────────────────────

  static Future<String?> _readRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  static Future<void> _writeRaw(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value);
  }

  static Future<bool> hasVault() async => (await _readRaw()) != null;

  // ── key derivation (Argon2id) ─────────────────────────────────────────────

  static Future<Uint8List> _deriveKek(
      String password, Uint8List salt) async {
    final sk = await _argon2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return Uint8List.fromList(await sk.extractBytes());
  }

  // ── AES-256-GCM helpers ────────────────────────────────────────────────────

  static Future<Uint8List> _gcmEncrypt(
      Uint8List key, List<int> plaintext) async {
    final sk = SecretKey(key);
    final box = await _aesGcm.encrypt(
      plaintext,
      secretKey: sk,
      nonce: _aesGcm.newNonce(), // Random.secure() 12 bytes
    );
    return Uint8List.fromList(box.concatenation());
  }

  static Future<Uint8List?> _gcmDecrypt(
      Uint8List key, Uint8List combined) async {
    if (combined.length < 28) return null; // 12 nonce + 0 data + 16 mac minimum
    final nonce = combined.sublist(0, 12);
    final mac = combined.sublist(combined.length - 16);
    final cipherText = combined.sublist(12, combined.length - 16);
    try {
      final plaintext = await _aesGcm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: SecretKey(key),
      );
      return Uint8List.fromList(plaintext);
    } on SecretBoxAuthenticationError {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── random bytes ──────────────────────────────────────────────────────────

  static Uint8List _randomBytes(int n) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(n, (_) => rng.nextInt(256)));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Public API
  // ══════════════════════════════════════════════════════════════════════════

  /// Create a brand-new vault protected by [masterPassword].
  /// Returns a [VaultSession] on success, or `null` if a vault already exists.
  static Future<VaultSession?> createVault(String masterPassword) async {
    if (await hasVault()) return null;

    // 1. Generate random vault key (the data encryption key).
    final vaultKey = _randomBytes(32);

    // 2. Derive KEK from master password.
    final salt = _randomBytes(32);
    final kek = await _deriveKek(masterPassword, salt);

    // 3. Wrap (encrypt) vault key with KEK.
    final wrappedKey = await _gcmEncrypt(kek, vaultKey);

    // 4. Encrypt empty account list with vault key.
    final box = await _gcmEncrypt(vaultKey, utf8.encode(jsonEncode([])));

    // 5. Persist to SharedPreferences.
    await _writeRaw(jsonEncode({
      'version': _version,
      'salt': base64.encode(salt),
      'wrapped_key': base64.encode(wrappedKey),
      'box': base64.encode(box),
    }));

    // 6. Store raw vault key in OS secure keystore.
    await _secure.write(key: _secureKey, value: base64.encode(vaultKey));

    return VaultSession(vaultKey: vaultKey, accounts: const []);
  }

  /// Unlock the vault with [masterPassword].
  ///
  /// The master password is ALWAYS verified through Argon2id + KEK unwrap —
  /// the MAC on wrapped_key cannot be forged without the correct password.
  /// After successful unwrap the vault key is cached in the OS secure keystore
  /// for at-rest device-binding (future biometric gate, app reinstall guard).
  ///
  /// Returns `null` if the password is wrong or the vault format is incompatible.
  static Future<VaultSession?> unlockVault(String masterPassword) async {
    // ── Brute-force gate ──────────────────────────────────────────────────
    final lockout = await getLockoutRemaining();
    if (lockout > Duration.zero) return null;

    final rawStr = await _readRaw();
    if (rawStr == null) return null;

    final raw = jsonDecode(rawStr) as Map<String, dynamic>;
    if ((raw['version'] as int?) != _version) return null;

    final salt = base64.decode(raw['salt'] as String);
    final wrappedKeyBytes = base64.decode(raw['wrapped_key'] as String);
    final boxBytes = base64.decode(raw['box'] as String);

    // ── Step 1: Always verify password via Argon2id + KEK ─────────────────
    // The GCM MAC on wrapped_key proves knowledge of the correct password.
    // Skipping this step (fast path) would allow any entry when the keystore
    // already holds a key — that is a password-bypass vulnerability.
    final kek = await _deriveKek(masterPassword, salt);
    final vaultKey = await _gcmDecrypt(kek, wrappedKeyBytes);
    if (vaultKey == null) {
      await _recordFailure();
      return null; // wrong password
    }

    // ── Step 2: Decrypt vault data with the vault key ─────────────────────
    final plaintext = await _gcmDecrypt(vaultKey, boxBytes);
    if (plaintext == null) return null; // corrupted box (should not happen)

    // ── Step 3: Clear failure counter on successful unlock ─────────────────
    await _clearFailures();

    // ── Step 4: Refresh the OS keystore entry (at-rest device binding) ────
    await _secure.write(key: _secureKey, value: base64.encode(vaultKey));

    final accounts = (jsonDecode(utf8.decode(plaintext)) as List)
        .cast<Map<String, dynamic>>();

    return VaultSession(vaultKey: vaultKey, accounts: accounts);
  }

  /// Re-encrypt and persist [accounts] using the pre-derived [vaultKey]
  /// from a [VaultSession].  Argon2id is NOT needed here.
  static Future<void> saveAccounts(
      Uint8List vaultKey, List<Map<String, dynamic>> accounts) async {
    final rawStr = await _readRaw();
    if (rawStr == null) return;

    final raw = jsonDecode(rawStr) as Map<String, dynamic>;
    if ((raw['version'] as int?) != _version) return;

    // Fresh nonce on every write — GCM nonces must never be reused.
    raw['box'] = base64.encode(
      await _gcmEncrypt(vaultKey, utf8.encode(jsonEncode(accounts))),
    );
    await _writeRaw(jsonEncode(raw));
  }

  /// Change the master password without touching the vault data.
  /// Re-wraps the vault key with a new Argon2id-derived KEK and a new salt.
  static Future<bool> changeMasterPassword(
      VaultSession session, String newPassword) async {
    final rawStr = await _readRaw();
    if (rawStr == null) return false;

    final raw = jsonDecode(rawStr) as Map<String, dynamic>;
    if ((raw['version'] as int?) != _version) return false;

    final newSalt = _randomBytes(32);
    final newKek = await _deriveKek(newPassword, newSalt);
    final newWrappedKey = await _gcmEncrypt(newKek, session.vaultKey);

    raw['salt'] = base64.encode(newSalt);
    raw['wrapped_key'] = base64.encode(newWrappedKey);
    await _writeRaw(jsonEncode(raw));
    return true;
  }

  /// Delete the vault from both SharedPreferences and the OS secure keystore.
  static Future<void> deleteVault() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_prefKey),
      _secure.delete(key: _secureKey),
    ]);
  }
}
