import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// App bar mark used on detail screens (matches product detail).
class AppBrandTitle extends StatelessWidget {
  const AppBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      AppConstants.appName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.crimsonText(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
