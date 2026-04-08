import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/main_toolbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final name = await _authService.getUserName();
    final email = await _authService.getUserEmail();
    
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
        _userEmail = email ?? 'usuario@ejemplo.com';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomAppBar(
      title: 'Mi Perfil',
      showDrawer: true,
      showBackButton: false,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildProfileAvatar(theme),
                    const SizedBox(height: 24),
                    _buildUserName(theme),
                    const SizedBox(height: 8),
                    _buildUserEmail(theme),
                    const SizedBox(height: 32),
                    _buildProfileOptions(theme, context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      child: Icon(Icons.person, size: 70, color: theme.colorScheme.primary),
    );
  }

  Widget _buildUserName(ThemeData theme) {
    return Text(
      _userName,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildUserEmail(ThemeData theme) {
    return Text(
      _userEmail,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  // Menú de opciones añadido para conectar con tus otras pantallas
  Widget _buildProfileOptions(ThemeData theme, BuildContext context) {
    final subtleIcon = theme.colorScheme.onSurface.withOpacity(0.4);
    final dividerColor = theme.colorScheme.onSurface.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.edit, color: theme.colorScheme.primary),
            title: const Text('Editar Perfil'),
            trailing: Icon(Icons.chevron_right, color: subtleIcon),
            onTap: () {
              // Navega a la pantalla de edición y refresca al volver
              // Asegúrate de que la ruta '/edit' sea correcta según tu enrutamiento
              Navigator.pushNamed(context, '/edit').then((_) => _refreshData());
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.primary),
            title: const Text('Configuración'),
            trailing: Icon(Icons.chevron_right, color: subtleIcon),
            onTap: () {
              // Asegúrate de que la ruta '/settings' coincida con tu main.dart
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Cerrar Sesión', 
              style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)
            ),
            onTap: () async {
              await _authService.logout();
              if (context.mounted) {
                // Vuelve a la pantalla de login (ajusta la ruta '/' si es distinta)
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
    );
  }
}