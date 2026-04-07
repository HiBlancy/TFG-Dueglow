// lib/screens/home_screen.dart (corregido)

import 'package:flutter/material.dart';
import '../constants/app_constants.dart'; // ✅ Importar AppConstants
import '../models/beauty_product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../widgets/main_toolbar.dart';
import 'product_screen.dart';

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

  // Método para navegar al detalle del producto y esperar resultado
  Future<void> _navigateToProduct(BeautyProduct product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(product: product, isFromSearch: false),
      ),
    );
    // Recargar los datos cuando el usuario regrese
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Skincare App',
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
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '¡Hola $_userName!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Bienvenido a Skincare App.\nTu aplicación para el cuidado de la piel.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildExpiringSoonProducts(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  Icons.shopping_bag_outlined,
                  'Mis productos',
                  'Ver todos',
                  () {
                    // Navegar a la pantalla de todos los productos
                    Navigator.pushNamed(context, AppConstants.routeMyProducts);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  Icons.face_retouching_natural_outlined,
                  'Rutinas',
                  'Próximamente',
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
                  'Categorías',
                  'Próximamente',
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
    // Filtrar productos que tienen fecha de caducidad y están próximos (30 días)
    final now = DateTime.now();
    final expiringSoon = _products.where((product) {
      if (product.expirationDate == null) return false;
      final daysUntilExpiration = product.expirationDate!.difference(now).inDays;
      return daysUntilExpiration >= 0 && daysUntilExpiration <= 30;
    }).toList();

    if (expiringSoon.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                SizedBox(height: 12),
                Text(
                  '¡Todo en orden!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'No hay productos próximos a caducar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próximos a caducar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de productos
                  Navigator.pushNamed(context, AppConstants.routeMyProducts);
                },
                child: const Text('Ver todos'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expiringSoon.length > 5 ? 5 : expiringSoon.length,
          itemBuilder: (context, index) {
            final product = expiringSoon[index];
            return _buildExpiringProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildExpiringProductCard(BeautyProduct product) {
    final daysUntilExpiration = product.expirationDate!.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.face_rounded,
                              color: Colors.grey[400],
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.face_rounded,
                        color: Colors.grey[400],
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      Text(
                        product.brand!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              
              // Indicador de días restantes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: daysUntilExpiration <= 7 ? Colors.red[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '$daysUntilExpiration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: daysUntilExpiration <= 7 ? Colors.red[700] : Colors.orange[700],
                      ),
                    ),
                    Text(
                      'días',
                      style: TextStyle(
                        fontSize: 10,
                        color: daysUntilExpiration <= 7 ? Colors.red[700] : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}