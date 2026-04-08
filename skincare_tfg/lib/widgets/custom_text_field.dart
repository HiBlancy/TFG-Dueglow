// custom_text_field.dart (adaptado)
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleVisibility;
  final bool showVisibilityToggle;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onToggleVisibility,
    this.showVisibilityToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: theme.textTheme.bodyMedium, // ✅ Usar tipografía del tema
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: isDarkMode ? Colors.grey[600] : Colors.grey[600],
        ),
        hintText: hint,
        hintStyle: theme.textTheme.bodySmall?.copyWith( //color del hint texto al pulsarlo
          color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        suffixIcon: showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.secondary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDarkMode  //color del fondo del forumario
            ? theme.colorScheme.surface.withOpacity(0.6)
            : Colors.white,
      ),
    );
  }
}