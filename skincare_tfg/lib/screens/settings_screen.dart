// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/main_toolbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Configuración',
      showDrawer: true,
      showBackButton: true,
      child: ListView(
        children: [
          // ===== NOTIFICACIONES =====
          const _SettingsSection(title: 'General', children: [
            _NotificationTile(),
          ]),
          
          const Divider(),
          
          // ===== TEMAS =====
          const _SettingsSection(title: 'Apariencia', children: [
            _ThemeTile(),
          ]),
          
          const Divider(),
          
          // ===== IDIOMAS =====
          const _SettingsSection(title: 'Idioma', children: [
            _LanguageTile(),
          ]),
          
          const Divider(),
          
          // ===== ACERCA DE =====
          const _SettingsSection(title: 'Información', children: [
            _AboutTile(),
          ]),
        ],
      ),
    );
  }
}

// Widget para notificaciones
class _NotificationTile extends StatefulWidget {
  const _NotificationTile();

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: const Text('Notificaciones'),
      subtitle: const Text('Recibir alertas y actualizaciones'),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (bool value) {
          setState(() {
            _notificationsEnabled = value;
          });
          // Aquí iría la lógica para guardar preferencia de notificaciones
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value 
                ? 'Notificaciones activadas' 
                : 'Notificaciones desactivadas'
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}

// Widget para cambiar el tema
class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        // Opción Claro
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: const Text('Modo Claro'),
          trailing: themeProvider.themeMode == ThemeMode.light
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () => themeProvider.setLightMode(),
        ),
        
        // Opción Oscuro
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Modo Oscuro'),
          trailing: themeProvider.themeMode == ThemeMode.dark
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () => themeProvider.setDarkMode(),
        ),
      ],
    );
  }
}

// Widget para cambiar el idioma
class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;
    
    return Column(
      children: [
        // Español
        ListTile(
          leading: const Icon(Icons.translate),
          title: const Text('Español'),
          subtitle: const Text('Spanish'),
          trailing: currentLocale == 'es'
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () {
            localeProvider.setSpanish();
            _showRestartSnackbar(context);
          },
        ),
        
        // Inglés
        ListTile(
          leading: const Icon(Icons.translate),
          title: const Text('English'),
          subtitle: const Text('Inglés'),
          trailing: currentLocale == 'en'
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () {
            localeProvider.setEnglish();
            _showRestartSnackbar(context);
          },
        ),
      ],
    );
  }
  
  void _showRestartSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Idioma cambiado. Reinicia la app para ver los cambios completos.'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Widget para Acerca de
class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('Acerca de'),
      subtitle: const Text('Versión 1.0.0'),
      onTap: () {
        // Navegar a la pantalla de About
        Navigator.pushNamed(context, '/about');
      },
    );
  }
}

// Sección con título
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}