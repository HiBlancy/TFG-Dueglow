import 'package:flutter/material.dart';
import '../widgets/main_toolbar.dart';
import '../models/beauty_product.dart';
import '../services/product_service.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/custom_button.dart';

class ProductScreen extends StatefulWidget {
  final BeautyProduct product;
  final bool isFromSearch;

  const ProductScreen({
    super.key,
    required this.product,
    this.isFromSearch = false,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  bool _isAdding = false;
  bool _isEditing = false;
  bool _isDeleting = false;
  bool _isOpening = false;
  bool _isClosing = false;
  bool _isCalculating = false;
  late BeautyProduct _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  // --- HELPERS PARA REDUCIR CÓDIGO DUPLICADO ---

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _confirmAction(String title, String content, {String confirmText = 'Aceptar', bool isDanger = false}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDanger ? ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white) : null,
            child: Text(isDanger ? 'Eliminar' : confirmText),
          ),
        ],
      ),
    );
    return result == true;
  }

  // --- MÉTODOS DE ACCIÓN ---

  Future<void> _addToMyProducts() async {
    if (!await _confirmAction('Agregar producto', '¿Quieres agregar "${_currentProduct.name}" a tu lista de productos?', confirmText: 'Agregar')) return;

    setState(() => _isAdding = true);
    final added = await _productService.addProductToHave(_currentProduct);
    setState(() => _isAdding = false);

    if (added != null) {
      setState(() => _currentProduct = added);
      _showSnack('✓ "${_currentProduct.name}" agregado a tu lista');
      if (widget.isFromSearch && mounted) Navigator.pop(context);
    } else {
      _showSnack('Error al agregar el producto. Intenta de nuevo.', isError: true);
    }
  }

 Future<void> _editProduct() async {
  final editedProduct = await showDialog<BeautyProduct>(
    context: context,
    builder: (context) => EditProductDialog(product: _currentProduct),
  );

  if (editedProduct != null && editedProduct != _currentProduct) {
    // ✅ LOG PARA VER QUÉ LLEGA DEL DIÁLOGO
    print('✏️ Producto editado recibido:');
    print('   - notes: "${editedProduct.notes}"');
    print('   - brand: "${editedProduct.brand}"');
    print('   - periodAfterOpening: "${editedProduct.periodAfterOpening}"');
    print('   - categories: ${editedProduct.categories}');

    setState(() => _isEditing = true);

    final updatedData = <String, dynamic>{
      'name': editedProduct.name,
      'brand': editedProduct.brand,  // ✅ ya puede ser null
      'categories': editedProduct.categories,  // ✅ ya puede ser null
      'notes': editedProduct.notes,  // ✅ ya puede ser null
      'rating': editedProduct.rating,
      'periodAfterOpening': editedProduct.periodAfterOpening,
      'expirationDate': editedProduct.expirationDate?.toIso8601String(),
      'openedDate': editedProduct.openedDate?.toIso8601String(),
    };

    // ✅ LOG DE LO QUE SE VA A ENVIAR
    print('📤 Enviando al backend:');
    //print(jsonEncode(updatedData));

    final updated = await _productService.updateProduct(_currentProduct.id!, updatedData);
    setState(() => _isEditing = false);

    if (updated != null) {
      setState(() => _currentProduct = updated);
      _showSnack('✓ Producto actualizado correctamente');
    } else {
      _showSnack('Error al actualizar el producto', isError: true);
    }
  }
}
  Future<void> _deleteProduct() async {
    if (!await _confirmAction('Eliminar producto', '¿Estás seguro de que quieres eliminar "${_currentProduct.name}" de tu lista?', isDanger: true)) return;

    setState(() => _isDeleting = true);
    final deleted = await _productService.deleteProduct(_currentProduct.id!);
    setState(() => _isDeleting = false);

    if (deleted) {
      _showSnack('✓ "${_currentProduct.name}" eliminado de tu lista');
      if (mounted) Navigator.pop(context, true);
    } else {
      _showSnack('Error al eliminar el producto. Intenta de nuevo.', isError: true);
    }
  }

  Future<void> _updateProductState(Future<BeautyProduct?> Function() action, String successMsg, String errorMsg, void Function(bool) setLoading) async {
    setLoading(true);
    final updated = await action();
    setLoading(false);

    if (updated != null) {
      setState(() => _currentProduct = updated);
      _showSnack(successMsg);
    } else {
      _showSnack(errorMsg, isError: true);
    }
  }

  Future<void> _markAsOpened() => _updateProductState(() => _productService.markAsOpened(_currentProduct.id!), '✓ Producto marcado como abierto', 'Error al marcar como abierto', (val) => setState(() => _isOpening = val));
  Future<void> _markAsClosed() => _updateProductState(() => _productService.markAsClosed(_currentProduct.id!), '✓ Producto marcado como cerrado', 'Error al marcar como cerrado', (val) => setState(() => _isClosing = val));
  Future<void> _calculateExpiration() => _updateProductState(() => _productService.calculateExpiration(_currentProduct.id!), '✓ Fecha de caducidad calculada', 'Error al calcular caducidad', (val) => setState(() => _isCalculating = val));

  // --- CONSTRUCCIÓN DE UI ---

  @override
  Widget build(BuildContext context) {
    final isProductSaved = _currentProduct.id != null;
    final showAddButton = widget.isFromSearch && !isProductSaved;

    return CustomAppBar(
      title: _currentProduct.name,
      showDrawer: false,
      showBackButton: true,
      actions: _buildAppBarActions(isProductSaved, showAddButton),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: 24),
            _buildProductHeader(),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.qr_code, label: 'Código de barras', value: _currentProduct.barcode.isNotEmpty ? _currentProduct.barcode : '—'),
            if (isProductSaved) _buildProductDetails(),
            const Divider(height: 32),
            if (_currentProduct.categories != null && _currentProduct.categories!.isNotEmpty) _buildCategories(),
            const SizedBox(height: 24),
            _buildActionButtons(isProductSaved, showAddButton),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(bool isProductSaved, bool showAddButton) {
    return [
      if (isProductSaved)
        IconButton(
          icon: _isEditing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.edit),
          onPressed: _isEditing ? null : _editProduct,
          tooltip: 'Editar producto',
        ),
      if (showAddButton)
        IconButton(
          icon: _isAdding ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add),
          onPressed: _isAdding ? null : _addToMyProducts,
          tooltip: 'Agregar a mis productos',
        ),
    ];
  }

  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _currentProduct.imageUrl?.isNotEmpty == true
            ? Image.network(_currentProduct.imageUrl!, height: 220, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const _PlaceholderImage())
            : const _PlaceholderImage(),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentProduct.brand != null && _currentProduct.brand!.isNotEmpty)
  Text(_currentProduct.brand!.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(_currentProduct.name.isNotEmpty ? _currentProduct.name : 'Sin nombre', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (_currentProduct.rating != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(5, (index) => Icon(index < _currentProduct.rating! ? Icons.star : Icons.star_border, color: Colors.amber, size: 20)),
              const SizedBox(width: 8),
              Text('${_currentProduct.rating}/5', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentProduct.addedAt != null) ...[const SizedBox(height: 12), _InfoRow(icon: Icons.calendar_today, label: 'Agregado', value: _formatDate(_currentProduct.addedAt!))],
        if (_currentProduct.expirationDate != null) ...[const SizedBox(height: 12), _InfoRow(icon: Icons.warning_amber, label: 'Caducidad', value: _formatDate(_currentProduct.expirationDate!))],
        if (_currentProduct.periodAfterOpening?.isNotEmpty == true) ...[const SizedBox(height: 12), _InfoRow(icon: Icons.timer, label: 'Duración después de abrir', value: _currentProduct.periodAfterOpening!)],
        if (_currentProduct.openedDate != null) ...[const SizedBox(height: 12), _InfoRow(icon: Icons.open_in_new, label: 'Abierto el', value: _formatDate(_currentProduct.openedDate!))],
        if (_currentProduct.notes?.isNotEmpty == true) ...[
          const Divider(height: 32),
          Text('Notas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 10),
          Text(_currentProduct.notes!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildCategories() {
  // ✅ Verificar que categories no sea null
  if (_currentProduct.categories == null || _currentProduct.categories!.isEmpty) {
    return const SizedBox.shrink();
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Categorías', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.outline)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _currentProduct.categories!.take(6).map((cat) => 
          Chip(
            label: Text(cat, style: const TextStyle(fontSize: 12)), 
            padding: EdgeInsets.zero, 
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
          )
        ).toList(),
      ),
    ],
  );
}


  Widget _buildActionButtons(bool isProductSaved, bool showAddButton) {
    return Column(
      children: [
        if (isProductSaved) ...[
          CustomButton(text: 'Eliminar producto', onPressed: _isDeleting ? () {} : _deleteProduct, type: ButtonType.danger, size: ButtonSize.full, icon: Icons.delete, isLoading: _isDeleting, isEnabled: !_isDeleting),
          const SizedBox(height: 12),
        ],
        if (isProductSaved && _currentProduct.isOpened == false) ...[
          CustomButton(text: 'Abrir producto', onPressed: _isEditing ? () {} : _markAsOpened, type: ButtonType.primary, size: ButtonSize.full, icon: Icons.open_in_new, isLoading: _isOpening, isEnabled: !_isOpening && !_isEditing),
          const SizedBox(height: 12),
        ],
        if (isProductSaved && _currentProduct.isOpened == true) ...[
          CustomButton(text: 'Cerrar producto', onPressed: _isEditing ? () {} : _markAsClosed, type: ButtonType.secondary, size: ButtonSize.full, icon: Icons.close, isLoading: _isClosing, isEnabled: !_isClosing && !_isEditing),
          const SizedBox(height: 12),
        ],
        if (isProductSaved && _currentProduct.isOpened == true && _currentProduct.periodAfterOpening?.isNotEmpty == true) ...[
          CustomButton(text: 'Calcular caducidad', onPressed: _isEditing ? () {} : _calculateExpiration, type: ButtonType.secondary, size: ButtonSize.full, icon: Icons.calculate, isLoading: _isCalculating, isEnabled: !_isCalculating && !_isEditing),
          const SizedBox(height: 12),
        ],
        if (showAddButton) CustomButton(text: 'Agregar a mis productos', onPressed: _isAdding ? () {} : _addToMyProducts, type: ButtonType.primary, size: ButtonSize.full, icon: Icons.add, isLoading: _isAdding, isEnabled: !_isAdding),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
      child: Icon(Icons.spa_outlined, size: 72, color: Theme.of(context).colorScheme.outline),
    );
  }
}