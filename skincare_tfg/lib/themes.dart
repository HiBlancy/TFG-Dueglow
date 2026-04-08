// themes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // ==================== TEMA CLARO ====================
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF420034),
      secondary: Color(0xFF920069),
      tertiary: Color(0xFFEC9ED6),
      surface: Color(0xFFFFFFFF),         // Blanco para tarjetas
      error: Color(0xFFD32F2F),           // Rojo para errores
      onPrimary: Colors.white,            // Texto sobre primary
      onSecondary: Colors.white,          // Texto sobre secondary
      onSurface: Color(0xFF1A1A1A),       // Texto sobre surface
      onError: Colors.white,              // Texto sobre error
    ),
    
    // Tipografías para tema claro
    textTheme: TextTheme(
      // Títulos grandes (Display)
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      
      // Títulos de sección (Headline)
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF420034),
      ),
      
      // Títulos (Title)
      titleLarge: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF420034),
      ),
 
      // Textos de cuerpo (Body)
      // bodyLarge: GoogleFonts.roboto(
      //   fontSize: 16,
      //   fontWeight: FontWeight.normal,
      //   color: const Color(0xFF2C2C2C),
      //   height: 1.5,
      // ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF666666),
        height: 1.4,
      ),
      
      // Textos de etiquetas (Label)
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1976D2),
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF999999),
      ),
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF420034),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1976D2),
        side: const BorderSide(color: Color(0xFF1976D2)),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1976D2),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Cards
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      margin: const EdgeInsets.all(8),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF920069), width: 2), // Usamos tu secondary
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
    ),
    
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );
  
  // ==================== TEMA OSCURO ====================
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    
    colorScheme: const ColorScheme.dark(
      // INVERTIMOS LA PALETA: El color claro ahora es el primario para resaltar
      primary: Color(0xFFEC9ED6),         // Rosa claro (tu antiguo tertiary)
      secondary: Color(0xFFD05C9F),       // Un magenta un poco más claro y desaturado
      tertiary: Color(0xFF420034),        // El ciruela oscuro pasa a ser terciario
      
      // Fondos con un levísimo tono ciruela en lugar de negro puro
      surface: Color(0xFF261D24),         // Gris muy oscuro con tinte rosa/ciruela para tarjetas
      error: Color(0xFFEF5350),           
      onPrimary: Color(0xFF420034),       // Texto oscuro sobre el botón rosa claro
      onSecondary: Colors.white,     
      onSurface: Color(0xFFEAEAEA),       // Texto sobre surface
      onError: Color(0xFF121212),        // Texto sobre error
    ),
    
    // Tipografías para tema oscuro
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white54,
        height: 1.4,
      ),
      
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF90CAF9),
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white54,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.white38,
      ),
    ),
    
   // AppBar oscura
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1A1318), // Fondo oscuro
      foregroundColor: Color(0xFFEC9ED6), // Color base
      iconTheme: IconThemeData(color: Color(0xFFEAEAEA)),      
      actionsIconTheme: IconThemeData(color: Color(0xFFEAEAEA)),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEAEAEA),
        fontFamily: 'Montserrat',
      ),
    ),
    
    // Botones oscuros
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEC9ED6), // Botones principales en rosa
        foregroundColor: const Color(0xFF420034), // Texto del botón en ciruela oscuro
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFEC9ED6), // Rosa claro
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF90CAF9),
        side: const BorderSide(color: Color(0xFF90CAF9)),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Cards oscuras
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF261D24),
      margin: const EdgeInsets.all(8),
    ),
    
    // Inputs oscuros
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF332730), // Fondo del input un poco más claro que el surface
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A3A46)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A3A46)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEC9ED6), width: 2), // Borde rosa al enfocar
      ),
    ),
    
    // Scaffold oscuro (Ligeramente cálido/ciruela)
    scaffoldBackgroundColor: const Color(0xFF1A1318),
    
    // Diálogos oscuros
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF261D24),
    ),
  );
}