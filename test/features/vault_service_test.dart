import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultix/features/password_manager/vault_service.dart';

/// Minimal in-memory mock for flutter_secure_storage's method channel.
final _secureStore = <String, String>{};

void _setupSecureStorageMock() {
  _secureStore.clear();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      switch (call.method) {
        case 'read':
          final key = (call.arguments as Map)['key'] as String;
          return _secureStore[key];
        case 'write':
          final args = call.arguments as Map;
          _secureStore[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          final key = (call.arguments as Map)['key'] as String;
          _secureStore.remove(key);
          return null;
        case 'deleteAll':
          _secureStore.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(_secureStore);
        default:
          return null;
      }
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _setupSecureStorageMock();
  });

  group('VaultService', () {
    group('hasVault()', () {
      test('returns false when no vault exists', () async {
        expect(await VaultService.hasVault(), false);
      });

      test('returns true after createVault', () async {
        await VaultService.createVault('password123');
        expect(await VaultService.hasVault(), true);
      });
    });

    group('createVault()', () {
      test('returns VaultSession on success', () async {
        final session = await VaultService.createVault('mypassword');
        expect(session, isNotNull);
      });

      test('returns session with empty accounts list', () async {
        final session = await VaultService.createVault('mypassword');
        expect(session!.accounts, isEmpty);
      });

      test('returns session with 32-byte vault key', () async {
        final session = await VaultService.createVault('mypassword');
        expect(session!.vaultKey.length, 32);
      });

      test('returns null when vault already exists', () async {
        await VaultService.createVault('first');
        final second = await VaultService.createVault('second');
        expect(second, isNull);
      });
    });

    group('unlockVault()', () {
      test('returns VaultSession with correct password', () async {
        await VaultService.createVault('correct_password');
        final session = await VaultService.unlockVault('correct_password');
        expect(session, isNotNull);
      });

      test('returns null with wrong password', () async {
        await VaultService.createVault('correct_password');
        final session = await VaultService.unlockVault('wrong_password');
        expect(session, isNull);
      });

      test('returns null when no vault exists', () async {
        final session = await VaultService.unlockVault('anypassword');
        expect(session, isNull);
      });

      test('returned session has same vault key as created', () async {
        final created = await VaultService.createVault('testpass');
        final unlocked = await VaultService.unlockVault('testpass');
        expect(unlocked!.vaultKey, created!.vaultKey);
      });

      test('returns null when locked out', () async {
        await VaultService.createVault('correct');
        // Trigger 3 failures to activate lockout
        await VaultService.unlockVault('wrong1');
        await VaultService.unlockVault('wrong2');
        await VaultService.unlockVault('wrong3');
        // Now even correct password should be blocked
        final session = await VaultService.unlockVault('correct');
        expect(session, isNull);
      });

      test('clears failure count on successful unlock', () async {
        await VaultService.createVault('correct');
        await VaultService.unlockVault('bad');
        await VaultService.unlockVault('bad');
        // 2 failures, not yet locked
        final session = await VaultService.unlockVault('correct');
        expect(session, isNotNull);
        // After success, should be clear — further wrong attempts start fresh
        await VaultService.unlockVault('bad');
        final session2 = await VaultService.unlockVault('correct');
        expect(session2, isNotNull);
      });
    });

    group('getLockoutRemaining()', () {
      test('returns Duration.zero when not locked', () async {
        final remaining = await VaultService.getLockoutRemaining();
        expect(remaining, Duration.zero);
      });

      test('returns non-zero after enough failures', () async {
        await VaultService.createVault('correct');
        await VaultService.unlockVault('bad1');
        await VaultService.unlockVault('bad2');
        await VaultService.unlockVault('bad3'); // triggers lockout
        final remaining = await VaultService.getLockoutRemaining();
        expect(remaining, greaterThan(Duration.zero));
      });
    });

    group('saveAccounts()', () {
      test('saves and persists accounts without error', () async {
        final session = await VaultService.createVault('pass');
        final accounts = [
          {'id': '1', 'siteName': 'GitHub', 'username': 'u', 'password': 'p'},
        ];
        await expectLater(
          VaultService.saveAccounts(session!.vaultKey, accounts),
          completes,
        );
      });

      test('does nothing when no vault raw data exists', () async {
        // No vault created, raw is null — should return without error
        final session = await VaultService.createVault('pass');
        final vaultKey = session!.vaultKey;
        await VaultService.deleteVault();
        await expectLater(
          VaultService.saveAccounts(vaultKey, []),
          completes,
        );
      });

      test('saved accounts are recoverable on unlock', () async {
        final session = await VaultService.createVault('pass');
        final accounts = [
          {'id': '1', 'siteName': 'Site', 'username': 'user', 'password': 'pw'},
        ];
        await VaultService.saveAccounts(session!.vaultKey, accounts);

        final unlocked = await VaultService.unlockVault('pass');
        expect(unlocked!.accounts.length, 1);
        expect(unlocked.accounts.first['siteName'], 'Site');
      });
    });

    group('changeMasterPassword()', () {
      test('returns true on success', () async {
        final session = await VaultService.createVault('oldpass');
        final result = await VaultService.changeMasterPassword(session!, 'newpass');
        expect(result, true);
      });

      test('old password no longer works after change', () async {
        final session = await VaultService.createVault('oldpass');
        await VaultService.changeMasterPassword(session!, 'newpass');
        final unlocked = await VaultService.unlockVault('oldpass');
        expect(unlocked, isNull);
      });

      test('new password unlocks vault after change', () async {
        final session = await VaultService.createVault('oldpass');
        await VaultService.changeMasterPassword(session!, 'newpass');
        final unlocked = await VaultService.unlockVault('newpass');
        expect(unlocked, isNotNull);
      });

      test('returns false when no vault exists', () async {
        final fakeSession = VaultSession(
          vaultKey: Uint8List.fromList(List.generate(32, (i) => i)),
          accounts: [],
        );
        final result = await VaultService.changeMasterPassword(fakeSession, 'new');
        expect(result, false);
      });
    });

    group('deleteVault()', () {
      test('removes vault so hasVault returns false', () async {
        await VaultService.createVault('pass');
        await VaultService.deleteVault();
        expect(await VaultService.hasVault(), false);
      });

      test('completes without error when no vault exists', () async {
        await expectLater(VaultService.deleteVault(), completes);
      });
    });
  });
}
