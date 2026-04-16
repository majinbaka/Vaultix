/// A single saved account entry in the password vault.
class Account {
  String id;
  String siteName;
  String username;
  String password;

  Account({
    required this.id,
    required this.siteName,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'siteName': siteName,
    'username': username,
    'password': password,
  };

  factory Account.fromMap(Map<String, dynamic> m) => Account(
    id: m['id'] as String,
    siteName: m['siteName'] as String,
    username: m['username'] as String,
    password: m['password'] as String,
  );
}
