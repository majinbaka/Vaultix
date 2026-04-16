import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaultix/features/password_manager/models/vault_session.dart';

void main() {
  group('VaultSession', () {
    final vaultKey = Uint8List.fromList(List.generate(32, (i) => i));
    final accounts = [
      {'id': '1', 'siteName': 'GitHub', 'username': 'user', 'password': 'pass'},
    ];

    test('constructor sets vaultKey and accounts', () {
      final session = VaultSession(vaultKey: vaultKey, accounts: accounts);
      expect(session.vaultKey, vaultKey);
      expect(session.accounts, accounts);
    });

    test('empty accounts list is valid', () {
      final session = VaultSession(vaultKey: vaultKey, accounts: const []);
      expect(session.accounts, isEmpty);
    });

    test('vaultKey is 32 bytes', () {
      final session = VaultSession(vaultKey: vaultKey, accounts: const []);
      expect(session.vaultKey.length, 32);
    });

    test('multiple accounts are preserved', () {
      final multiAccounts = [
        {'id': '1', 'siteName': 'Site1', 'username': 'u1', 'password': 'p1'},
        {'id': '2', 'siteName': 'Site2', 'username': 'u2', 'password': 'p2'},
      ];
      final session = VaultSession(vaultKey: vaultKey, accounts: multiAccounts);
      expect(session.accounts.length, 2);
      expect(session.accounts[0]['siteName'], 'Site1');
      expect(session.accounts[1]['siteName'], 'Site2');
    });

    test('const constructor works', () {
      final key = Uint8List(32);
      const emptyAccounts = <Map<String, dynamic>>[];
      final session = VaultSession(vaultKey: key, accounts: emptyAccounts);
      expect(session.vaultKey.length, 32);
    });
  });
}
