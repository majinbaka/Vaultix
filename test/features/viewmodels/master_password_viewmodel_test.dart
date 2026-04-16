import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultix/features/password_manager/presentation/viewmodels/master_password_viewmodel.dart';
import 'package:vaultix/features/password_manager/vault_service.dart';

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

  group('MasterPasswordViewModel', () {
    late VaultSession? capturedSession;
    late MasterPasswordViewModel vm;

    setUp(() {
      capturedSession = null;
      vm = MasterPasswordViewModel(onSuccess: (s) => capturedSession = s);
    });

    tearDown(() {
      vm.dispose();
    });

    test('initial state: loading=true, working=false, vaultExists=false', () {
      expect(vm.loading, true);
      expect(vm.working, false);
      expect(vm.vaultExists, false);
      expect(vm.errorMessage, isNull);
      expect(vm.lockoutRemaining, Duration.zero);
    });

    group('checkVault()', () {
      test('sets loading=false after completion', () async {
        await vm.checkVault();
        expect(vm.loading, false);
      });

      test('sets vaultExists=false when no vault', () async {
        await vm.checkVault();
        expect(vm.vaultExists, false);
      });

      test('sets vaultExists=true when vault exists', () async {
        await VaultService.createVault('pass');
        await vm.checkVault();
        expect(vm.vaultExists, true);
      });

      test('notifies listeners during check', () async {
        var count = 0;
        vm.addListener(() => count++);
        await vm.checkVault();
        expect(count, greaterThanOrEqualTo(2)); // loading=true, then false
      });
    });

    group('submit() - create vault', () {
      setUp(() async {
        await vm.checkVault(); // vaultExists = false
      });

      test('creates vault and calls onSuccess', () async {
        await vm.submit('password123', 'password123',
            wrongPasswordMessage: 'wrong', lockedMessage: 'locked');
        expect(capturedSession, isNotNull);
      });

      test('working is false after success', () async {
        await vm.submit('password123', null,
            wrongPasswordMessage: 'wrong', lockedMessage: 'locked');
        expect(vm.working, false);
      });

      test('errorMessage is null after success', () async {
        await vm.submit('password123', null,
            wrongPasswordMessage: 'wrong', lockedMessage: 'locked');
        expect(vm.errorMessage, isNull);
      });
    });

    group('submit() - unlock vault', () {
      setUp(() async {
        await VaultService.createVault('correct');
        await vm.checkVault(); // vaultExists = true
      });

      test('unlocks successfully with correct password', () async {
        await vm.submit('correct', null,
            wrongPasswordMessage: 'wrong', lockedMessage: 'locked');
        expect(capturedSession, isNotNull);
      });

      test('sets error message on wrong password', () async {
        await vm.submit('wrong', null,
            wrongPasswordMessage: 'Wrong password', lockedMessage: 'locked');
        expect(vm.errorMessage, 'Wrong password');
        expect(capturedSession, isNull);
      });

      test('working=false after failed attempt', () async {
        await vm.submit('wrong', null,
            wrongPasswordMessage: 'err', lockedMessage: 'locked');
        expect(vm.working, false);
      });

      test('shows locked message when locked out', () async {
        // First 2 failures show wrong password message
        await vm.submit('bad', null, wrongPasswordMessage: 'w', lockedMessage: 'Locked');
        await vm.submit('bad', null, wrongPasswordMessage: 'w', lockedMessage: 'Locked');
        // 3rd failure triggers lockout — errorMessage becomes the lockedMessage
        await vm.submit('bad', null,
            wrongPasswordMessage: 'wrong', lockedMessage: 'Account locked');
        expect(vm.errorMessage, 'Account locked');
        expect(vm.lockoutRemaining, greaterThan(Duration.zero));
      });
    });

    group('submit() - lockout guard', () {
      test('submit does nothing when lockoutRemaining > zero', () async {
        await VaultService.createVault('pass');
        // Manually set lockoutRemaining via checkVault after 3 failures
        for (var i = 0; i < 3; i++) {
          await VaultService.unlockVault('wrong$i');
        }
        await vm.checkVault(); // picks up lockout
        expect(vm.lockoutRemaining, greaterThan(Duration.zero));
        // submit should return early
        await vm.submit('pass', null,
            wrongPasswordMessage: 'w', lockedMessage: 'l');
        expect(capturedSession, isNull);
      });
    });

    group('dispose()', () {
      test('disposes without error', () {
        // dispose() is called by tearDown; just verify the vm is usable before that
        expect(vm.loading, isA<bool>());
      });
    });
  });
}
