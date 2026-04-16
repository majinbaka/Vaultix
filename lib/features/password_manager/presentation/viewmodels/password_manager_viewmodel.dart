import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/account.dart';
import '../../vault_service.dart';

class PasswordManagerViewModel extends ChangeNotifier {
  PasswordManagerViewModel({required VaultSession session})
      : _session = session {
    _accounts = session.accounts.map(Account.fromMap).toList();
    resetIdleTimer();
  }

  final VaultSession _session;
  late List<Account> _accounts;
  bool _isLocked = false;

  static const _lockTimeout = Duration(minutes: 5);
  static const _persistDebounce = Duration(milliseconds: 500);
  Timer? _idleTimer;
  Timer? _persistTimer;

  List<Account> get accounts => List.unmodifiable(_accounts);

  bool get isLocked => _isLocked;

  // ── Idle timer ─────────────────────────────────────────────────────────────

  void resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_lockTimeout, lock);
  }

  void lock() {
    // Flush any pending write before locking
    if (_persistTimer?.isActive == true) {
      _persistTimer!.cancel();
      VaultService.saveAccounts(
        _session.vaultKey,
        _accounts.map((a) => a.toMap()).toList(),
      );
    }
    _isLocked = true;
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  void persist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(_persistDebounce, () {
      VaultService.saveAccounts(
        _session.vaultKey,
        _accounts.map((a) => a.toMap()).toList(),
      );
    });
  }

  // ── Mutation methods ───────────────────────────────────────────────────────

  void addAccount(Account a) {
    _accounts.add(a);
    resetIdleTimer();
    notifyListeners();
    persist();
  }

  void updateAccount(int index, Account a) {
    _accounts[index] = a;
    resetIdleTimer();
    notifyListeners();
    persist();
  }

  void deleteAccount(int index) {
    _accounts.removeAt(index);
    resetIdleTimer();
    notifyListeners();
    persist();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _persistTimer?.cancel();
    super.dispose();
  }
}
