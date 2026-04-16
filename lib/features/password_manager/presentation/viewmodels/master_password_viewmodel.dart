import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../vault_service.dart';

class MasterPasswordViewModel extends ChangeNotifier {
  MasterPasswordViewModel({required this.onSuccess});

  /// Called with the new [VaultSession] after successful create or unlock.
  final void Function(VaultSession) onSuccess;

  bool vaultExists = false;
  bool loading = true;
  bool working = false;
  String? errorMessage;

  /// Remaining lockout duration (zero = not locked).
  Duration lockoutRemaining = Duration.zero;
  Timer? _lockoutTick;

  // ── Vault check ────────────────────────────────────────────────────────────

  Future<void> checkVault() async {
    loading = true;
    notifyListeners();
    vaultExists = await VaultService.hasVault();
    lockoutRemaining = await VaultService.getLockoutRemaining();
    _startLockoutTick();
    loading = false;
    notifyListeners();
  }

  // ── Lockout countdown ──────────────────────────────────────────────────────

  void _startLockoutTick() {
    _lockoutTick?.cancel();
    if (lockoutRemaining <= Duration.zero) return;
    _lockoutTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (lockoutRemaining.inSeconds <= 1) {
        lockoutRemaining = Duration.zero;
        _lockoutTick?.cancel();
      } else {
        lockoutRemaining -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> submit(
    String password,
    String? confirm, {
    required String wrongPasswordMessage,
    required String lockedMessage,
  }) async {
    if (lockoutRemaining > Duration.zero) return;

    working = true;
    errorMessage = null;
    notifyListeners();

    VaultSession? session;

    if (vaultExists) {
      session = await VaultService.unlockVault(password);
    } else {
      session = await VaultService.createVault(password);
    }

    if (session == null) {
      working = false;
      // Refresh lockout state after a failed attempt
      lockoutRemaining = await VaultService.getLockoutRemaining();
      errorMessage = lockoutRemaining > Duration.zero
          ? lockedMessage
          : wrongPasswordMessage;
      _startLockoutTick();
      notifyListeners();
      return;
    }

    working = false;
    notifyListeners();
    onSuccess(session);
  }

  @override
  void dispose() {
    _lockoutTick?.cancel();
    super.dispose();
  }
}
