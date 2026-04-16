import 'package:flutter/material.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/theme_controller.dart';

class VaultTextFormField extends StatelessWidget {
  const VaultTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeProvider.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.bodyPrimary(palette),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.ui(color: palette.secondary),
        prefixIcon: Icon(prefixIcon, color: palette.accent),
        suffixIcon: suffixIcon,
        border: AppFieldStyles.border(
          color: palette.secondary.withValues(alpha: 0.5),
        ),
        enabledBorder: AppFieldStyles.border(
          color: palette.secondary.withValues(alpha: 0.5),
        ),
        focusedBorder: AppFieldStyles.border(
          color: palette.primary,
          width: 1.5,
        ),
        errorBorder: AppFieldStyles.border(color: palette.error),
        focusedErrorBorder: AppFieldStyles.border(
          color: palette.error,
          width: 1.5,
        ),
      ),
      validator: validator,
    );
  }
}
