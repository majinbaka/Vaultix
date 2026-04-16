import 'dart:typed_data';

/// Holds the vault key in memory during an unlocked session.
/// Injected into [PasswordManagerScreen] so that [saveAccounts] never needs
/// to re-derive the heavy Argon2id key.
class VaultSession {
  /// Raw 32-byte AES-256 vault key.
  final Uint8List vaultKey;

  /// Decrypted account list at the time of unlock.
  final List<Map<String, dynamic>> accounts;

  const VaultSession({required this.vaultKey, required this.accounts});
}
