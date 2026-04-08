// lib/screens/my_products_screen.dart
import 'package:flutter/material.dart';
import '../models/beauty_product.dart';
import '../models/product_list_type.dart';
import '../services/product_service.dart';
import '../widgets/main_toolbar.dart';
import '../widgets/product_card.dart';
import 'product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  final ProductListType? initialListType;

  const MyProductsScreen({super.key, this.initialListType});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final ProductService _productService = ProductService();
  
  ProductListType? _selectedListType;
  List<BeautyProduct> _allProducts = [];
  List<BeautyProduct> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedListType = widget.initialListType;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allProducts = await _productService.getProducts();
      
      if (mounted) {
        setState(() {
          _allProducts = allProducts;
          _filteredProducts = _applyFilter(allProducts, _selectedListType);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar los productos: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<BeautyProduct> _applyFilter(List<BeautyProduct> products, ProductListType? listType) {
    if (listType == null) {
      return products; 
    }
    return products.where((product) {
      return product.listType == listType.value;
    }).toList();
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  void _changeListType(ProductListType? newType) {
    setState(() {
      if (_selectedListType == newType) {
        _selectedListType = null; 
      } else {
        _selectedListType = newType; 
      }
      _filteredProducts = _applyFilter(_allProducts, _selectedListType);
    });
  }

  Future<void> _navigateToProduct(BeautyProduct product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(product: product, isFromSearch: false),
      ),
    );
    await _loadProducts();
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getTitle() {
    if (_selectedListType == null) {
      return 'Todos los productos (${_filteredProducts.length})';
    }
    return '${_selectedListType!.label} (${_filteredProducts.length})';
  }

  String _getEmptyMessage() {
    if (_selectedListType == null) {
      return 'No tienes productos registrados';
    }
    switch (_selectedListType!) {
      case ProductListType.have:
        return 'No tienes productos en "Tengo"';
      case ProductListType.wishlist:
        return 'No tienes productos en "Deseados"';
      case ProductListType.favorites:
        return 'No tienes productos favoritos';
      case ProductListType.used:
        return 'No has registrado productos usados';
    }
  }

  String _getEmptySubMessage() {
    if (_selectedListType == null) {
      return 'Agrega tus primeros productos escaneando códigos de barras o buscando en la base de datos';
    }
    switch (_selectedListType!) {
      case ProductListType.have:
        return 'Los productos que marques como "Tengo" aparecerán aquí';
      case ProductListType.wishlist:
        return 'Agrega productos a tu wishlist desde la pantalla de detalles';
      case ProductListType.favorites:
        return 'Marca productos como favoritos desde la pantalla de detalles';
      case ProductListType.used:
        return 'Los productos que marques como usados aparecerán aquí';
    }
  }

  int _getProductCountByType(ProductListType type) {
    return _allProducts.where((p) => p.listType == type.value).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtleText = theme.colorScheme.onSurface.withOpacity(0.6);

    return CustomAppBar(
      title: 'Mis Productos',
      showDrawer: true,
      showBackButton: true,
      child: Column(
        children: [
          _buildFilterChips(theme),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subtleText,
                  ),
                ),
                if (_selectedListType != null)
                  TextButton(
                    onPressed: () => _changeListType(_selectedListType),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                    child: const Text('Mostrar todos'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              color: theme.colorScheme.primary,
              child: _buildContent(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Fondo adaptativo
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ProductListType.values.map((type) {
            final isSelected = _selectedListType == type;
            final count = _getProductCountByType(type);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildFilterChip(type, isSelected, count, theme),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(ProductListType type, bool isSelected, int count, ThemeData theme) {
    final unselectedBg = theme.colorScheme.onSurface.withOpacity(0.05);
    final unselectedBorder = theme.colorScheme.onSurface.withOpacity(0.1);
    final unselectedText = theme.colorScheme.onSurface.withOpacity(0.7);

    return GestureDetector(
      onTap: () => _changeListType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? type.color : unselectedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? type.color : unselectedBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              color: isSelected ? Colors.white : type.color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: TextStyle(
                color: isSelected ? Colors.white : unselectedText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.3) 
                      : type.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : type.color,
                  ),
                ),
              ),
            ],
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, color: Colors.white, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedListType?.icon ?? Icons.inbox_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getEmptySubMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProduct(product),
          onDelete: () => _showDeleteDialog(product),
          onMove: () => _showMoveToListDialog(product),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BeautyProduct product) async {
    final theme = Theme.of(context);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: theme.brightness == Brightness.dark 
              ? BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))
              : BorderSide.none,
        ),
        title: Text('Eliminar producto', style: theme.textTheme.titleLarge),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product.name}"?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        if (product.id != null) {
          await _productService.deleteProduct(product.id!);
          await _loadProducts();
          if (mounted) {
            _showCustomSnackBar('Producto eliminado correctamente');
          }
        }
      } catch (e) {
        if (mounted) {
          _showCustomSnackBar('Error al eliminar: $e', isError: true);
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showMoveToListDialog(BeautyProduct product) async {
    final theme = Theme.of(context);
    
    final newListType = await showDialog<ProductListType?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: theme.brightness == Brightness.dark 
              ? BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))
              : BorderSide.none,
        ),
        title: Text('Mover a otra lista', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProductListType.values.map((type) {
            final isCurrentType = product.listType == type.value;
            return ListTile(
              leading: Icon(type.icon, color: type.color),
              title: Text(type.label, style: theme.textTheme.bodyMedium),
              trailing: isCurrentType 
                  ? Icon(Icons.check_circle, color: type.color, size: 20)
                  : null,
              onTap: () => Navigator.pop(context, type),
            );
          }).toList(),
        ),
      ),
    );

    if (newListType != null && product.listType != newListType.value) {
      setState(() => _isLoading = true);
      try {
        final updatedProduct = product.copyWith(listType: newListType.value);
        if (product.id != null) {
          await _productService.updateProduct(product.id!, updatedProduct.toBackendJson());
          await _loadProducts();
          if (mounted) {
            _showCustomSnackBar('Producto movido a ${newListType.label.toLowerCase()}');
          }
        }
      } catch (e) {
        if (mounted) {
          _showCustomSnackBar('Error al mover: $e', isError: true);
          setState(() => _isLoading = false);
        }
      }
    }
  }
}