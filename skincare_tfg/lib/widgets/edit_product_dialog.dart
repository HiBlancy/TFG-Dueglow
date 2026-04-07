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

    // Leer valores actuales
    final currentName = _nameController.text.trim();
    final currentBrand = _brandController.text.trim();
    final currentNotes = _notesController.text.trim();
    final currentPeriod = _periodAfterOpeningController.text.trim();

    print('🔍 CONSTRUYENDO PRODUCTO:');
    print('  - notes actual: "$currentNotes"');
    print('  - notes será: ${currentNotes.isEmpty ? "null" : currentNotes}');
    print('  - brand actual: "$currentBrand"');
    print('  - brand será: ${currentBrand.isEmpty ? "null" : currentBrand}');
    print('  - categories actual: $_categories');
    print('  - categories será: ${_categories.isEmpty ? "null" : _categories}');

    // ✅ Construir el producto (ahora acepta nulls)
    final updatedProduct = BeautyProduct(
      id: widget.product.id,
      barcode: widget.product.barcode,
      name: currentName,
      brand: currentBrand.isEmpty ? null : currentBrand, // ✅ Ahora funciona
      imageUrl: widget.product.imageUrl,
      categories: _categories.isEmpty ? null : _categories, // ✅ Ahora funciona
      notes: currentNotes.isEmpty ? null : currentNotes,
      rating: _rating,
      listType: widget.product.listType,
      expirationDate: _expirationDate,
      periodAfterOpening: currentPeriod.isEmpty ? null : currentPeriod,
      openedDate: _openedDate,
      addedAt: widget.product.addedAt,
      isOpened: widget.product.isOpened,
    );

    print('📦 PRODUCTO FINAL:');
    print('  - notes: ${updatedProduct.notes}');
    print('  - brand: ${updatedProduct.brand}');
    print('  - categories: ${updatedProduct.categories}');
    print('  - rating: ${updatedProduct.rating}');

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
          const SizedBox(width: 12),
          Text(
            'Editar producto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calificación',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (_rating != null)
                TextButton(
                  onPressed: () => setState(() => _rating = null),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(fontSize: 11, color: Colors.red),
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
                Text(
                  '$_rating/5',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: isActive ? Colors.black : Colors.grey),
              ),
            ),
            if (isActive)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Eliminar fecha',
              ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (_categories.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _categories.clear()),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Eliminar todas',
                    style: TextStyle(fontSize: 11, color: Colors.red),
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
                    deleteIcon: const Icon(Icons.close, size: 18),
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
                icon: const Icon(Icons.add_circle),
                onPressed: _addCategory,
                color: Theme.of(context).colorScheme.primary,
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
