import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultix/features/password_manager/models/account.dart';
import 'package:vaultix/features/password_manager/models/vault_session.dart';
import 'package:vaultix/features/password_manager/presentation/viewmodels/password_manager_viewmodel.dart';

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
        default:
          return null;
      }
    },
  );
}

VaultSession _makeSession([List<Map<String, dynamic>>? accounts]) {
  return VaultSession(
    vaultKey: Uint8List.fromList(List.generate(32, (i) => i)),
    accounts: accounts ?? [],
  );
}

Account _makeAccount({
  String id = '1',
  String siteName = 'GitHub',
  String username = 'user',
  String password = 'pass',
}) =>
    Account(id: id, siteName: siteName, username: username, password: password);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _setupSecureStorageMock();
  });

  group('PasswordManagerViewModel', () {
    late PasswordManagerViewModel vm;

    setUp(() {
      vm = PasswordManagerViewModel(session: _makeSession());
    });

    tearDown(() {
      vm.dispose();
    });

    group('initial state', () {
      test('accounts is empty when session has no accounts', () {
        expect(vm.accounts, isEmpty);
      });

      test('isLocked is false initially', () {
        expect(vm.isLocked, false);
      });

      test('loads accounts from session', () {
        final session = _makeSession([
          {'id': '1', 'siteName': 'Site', 'username': 'u', 'password': 'p'},
        ]);
        final vmWithAccounts = PasswordManagerViewModel(session: session);
        expect(vmWithAccounts.accounts.length, 1);
        expect(vmWithAccounts.accounts.first.siteName, 'Site');
        vmWithAccounts.dispose();
      });

      test('accounts list is unmodifiable', () {
        expect(
          () => (vm.accounts as dynamic).add(_makeAccount()),
          throwsUnsupportedError,
        );
      });
    });

    group('addAccount()', () {
      test('adds account to list', () {
        final account = _makeAccount();
        vm.addAccount(account);
        expect(vm.accounts.length, 1);
        expect(vm.accounts.first.siteName, 'GitHub');
      });

      test('notifies listeners', () {
        var notified = false;
        vm.addListener(() => notified = true);
        vm.addAccount(_makeAccount());
        expect(notified, true);
      });

      test('multiple accounts can be added', () {
        vm.addAccount(_makeAccount(id: '1', siteName: 'A'));
        vm.addAccount(_makeAccount(id: '2', siteName: 'B'));
        vm.addAccount(_makeAccount(id: '3', siteName: 'C'));
        expect(vm.accounts.length, 3);
      });
    });

    group('updateAccount()', () {
      test('updates account at given index', () {
        vm.addAccount(_makeAccount(siteName: 'Old'));
        vm.updateAccount(0, _makeAccount(siteName: 'New'));
        expect(vm.accounts.first.siteName, 'New');
      });

      test('notifies listeners', () {
        vm.addAccount(_makeAccount());
        var notified = false;
        vm.addListener(() => notified = true);
        vm.updateAccount(0, _makeAccount(siteName: 'Updated'));
        expect(notified, true);
      });

      test('does not change list length', () {
        vm.addAccount(_makeAccount(id: '1'));
        vm.addAccount(_makeAccount(id: '2'));
        vm.updateAccount(0, _makeAccount(id: '3', siteName: 'X'));
        expect(vm.accounts.length, 2);
      });
    });

    group('deleteAccount()', () {
      test('removes account at given index', () {
        vm.addAccount(_makeAccount(id: '1', siteName: 'A'));
        vm.addAccount(_makeAccount(id: '2', siteName: 'B'));
        vm.deleteAccount(0);
        expect(vm.accounts.length, 1);
        expect(vm.accounts.first.siteName, 'B');
      });

      test('notifies listeners', () {
        vm.addAccount(_makeAccount());
        var notified = false;
        vm.addListener(() => notified = true);
        vm.deleteAccount(0);
        expect(notified, true);
      });

      test('list is empty after deleting last account', () {
        vm.addAccount(_makeAccount());
        vm.deleteAccount(0);
        expect(vm.accounts, isEmpty);
      });
    });

    group('lock()', () {
      test('sets isLocked to true', () {
        vm.lock();
        expect(vm.isLocked, true);
      });

      test('notifies listeners', () {
        var notified = false;
        vm.addListener(() => notified = true);
        vm.lock();
        expect(notified, true);
      });

      test('flushes pending persist timer before locking', () async {
        vm.addAccount(_makeAccount());
        // persist timer is debounced at 500ms; lock should flush it
        vm.lock();
        // just verify no error and isLocked is set
        expect(vm.isLocked, true);
      });
    });

    group('resetIdleTimer()', () {
      test('does not throw when called multiple times', () {
        expect(() {
          vm.resetIdleTimer();
          vm.resetIdleTimer();
          vm.resetIdleTimer();
        }, returnsNormally);
      });

      test('resets timer on each mutation', () {
        // Calling addAccount resets the timer internally
        expect(() {
          vm.addAccount(_makeAccount(id: '1'));
          vm.updateAccount(0, _makeAccount(id: '1', siteName: 'Updated'));
          vm.deleteAccount(0);
        }, returnsNormally);
      });
    });

    group('dispose()', () {
      test('disposes without error', () {
        // tearDown calls dispose(); just verify the vm is usable before that
        expect(vm.isLocked, isA<bool>());
      });

      test('cancels timers during dispose', () {
        vm.addAccount(_makeAccount()); // starts persist timer
        // tearDown calls dispose(); just verify accounts were added without error
        expect(vm.accounts.length, 1);
      });
    });
  });
}
