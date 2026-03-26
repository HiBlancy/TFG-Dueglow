// screens/settings_screen.dart
import 'package:flutter/material.dart';
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
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Tema oscuro'),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Idioma'),
            trailing: Text('Español'),
          ),
        ],
      ),
    );
  }
}