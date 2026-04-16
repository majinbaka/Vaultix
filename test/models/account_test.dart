import 'package:flutter_test/flutter_test.dart';
import 'package:vaultix/features/password_manager/models/account.dart';

void main() {
  group('Account', () {
    final testAccount = Account(
      id: 'id-1',
      siteName: 'GitHub',
      username: 'user@example.com',
      password: 'secret123',
    );

    test('constructor sets all fields correctly', () {
      expect(testAccount.id, 'id-1');
      expect(testAccount.siteName, 'GitHub');
      expect(testAccount.username, 'user@example.com');
      expect(testAccount.password, 'secret123');
    });

    test('toMap returns correct map', () {
      final map = testAccount.toMap();
      expect(map['id'], 'id-1');
      expect(map['siteName'], 'GitHub');
      expect(map['username'], 'user@example.com');
      expect(map['password'], 'secret123');
    });

    test('fromMap creates account from map correctly', () {
      final map = {
        'id': 'id-2',
        'siteName': 'Google',
        'username': 'me@google.com',
        'password': 'p@ssw0rd',
      };
      final account = Account.fromMap(map);
      expect(account.id, 'id-2');
      expect(account.siteName, 'Google');
      expect(account.username, 'me@google.com');
      expect(account.password, 'p@ssw0rd');
    });

    test('toMap and fromMap are inverse operations', () {
      final map = testAccount.toMap();
      final restored = Account.fromMap(map);
      expect(restored.id, testAccount.id);
      expect(restored.siteName, testAccount.siteName);
      expect(restored.username, testAccount.username);
      expect(restored.password, testAccount.password);
    });

    test('fields are mutable', () {
      final account = Account(
        id: 'a',
        siteName: 'Old',
        username: 'old@user.com',
        password: 'oldpass',
      );
      account.id = 'b';
      account.siteName = 'New';
      account.username = 'new@user.com';
      account.password = 'newpass';
      expect(account.id, 'b');
      expect(account.siteName, 'New');
      expect(account.username, 'new@user.com');
      expect(account.password, 'newpass');
    });

    test('toMap contains exactly 4 keys', () {
      final map = testAccount.toMap();
      expect(map.keys.length, 4);
    });
  });
}
