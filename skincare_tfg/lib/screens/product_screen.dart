import 'package:flutter/material.dart';
import '../widgets/main_toolbar.dart';
import '../models/beauty_product.dart';
import '../services/product_service.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/warning_dialog.dart';

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
  late BeautyProduct _currentProduct;
  
  // Estados de carga
  final Map<String, bool> _loadingStates = {
    'adding': false,
    'editing': false,
    'deleting': false,
    'opening': false,
    'closing': false,
    'calculating': false,
  };

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  // --- HELPERS ---
  
  void _setLoading(String key, bool value) {
    if (mounted) {
      setState(() => _loadingStates[key] = value);
    }
  }

  bool _isLoading(String key) => _loadingStates[key] == true;

  Future<void> _showMessage(String message, {bool isError = false}) async {
    if (!mounted) return;
    
    if (isError) {
      await WarningDialog.showInfo(
        context: context,
        title: 'Error',
        content: message,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _confirmAction(String title, String content, {bool isDanger = false}) async {
    return await WarningDialog.show(
      context: context,
      title: title,
      content: content,
      confirmText: isDanger ? 'Eliminar' : 'Aceptar',
      isDanger: isDanger,
    );
  }

  Future<void> _executeAction({
    required Future<BeautyProduct?> Function() action,
    required String successMessage,
    required String loadingKey,
    VoidCallback? onSuccess,
  }) async {
    _setLoading(loadingKey, true);
    final result = await action();
    _setLoading(loadingKey, false);

    if (result != null) {
      setState(() => _currentProduct = result);
      await _showMessage(successMessage);
      onSuccess?.call();
    } else {
      await _showMessage('Error al realizar la operación', isError: true);
    }
  }

  // --- ACCIONES PRINCIPALES ---

  Future<void> _addToMyProducts() async {
    if (!await _confirmAction('Agregar producto', '¿Quieres agregar "${_currentProduct.name}" a tu lista de productos?')) return;

    await _executeAction(
      action: () => _productService.addProductToHave(_currentProduct),
      successMessage: '✓ "${_currentProduct.name}" agregado a tu lista',
      loadingKey: 'adding',
      onSuccess: () {
        if (widget.isFromSearch && mounted) Navigator.pop(context);
      },
    );
  }

  Future<void> _editProduct() async {
    final editedProduct = await showDialog<BeautyProduct>(
      context: context,
      builder: (context) => EditProductDialog(product: _currentProduct),
    );

    if (editedProduct != null && editedProduct != _currentProduct) {
      final updatedData = <String, dynamic>{
        'name': editedProduct.name,
        'brand': editedProduct.brand,
        'categories': editedProduct.categories,
        'notes': editedProduct.notes,
        'rating': editedProduct.rating,
        'periodAfterOpening': editedProduct.periodAfterOpening,
        'expirationDate': editedProduct.expirationDate?.toIso8601String(),
        'openedDate': editedProduct.openedDate?.toIso8601String(),
      };

      await _executeAction(
        action: () => _productService.updateProduct(_currentProduct.id!, updatedData),
        successMessage: '✓ Producto actualizado correctamente',
        loadingKey: 'editing',
      );
    }
  }

  Future<void> _deleteProduct() async {
    if (!await _confirmAction('Eliminar producto', '¿Estás seguro de que quieres eliminar "${_currentProduct.name}" de tu lista?', isDanger: true)) return;

    _setLoading('deleting', true);
    final deleted = await _productService.deleteProduct(_currentProduct.id!);
    _setLoading('deleting', false);

    if (deleted) {
      await _showMessage('✓ "${_currentProduct.name}" eliminado de tu lista');
      if (mounted) Navigator.pop(context, true);
    } else {
      await _showMessage('Error al eliminar el producto', isError: true);
    }
  }

  Future<void> _markAsOpened() async {
    bool useCustomDate = false;
    DateTime? selectedDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Abrir producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuándo abriste este producto?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildDateRadio('Hoy', false, useCustomDate, (val) => setDialogState(() => useCustomDate = val)),
                  _buildDateRadio('Otra fecha', true, useCustomDate, (val) => setDialogState(() => useCustomDate = val)),
                ],
              ),
              if (useCustomDate) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  child: Text('Seleccionar fecha: ${_formatDate(selectedDate!)}'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Abrir producto')),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final openedDate = useCustomDate ? selectedDate : DateTime.now();
    await _executeAction(
      action: () => _productService.markAsOpened(_currentProduct.id!, openedDate: openedDate),
      successMessage: '✓ Producto marcado como abierto',
      loadingKey: 'opening',
    );
  }

  Future<void> _markAsClosed() async {
    if (!await _confirmAction(
      'Cerrar producto',
      '¿Estás seguro de que quieres cerrar "${_currentProduct.name}"?\n\n'
      'Al cerrar el producto:\n'
      '• Se eliminará la fecha de apertura\n'
      '• Se eliminará la fecha de caducidad calculada\n'
      '• Se conservará la duración después de abrir (ej: "6M")\n\n'
      'Podrás volver a abrirlo más tarde si fue un error.',
      isDanger: true,
    )) return;

    await _executeAction(
      action: () => _productService.markAsClosed(_currentProduct.id!),
      successMessage: '✓ Producto cerrado correctamente',
      loadingKey: 'closing',
    );
  }

  Future<void> _calculateExpiration() => _executeAction(
    action: () => _productService.calculateExpiration(_currentProduct.id!),
    successMessage: '✓ Fecha de caducidad calculada',
    loadingKey: 'calculating',
  );

  // --- UI ---

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
            if (_currentProduct.categories?.isNotEmpty == true) _buildCategories(),
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
          icon: _isLoading('editing') 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.edit),
          onPressed: _isLoading('editing') ? null : _editProduct,
          tooltip: 'Editar producto',
        ),
      if (showAddButton)
        IconButton(
          icon: _isLoading('adding')
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.add),
          onPressed: _isLoading('adding') ? null : _addToMyProducts,
          tooltip: 'Agregar a mis productos',
        ),
    ];
  }

  Widget _buildDateRadio(String label, bool value, bool groupValue, Function(bool) onChanged) {
    return Expanded(
      child: ListTile(
        title: Text(label),
        leading: Radio<bool>(
          value: value,
          groupValue: groupValue,
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _currentProduct.imageUrl?.isNotEmpty == true
            ? Image.network(
                _currentProduct.imageUrl!,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const _PlaceholderImage(),
              )
            : const _PlaceholderImage(),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentProduct.brand?.isNotEmpty == true)
          Text(
            _currentProduct.brand!.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          _currentProduct.name.isNotEmpty ? _currentProduct.name : 'Sin nombre',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (_currentProduct.rating != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < _currentProduct.rating! ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text('${_currentProduct.rating}/5', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductDetails() {
    final isReallyOpened = _currentProduct.isOpened == true && _currentProduct.openedDate != null;
    final hasExpirationInfo = (_currentProduct.periodAfterOpening?.isNotEmpty == true) || (_currentProduct.expirationDate != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentProduct.addedAt != null) ...[
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.calendar_today, label: 'Agregado', value: _formatDate(_currentProduct.addedAt!)),
        ],
        if (_currentProduct.expirationDate != null) ...[
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.warning_amber, label: 'Caducidad', value: _formatDate(_currentProduct.expirationDate!)),
        ],
        if (isReallyOpened && _currentProduct.openedDate != null) ...[
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.open_in_new, label: 'Abierto el', value: _formatDate(_currentProduct.openedDate!)),
        ],
        if (isReallyOpened && _currentProduct.periodAfterOpening?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.timer, label: 'Duración después de abrir', value: _currentProduct.periodAfterOpening!),
        ],
        if (isReallyOpened && !hasExpirationInfo) _buildExpirationWarning(),
        if (_currentProduct.notes?.isNotEmpty == true) ...[
          const Divider(height: 32),
          Text('Notas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 10),
          Text(_currentProduct.notes!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildExpirationWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ Sin información de caducidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Edita el producto para añadir su duración después de abierto (ej: "6M") o una fecha de caducidad.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorías', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currentProduct.categories!.take(6).map((cat) => Chip(
            label: Text(cat, style: const TextStyle(fontSize: 12)),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isProductSaved, bool showAddButton) {
    final isReallyOpened = _currentProduct.isOpened == true && _currentProduct.openedDate != null;
    final canCalculateExpiration = isReallyOpened && 
                                   _currentProduct.periodAfterOpening?.isNotEmpty == true && 
                                   _currentProduct.expirationDate == null;

    return Column(
      children: [
        if (isProductSaved) ...[
          CustomButton(
            text: 'Eliminar producto',
            onPressed: _isLoading('deleting') ? () {} : _deleteProduct,
            type: ButtonType.danger,
            size: ButtonSize.full,
            icon: Icons.delete,
            isLoading: _isLoading('deleting'),
            isEnabled: !_isLoading('deleting'),
          ),
          const SizedBox(height: 12),
        ],
        if (isProductSaved && !isReallyOpened) ...[
          CustomButton(
            text: 'Abrir producto',
            onPressed: _isLoading('opening') ? () {} : _markAsOpened,
            type: ButtonType.primary,
            size: ButtonSize.full,
            icon: Icons.open_in_new,
            isLoading: _isLoading('opening'),
            isEnabled: !_isLoading('opening') && !_isLoading('editing'),
          ),
          const SizedBox(height: 12),
        ],
        if (isProductSaved && isReallyOpened) ...[
          CustomButton(
            text: 'Cerrar producto',
            onPressed: _isLoading('closing') ? () {} : _markAsClosed,
            type: ButtonType.secondary,
            size: ButtonSize.full,
            icon: Icons.close,
            isLoading: _isLoading('closing'),
            isEnabled: !_isLoading('closing') && !_isLoading('editing'),
          ),
          const SizedBox(height: 12),
        ],
        if (canCalculateExpiration) ...[
          CustomButton(
            text: 'Calcular caducidad',
            onPressed: _isLoading('calculating') ? () {} : _calculateExpiration,
            type: ButtonType.secondary,
            size: ButtonSize.full,
            icon: Icons.calculate,
            isLoading: _isLoading('calculating'),
            isEnabled: !_isLoading('calculating') && !_isLoading('editing'),
          ),
          const SizedBox(height: 12),
        ],
        if (showAddButton)
          CustomButton(
            text: 'Agregar a mis productos',
            onPressed: _isLoading('adding') ? () {} : _addToMyProducts,
            type: ButtonType.primary,
            size: ButtonSize.full,
            icon: Icons.add,
            isLoading: _isLoading('adding'),
            isEnabled: !_isLoading('adding'),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

// --- COMPONENTES REUTILIZABLES ---

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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.spa_outlined, size: 72, color: Theme.of(context).colorScheme.outline),
    );
  }
}