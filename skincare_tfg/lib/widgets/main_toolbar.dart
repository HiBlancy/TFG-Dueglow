import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showDrawer;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showDrawer = true,
    this.showBackButton = false,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final _authService = AuthService();
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUserName();
    final email = await _authService.getUserEmail();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
        _userEmail = email ?? '';
      });
    }
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: widget.showBackButton 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
        actions: [
          ...?widget.actions,
          if (widget.showDrawer)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
      endDrawer: widget.showDrawer ? _buildDrawer(context) : null,
      body: widget.child,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(context, Icons.home, 'Inicio', AppConstants.routeHome),
                  _buildDrawerItem(context, Icons.person, 'Mi Perfil', AppConstants.routeProfile),
                  const Divider(),
                  _buildDrawerItem(context, Icons.settings, 'Configuración', AppConstants.routeSettings),
                  _buildDrawerItem(context, Icons.info, 'Acerca de', AppConstants.routeAbout),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    Icons.logout,
                    'Cerrar sesión',
                    null,
                    isLogout: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String? route, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : null),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : null)),
      onTap: isLogout
          ? () async {
              Navigator.pop(context); // Cerrar drawer
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
              }
            }
          : () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.pushNamed(context, route!);
            },
    );
  }
}