// lib/widgets/edit_product_dialog.dart (simplificado)

import 'package:flutter/material.dart';
import '../models/beauty_product.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class EditProductDialog extends StatefulWidget {
  final BeautyProduct product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _notesController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _periodAfterOpeningController;
  final TextEditingController _newCategoryController = TextEditingController();

  int? _rating;
  DateTime? _expirationDate;
  DateTime? _openedDate;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.name);
    _brandController = TextEditingController(text: p.brand);
    _notesController = TextEditingController(text: p.notes ?? '');
    _barcodeController = TextEditingController(text: p.barcode);
    _periodAfterOpeningController = TextEditingController(
      text: p.periodAfterOpening ?? '',
    );
    _rating = p.rating;
    _expirationDate = p.expirationDate;
    _openedDate = p.openedDate;
    _categories = List.from(p.categories ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    _periodAfterOpeningController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // Lógica unificada para seleccionar fechas
  Future<void> _selectDate({
    required DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onDateSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && mounted) setState(() => onDateSelected(picked));
  }

  void _addCategory() {
    if (_newCategoryController.text.trim().isNotEmpty) {
      setState(() {
        _categories.add(_newCategoryController.text.trim());
        _newCategoryController.clear();
      });
    }
  }

  void _saveProduct() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    // 🔴 IMPORTANTE: Si no hay fecha de apertura, el producto NO está abierto
    final hasOpenedDate = _openedDate != null;

    final updatedProduct = BeautyProduct(
      id: widget.product.id,
      barcode: widget.product.barcode,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      imageUrl: widget.product.imageUrl,
      categories: _categories.isEmpty ? null : _categories,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      rating: _rating,
      listType: widget.product.listType,
      expirationDate: _expirationDate,
      periodAfterOpening: _periodAfterOpeningController.text.trim().isEmpty
          ? null
          : _periodAfterOpeningController.text.trim(),
      openedDate: _openedDate, // Puede ser null
      addedAt: widget.product.addedAt,
      isOpened: hasOpenedDate, // 🔴 Sincronizar isOpened con openedDate
    );

    Navigator.pop(context, updatedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 500,
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nombre del producto *',
                      prefixIcon: Icons.spa,
                      hint: 'Ej: Crema hidratante facial',
                      validator: (v) => v?.trim().isEmpty == true
                          ? 'El nombre es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _brandController,
                      label: 'Marca',
                      prefixIcon: Icons.branding_watermark,
                      hint: 'Ej: L\'Oréal, Nivea, Garnier',
                    ),
                    const SizedBox(height: 16),
                    _buildBarcodeField(),
                    const SizedBox(height: 16),
                    _buildRatingSection(),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      icon: Icons.warning_amber,
                      iconColor: Colors.orange,
                      text: _expirationDate != null
                          ? 'Caducidad: ${_formatDate(_expirationDate!)}'
                          : 'Añadir fecha de caducidad',
                      isActive: _expirationDate != null,
                      onTap: () => _selectDate(
                        initialDate: _expirationDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                        onDateSelected: (date) => _expirationDate = date,
                      ),
                      onClear: () => setState(() => _expirationDate = null),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _periodAfterOpeningController,
                      label: 'Duración después de abrir',
                      prefixIcon: Icons.timer,
                      hint: 'Ej: 6 meses, 12M (dejar vacío para eliminar)',
                    ),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      icon: Icons.open_in_new,
                      iconColor: Colors.black54,
                      text: _openedDate != null
                          ? 'Abierto el: ${_formatDate(_openedDate!)}'
                          : 'Añadir fecha de apertura',
                      isActive: _openedDate != null,
                      onTap: () => _selectDate(
                        initialDate: _openedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365 * 2),
                        ),
                        lastDate: DateTime.now(),
                        onDateSelected: (date) => _openedDate = date,
                      ),
                      onClear: () => setState(() => _openedDate = null),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoriesSection(),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _notesController,
                      label: 'Notas adicionales',
                      prefixIcon: Icons.note,
                      hint:
                          'Añade información adicional (dejar vacío para eliminar)',
                      keyboardType: TextInputType.multiline,
                    ),
                    // En el build del diálogo, después de los campos
                    ElevatedButton(
                      onPressed: () {
                        print('🔴 VALORES ACTUALES EN EL DIÁLOGO:');
                        print('  notes controller: "${_notesController.text}"');
                        print('  brand controller: "${_brandController.text}"');
                        print(
                          '  period controller: "${_periodAfterOpeningController.text}"',
                        );
                        print('  rating: $_rating');
                        print('  categories: $_categories');
                      },
                      child: Text('DEBUG - Ver valores actuales'),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUCCIÓN DE UI (Extract Widgets) ---

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 12),
          Text(
            'Editar producto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: TextFormField(
        controller: _barcodeController,
        decoration: InputDecoration(
          labelText: 'Código de barras',
          prefixIcon: const Icon(Icons.qr_code),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildRatingSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calificación',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (_rating != null)
                TextButton(
                  onPressed: () => setState(() => _rating = null),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Limpiar',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < (_rating ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              if (_rating != null)
                Text('$_rating/5', style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  // Componente reutilizable para Fechas (Apertura y Caducidad)
  Widget _buildDateSelector({
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive
                      ? theme.textTheme.bodyMedium?.color
                      : (isDarkMode ? Colors.grey[600] : Colors.grey[500]),
                ),
              ),
            ),
            if (isActive)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Eliminar fecha',
              ),
            Icon(
              Icons.calendar_today,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (_categories.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _categories.clear()),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Eliminar todas',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories
                .map(
                  (cat) => Chip(
                    label: Text(cat),
                    backgroundColor: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    onDeleted: () => setState(() => _categories.remove(cat)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _newCategoryController,
                  label: '',
                  prefixIcon: Icons.category,
                  hint: 'Nueva categoría',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                onPressed: _addCategory,
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancelar',
              onPressed: () => Navigator.pop(context),
              type: ButtonType.secondary,
              size: ButtonSize.full,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Guardar cambios',
              onPressed: _saveProduct,
              type: ButtonType.primary,
              size: ButtonSize.full,
              icon: Icons.save,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
