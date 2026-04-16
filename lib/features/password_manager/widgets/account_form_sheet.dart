import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../models/account.dart';
import 'vault_text_form_field.dart';

/// Generates a 16-byte cryptographically random hex ID.
String _generateId() {
  final rng = Random.secure();
  return List.generate(16, (_) => rng.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}

/// The result returned by [AccountFormSheet.show].
///
/// - [account] is non-null when the user saved the form.
/// - [deleted] is true when the user tapped Delete on an existing account.
/// - Both are default (null / false) when the user cancelled.
class AccountFormResult {
  const AccountFormResult({this.account, this.deleted = false});

  final Account? account;
  final bool deleted;
}

/// Bottom sheet for creating or editing an [Account].
///
/// Use [AccountFormSheet.show] to display the sheet and await the result.
class AccountFormSheet extends StatefulWidget {
  const AccountFormSheet({super.key, this.initial});

  /// When non-null the sheet is in edit mode pre-populated with this account.
  final Account? initial;

  /// Shows the modal bottom sheet.
  ///
  /// Returns an [AccountFormResult] whose [AccountFormResult.account] is
  /// non-null on save, [AccountFormResult.deleted] is true on delete, or
  /// both default values on cancel.
  static Future<AccountFormResult?> show(
    BuildContext context, {
    Account? initial,
  }) {
    return showModalBottomSheet<AccountFormResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeProvider.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AccountFormSheet(initial: initial),
    );
  }

  @override
  State<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _siteCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _siteCtrl = TextEditingController(text: widget.initial?.siteName ?? '');
    _userCtrl = TextEditingController(text: widget.initial?.username ?? '');
    _passCtrl = TextEditingController(text: widget.initial?.password ?? '');
  }

  @override
  void dispose() {
    _siteCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final account = Account(
      id: widget.initial?.id ?? _generateId(),
      siteName: _siteCtrl.text.trim(),
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
    );
    Navigator.of(context).pop(AccountFormResult(account: account));
  }

  void _delete() {
    Navigator.of(context).pop(const AccountFormResult(deleted: true));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = AppThemeProvider.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null
                  ? l10n.pmAddAccount
                  : widget.initial!.siteName,
              style: AppTextStyles.bodyPrimary(
                palette,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            VaultTextFormField(
              controller: _siteCtrl,
              label: l10n.pmSiteName,
              prefixIcon: Icons.language,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            VaultTextFormField(
              controller: _userCtrl,
              label: l10n.pmUsername,
              prefixIcon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            VaultTextFormField(
              controller: _passCtrl,
              label: l10n.pmPassword,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: palette.secondary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) => (v == null || v.isEmpty) ? '' : null,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.initial != null) ...[
                  OutlinedButton.icon(
                    onPressed: _delete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: palette.accent,
                    ),
                    label: Text(
                      l10n.pmDelete,
                      style: AppTextStyles.bodyAccent(palette),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: palette.accent),
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null as AccountFormResult?),
                  child: Text(
                    l10n.pmCancel,
                    style: AppTextStyles.ui(color: palette.secondary),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                  ),
                  onPressed: _submit,
                  child: Text(l10n.pmSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
