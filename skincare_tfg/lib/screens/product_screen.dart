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
    'finishing': false,
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

    final theme = Theme.of(context);

    if (isError) {
      await WarningDialog.showInfo(
        context: context,
        title: 'Error',
        content: message,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<void> _markAsFinished() async {
    await _showMessage('Funcionalidad "Producto acabado" en desarrollo');
  }

  Future<void> _markAsOpened() async {
    final theme = Theme.of(context);

    final selectedOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Abrir producto', style: theme.textTheme.titleLarge),
        contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.today, color: theme.colorScheme.primary),
              title: const Text('Hoy'),
              onTap: () => Navigator.pop(context, 'hoy'),
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: theme.colorScheme.primary),
              title: const Text('Otra fecha...'),
              onTap: () => Navigator.pop(context, 'otra'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
        ],
      ),
    );
    if (selectedOption == null) return;

    DateTime? finalDate;

    if (selectedOption == 'hoy') {
      finalDate = DateTime.now();
    } else if (selectedOption == 'otra') {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: theme.colorScheme,
            ),
            child: child!,
          );
        },
      );

      if (pickedDate == null) return;
      finalDate = DateTime.utc(pickedDate.year, pickedDate.month, pickedDate.day, 12, 0, 0);
    }

    await _executeAction(
      action: () => _productService.markAsOpened(_currentProduct.id!, openedDate: finalDate),
      successMessage: '✓ Producto marcado como abierto',
      loadingKey: 'opening',
    );
  }

  Future<void> _markAsClosed() async {
    final hasPAO = _currentProduct.periodAfterOpening?.isNotEmpty == true;

    final expirationMessage = hasPAO
        ? '• Se eliminará la fecha de caducidad calculada\n'
        : '• Se conservará tu fecha de caducidad fija\n';

    if (!await _confirmAction(
      'Cerrar producto',
      '¿Estás seguro de que quieres cerrar "${_currentProduct.name}"?\n\n'
      'Al cerrar el producto:\n'
      '• Se eliminará la fecha de apertura\n'
      '$expirationMessage'
      '• Se conservará la duración después de abrir (ej: "6M")\n\n'
      'Podrás volver a abrirlo más tarde si fue un error.',
      isDanger: true,
    )) {
      return;
    }

    await _executeAction(
      action: () {
        final updatedData = <String, dynamic>{
          'openedDate': null,
          'isOpened': false,
        };

        if (hasPAO) {
          updatedData['expirationDate'] = null;
        }

        return _productService.updateProduct(_currentProduct.id!, updatedData);
      },
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
    final theme = Theme.of(context);

    return CustomAppBar(
      title: _currentProduct.name,
      showDrawer: false,
      showBackButton: true,
      actions: _buildAppBarActions(isProductSaved, showAddButton),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProductImage(),
                  const SizedBox(height: 24),
                  _buildProductHeader(theme),
                  const SizedBox(height: 24),
                  if (isProductSaved) _buildProductDetails(theme),
                  if (_currentProduct.categories?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    _buildCategories(theme),
                  ],
                  const SizedBox(height: 24),
                  // Todos los botones excepto eliminar
                  _buildScrollableButtons(isProductSaved, showAddButton),
                ],
              ),
            ),
          ),
          // Solo el botón de eliminar fijo abajo (si aplica)
          if (isProductSaved)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Eliminar producto',
                onPressed: _isLoading('deleting') ? () {} : _deleteProduct,
                type: ButtonType.danger,
                size: ButtonSize.full,
                icon: Icons.delete,
                isLoading: _isLoading('deleting'),
                isEnabled: !_isLoading('deleting'),
              ),
            ),
        ],
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

  Widget _buildProductImage() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _currentProduct.imageUrl?.isNotEmpty == true
              ? Image.network(
                  _currentProduct.imageUrl!,
                  width: 160,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _PlaceholderImage(),
                )
              : const _PlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildProductHeader(ThemeData theme) {
    return Column(
      children: [
        if (_currentProduct.brand?.isNotEmpty == true)
          Text(
            _currentProduct.brand!.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 8),
        Text(
          _currentProduct.name.isNotEmpty ? _currentProduct.name : 'Sin nombre',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (_currentProduct.rating != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < _currentProduct.rating! ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentProduct.rating}/5',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductDetails(ThemeData theme) {
    final isReallyOpened = _currentProduct.isOpened == true && _currentProduct.openedDate != null;
    final hasExpirationInfo = (_currentProduct.periodAfterOpening?.isNotEmpty == true) || (_currentProduct.expirationDate != null);
    final subtleText = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentProduct.addedAt != null) ...[
            _InfoRow(icon: Icons.calendar_today, label: 'Agregado', value: _formatDate(_currentProduct.addedAt!)),
            const SizedBox(height: 12),
          ],
          if (_currentProduct.expirationDate != null) ...[
            _InfoRow(icon: Icons.warning_amber, label: 'Caducidad', value: _formatDate(_currentProduct.expirationDate!)),
            const SizedBox(height: 12),
          ],
          if (isReallyOpened && _currentProduct.openedDate != null) ...[
            _InfoRow(icon: Icons.open_in_new, label: 'Abierto el', value: _formatDate(_currentProduct.openedDate!)),
            const SizedBox(height: 12),
          ],
          if (isReallyOpened && _currentProduct.periodAfterOpening?.isNotEmpty == true) ...[
            _InfoRow(icon: Icons.timer, label: 'Duración después de abrir', value: _currentProduct.periodAfterOpening!),
            const SizedBox(height: 12),
          ],
          if (isReallyOpened && !hasExpirationInfo) _buildExpirationWarning(theme),
          if (_currentProduct.notes?.isNotEmpty == true) ...[
            const Divider(height: 24),
            Text(
              'Notas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subtleText),
            ),
            const SizedBox(height: 8),
            Text(_currentProduct.notes!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final warningColor = isDarkMode ? Colors.orange[300]! : Colors.orange[800]!;
    final bgColor = Colors.orange.withValues(alpha: 0.15);
    final borderColor = warningColor.withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: warningColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Sin información de caducidad',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: warningColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Edita el producto para añadir su duración después de abierto (ej: "6M") o una fecha de caducidad.',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    final subtleText = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final chipBg = theme.colorScheme.onSurface.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subtleText),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currentProduct.categories!.take(6).map((cat) => Chip(
                label: Text(cat, style: theme.textTheme.bodySmall),
                backgroundColor: chipBg,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
        ),
      ],
    );
  }

  // Nuevo método: botones que van dentro del scroll (todos excepto eliminar)
  Widget _buildScrollableButtons(bool isProductSaved, bool showAddButton) {
    final isReallyOpened = _currentProduct.isOpened == true && _currentProduct.openedDate != null;
    final canCalculateExpiration = isReallyOpened &&
        _currentProduct.periodAfterOpening?.isNotEmpty == true &&
        _currentProduct.expirationDate == null;

    return Column(
      children: [
        if (showAddButton) ...[
          CustomButton(
            text: 'Agregar a mis productos',
            onPressed: _isLoading('adding') ? () {} : _addToMyProducts,
            type: ButtonType.primary,
            size: ButtonSize.full,
            icon: Icons.add,
            isLoading: _isLoading('adding'),
            isEnabled: !_isLoading('adding'),
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
        if (isProductSaved) ...[
          CustomButton(
            text: 'Producto acabado',
            onPressed: _isLoading('finishing') ? () {} : _markAsFinished,
            type: ButtonType.secondary,
            size: ButtonSize.full,
            icon: Icons.check_circle_outline,
            isLoading: _isLoading('finishing'),
            isEnabled: !_isLoading('finishing') && !_isLoading('editing'),
          ),
          const SizedBox(height: 12),
        ],
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
    final theme = Theme.of(context);
    final subtleIcon = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final subtleText = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Icon(icon, size: 18, color: subtleIcon),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13, color: subtleText)),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 160,
      width: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        Icons.spa_outlined,
        size: 72,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}