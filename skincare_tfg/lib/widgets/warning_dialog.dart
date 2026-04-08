// warning_dialog.dart (adaptado)
import 'package:flutter/material.dart';

class WarningDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Continuar',
    String cancelText = 'Cancelar',
    bool isDanger = false,
  }) async {
    final theme = Theme.of(context);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              isDanger ? Icons.warning_amber : Icons.info_outline,
              color: isDanger ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger 
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              foregroundColor: isDanger
                  ? theme.colorScheme.onError
                  : theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    final theme = Theme.of(context);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}