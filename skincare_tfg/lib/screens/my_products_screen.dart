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
  
  ProductListType? _selectedListType; // ✅ Puede ser null (todos los productos)
  List<BeautyProduct> _allProducts = [];
  List<BeautyProduct> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedListType = widget.initialListType; // ✅ Puede ser null
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

  // ✅ Aplicar filtro: si es null, muestra todos
  List<BeautyProduct> _applyFilter(List<BeautyProduct> products, ProductListType? listType) {
    if (listType == null) {
      return products; // ✅ Mostrar todos los productos
    }
    return products.where((product) {
      return product.listType == listType.value;
    }).toList();
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  // ✅ Cambiar filtro: null = todos, o un tipo específico
  void _changeListType(ProductListType? newType) {
    setState(() {
      // Si ya está seleccionado, lo deseleccionamos (muestra todos)
      if (_selectedListType == newType) {
        _selectedListType = null; // ✅ Deseleccionar = mostrar todos
      } else {
        _selectedListType = newType; // ✅ Seleccionar filtro específico
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
    return CustomAppBar(
      title: 'Mis Productos',
      showDrawer: true,
      showBackButton: true,
      child: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                if (_selectedListType != null)
                  TextButton(
                    onPressed: () => _changeListType(_selectedListType),
                    child: const Text('Mostrar todos'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ProductListType.values.map((type) {
            final isSelected = _selectedListType == type;
            final count = _getProductCountByType(type);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildFilterChip(type, isSelected, count),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(ProductListType type, bool isSelected, int count) {
    return GestureDetector(
      onTap: () => _changeListType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? type.color : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? type.color : Colors.grey[300]!,
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
                color: isSelected ? Colors.white : type.color,
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
              const Icon(Icons.close, color: Colors.white, size: 16), // ✅ Icono de cerrar
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getEmptySubMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto eliminado correctamente')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showMoveToListDialog(BeautyProduct product) async {
    final newListType = await showDialog<ProductListType?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mover a otra lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProductListType.values.map((type) {
            final isCurrentType = product.listType == type.value;
            return ListTile(
              leading: Icon(type.icon, color: type.color),
              title: Text(type.label),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto movido a ${newListType.label.toLowerCase()}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al mover: $e')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }
}