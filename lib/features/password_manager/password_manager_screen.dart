import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_styles.dart';
import '../../core/theme/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import 'master_password_screen.dart';
import 'presentation/viewmodels/password_manager_viewmodel.dart';
import 'vault_service.dart';
import 'widgets/account_form_sheet.dart';

class PasswordManagerScreen extends StatefulWidget {
  final VaultSession session;

  const PasswordManagerScreen({super.key, required this.session});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen>
    with WidgetsBindingObserver {
  late PasswordManagerViewModel _viewModel;
  Timer? _clipboardClearTimer;

  static const _clipboardClearDelay = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _viewModel = PasswordManagerViewModel(session: widget.session);
    _viewModel.addListener(_onViewModelChange);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lock immediately when app is hidden or suspended
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _viewModel.lock();
    }
  }

  void _onViewModelChange() {
    if (_viewModel.isLocked && mounted) {
      _navigateToMasterPassword();
    } else if (mounted) {
      setState(() {});
    }
  }

  void _navigateToMasterPassword() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MasterPasswordScreen()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardClearTimer?.cancel();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    // Auto-clear clipboard after 30 seconds
    _clipboardClearTimer?.cancel();
    _clipboardClearTimer = Timer(_clipboardClearDelay, () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  Future<void> _openForm({int? editIndex}) async {
    final initial =
        editIndex != null ? _viewModel.accounts[editIndex] : null;
    final result = await AccountFormSheet.show(context, initial: initial);
    if (result == null) return;

    if (result.deleted && editIndex != null) {
      _viewModel.deleteAccount(editIndex);
    } else if (result.account != null) {
      if (editIndex == null) {
        _viewModel.addAccount(result.account!);
      } else {
        // Preserve the same id
        final updated = result.account!;
        _viewModel.updateAccount(editIndex, updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeProvider.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final accounts = _viewModel.accounts;

        return Scaffold(
          backgroundColor: palette.surface,
          appBar: AppBar(
            backgroundColor: palette.primary,
            foregroundColor: palette.surface,
            elevation: 0,
            title: Text(
              l10n.pmTitle,
              style: AppTextStyles.bodySurface(
                palette,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: palette.primary,
            foregroundColor: palette.surface,
            onPressed: () => _openForm(),
            child: const Icon(Icons.add),
          ),
          body: Listener(
            onPointerDown: (_) => _viewModel.resetIdleTimer(),
            child: accounts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_open_outlined,
                          size: 64,
                          color: palette.secondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.pmEmptyHint,
                          style: AppTextStyles.ui(color: palette.secondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final acc = accounts[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: palette.secondary,
                          foregroundColor: palette.surface,
                          child: Text(
                            acc.siteName.isNotEmpty
                                ? acc.siteName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          acc.siteName,
                          style: AppTextStyles.bodyPrimary(
                            palette,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          acc.username,
                          style: AppTextStyles.ui(
                            color: palette.secondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                _copyPassword(acc.password);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.copiedToClipboard,
                                      style: AppTextStyles.ui(
                                        color: palette.surface,
                                      ),
                                    ),
                                    backgroundColor: palette.primary,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.copy,
                                color: palette.secondary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _openForm(editIndex: i),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: palette.secondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
