import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/beauty_product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../widgets/main_toolbar.dart';
import 'product_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final ProductService _productService = ProductService();

  String _userName = '';
  bool _isLoading = true;
  List<BeautyProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final name = await _authService.getUserName();
    final products = await _productService.getProducts();

    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
        _products = products;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  Future<void> _navigateToProduct(BeautyProduct product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductScreen(product: product, isFromSearch: false),
      ),
    );
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAppBar(
      title: 'DueGlow',
      showDrawer: true,
      showBackButton: false,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // --- CABECERA CENTRADA ---
                    Center(
                      child: Column(
                        children: [
                          Text(
                            l10n.helloUser(_userName),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontFamily: 'Sora',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tu rutina personalizada te espera',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // --- ACCIONES RÁPIDAS (Opacidades suaves) ---
                    _buildQuickActions(theme, l10n),
                    
                    const SizedBox(height: 32),
                    
                    // --- SECCIÓN DE CADUCIDAD ---
                    _buildExpiringSoonProducts(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, AppLocalizations l10n) {
    // Usamos el mismo tono primaryContainer pero variando la intensidad
    final colorPrincipal = theme.colorScheme.primaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  Icons.shopping_bag_outlined,
                  l10n.myProducts,
                  l10n.seeAll,
                  colorPrincipal.withValues(alpha: 0.4), 
                  () => Navigator.pushNamed(context, AppConstants.routeMyProducts),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  Icons.face_retouching_natural_outlined,
                  l10n.routines,
                  'Próximamente',
                  colorPrincipal.withValues(alpha: 0.2), 
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  Icons.category_outlined,
                  l10n.categories,
                  'Próximamente',
                  colorPrincipal.withValues(alpha: 0.2), 
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  Icons.history,
                  'Usados',
                  'Próximamente',
                  colorPrincipal.withValues(alpha: 0.1), // El más suave para el historial
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonProducts() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final now = DateTime.now();
    final expiringSoon = _products.where((product) {
      if (product.expirationDate == null) return false;
      final days = product.expirationDate!.difference(now).inDays;
      return days >= 0 && days <= 30;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.expiringSoon,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppConstants.routeMyProducts),
                child: Text(
                  l10n.seeAll,
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (expiringSoon.isEmpty)
          _buildEmptyCard(theme, l10n)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expiringSoon.length > 5 ? 5 : expiringSoon.length,
            itemBuilder: (context, index) => _buildExpiringProductCard(expiringSoon[index]),
          ),
      ],
    );
  }

  // ... (Resto de métodos _buildEmptyCard, _buildExpiringProductCard y _buildActionCard se mantienen iguales)
  // He omitido la repetición para que sea más clara la lectura, 
  // pero mantén la lógica de diseño que ya te funcionaba perfectamente.

  Widget _buildEmptyCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(l10n.allFine, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.noProdExpiring, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildExpiringProductCard(BeautyProduct product) {
    final theme = Theme.of(context);
    final days = product.expirationDate!.difference(DateTime.now()).inDays;
    final isDanger = days <= 7;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => _navigateToProduct(product),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: product.imageUrl != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12), 
                  child: Image.network(product.imageUrl!, fit: BoxFit.cover))
              : Icon(Icons.face_retouching_natural, color: theme.colorScheme.outline),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(product.brand ?? '', style: theme.textTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDanger ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$days ${l10n.days}',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDanger ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                title, 
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}