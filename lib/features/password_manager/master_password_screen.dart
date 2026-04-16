import 'package:flutter/material.dart';

import '../../core/theme/app_styles.dart';
import '../../core/theme/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/viewmodels/master_password_viewmodel.dart';
import 'vault_service.dart';
import 'password_manager_screen.dart';
import 'widgets/vault_text_form_field.dart';

/// Shown before PasswordManagerScreen.
/// Handles both first-time vault creation and subsequent unlocks.
class MasterPasswordScreen extends StatefulWidget {
  const MasterPasswordScreen({super.key});

  @override
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _masterCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  // UI-only toggle states (not moved to viewmodel per spec)
  bool _obscureMaster = true;
  bool _obscureConfirm = true;

  late MasterPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MasterPasswordViewModel(
      onSuccess: _handleSuccess,
    );
    _viewModel.checkVault();
  }

  void _handleSuccess(VaultSession session) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PasswordManagerScreen(session: session),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final password = _masterCtrl.text;
    final confirm = _confirmCtrl.text.isEmpty ? null : _confirmCtrl.text;

    await _viewModel.submit(
      password,
      confirm,
      wrongPasswordMessage: l10n.pmMasterWrong,
      lockedMessage: l10n.pmLockedOut(
        _viewModel.lockoutRemaining.inSeconds.clamp(1, 9999),
      ),
    );

    // Clear password fields from memory after every submit attempt
    _masterCtrl.clear();
    _confirmCtrl.clear();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _confirmCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeProvider.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.surface,
          appBar: AppBar(
            backgroundColor: palette.primary,
            foregroundColor: palette.surface,
            elevation: 0,
            title: Text(
              l10n.pmMasterTitle,
              style: AppTextStyles.bodySurface(
                palette,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: _viewModel.loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 64,
                            color: palette.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _viewModel.vaultExists
                                ? l10n.pmMasterUnlockHeader
                                : l10n.pmMasterNewHeader,
                            style: AppTextStyles.bodyPrimary(
                              palette,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          if (!_viewModel.vaultExists)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                l10n.pmEncryptionInfo,
                                style: AppTextStyles.ui(
                                  color: palette.secondary,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 8),
                          VaultTextFormField(
                            controller: _masterCtrl,
                            label: l10n.pmMasterHint,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureMaster,
                            textInputAction: _viewModel.vaultExists
                                ? TextInputAction.done
                                : TextInputAction.next,
                            onFieldSubmitted: _viewModel.vaultExists
                                ? (_) => _submit()
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureMaster
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: palette.secondary,
                              ),
                              onPressed: () => setState(
                                () => _obscureMaster = !_obscureMaster,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return '';
                              if (!_viewModel.vaultExists && v.length < 8) {
                                return l10n.pmMasterTooShort;
                              }
                              return null;
                            },
                          ),
                          if (!_viewModel.vaultExists) ...[
                            const SizedBox(height: 12),
                            VaultTextFormField(
                              controller: _confirmCtrl,
                              label: l10n.pmMasterConfirmHint,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: palette.secondary,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return '';
                                if (v != _masterCtrl.text) {
                                  return l10n.pmMasterMismatch;
                                }
                                return null;
                              },
                            ),
                          ],
                          if (_viewModel.lockoutRemaining > Duration.zero) ...[
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.pmLockedOut(
                                _viewModel.lockoutRemaining.inSeconds,
                              ),
                              style: AppTextStyles.ui(color: palette.error),
                              textAlign: TextAlign.center,
                            ),
                          ] else if (_viewModel.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _viewModel.errorMessage!,
                              style: AppTextStyles.ui(color: palette.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          _viewModel.working
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : FilledButton(
                                  onPressed: _viewModel.lockoutRemaining > Duration.zero
                                      ? null
                                      : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: palette.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    _viewModel.vaultExists
                                        ? l10n.pmMasterUnlock
                                        : l10n.pmMasterCreate,
                                    style: AppTextStyles.ui(
                                      color: palette.surface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
