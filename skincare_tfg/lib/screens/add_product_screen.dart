import 'package:dueglow/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../models/beauty_product.dart';
import '../services/product_service.dart';
import '../widgets/main_toolbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _paoController = TextEditingController();
  final _notesController = TextEditingController();
  final _newCategoryController = TextEditingController();

  DateTime? _expirationDate;
  DateTime? _openedDate;
  final List<String> _categories = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _paoController.dispose();
    _notesController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NEGOCIO (Igual que antes) ---
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
    final newCat = _newCategoryController.text.trim();
    if (newCat.isNotEmpty && !_categories.contains(newCat)) {
      setState(() {
        _categories.add(newCat);
        _newCategoryController.clear();
      });
    }
  }

  Future<void> _saveProductManually() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final newProduct = BeautyProduct(
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        categories: _categories.isEmpty ? null : _categories,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        periodAfterOpening: _paoController.text.trim().isEmpty ? null : _paoController.text.trim(),
        expirationDate: _expirationDate,
        openedDate: _openedDate,
        listType: 'have', 
        addedAt: DateTime.now(),
        isOpened: _openedDate != null,
      );
      final addedProduct = await _productService.addProductToHave(newProduct);
      if (mounted) {
        setState(() => _isLoading = false);
        if (addedProduct != null) {
          _showSnackBar('✓ Producto añadido correctamente');
          _clearForm();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear(); _brandController.clear(); _barcodeController.clear();
      _paoController.clear(); _notesController.clear(); _newCategoryController.clear();
      _expirationDate = null; _openedDate = null; _categories.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- DISEÑO ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrincipal = theme.colorScheme.primaryContainer;

    return CustomAppBar(
      title: 'Añadir Producto',
      showDrawer: true,
      showBackButton: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. TÍTULO Y DESCRIPCIÓN CENTRADA
            Center(
              child: Column(
                children: [
                  Text(
                    '¿Nuevo producto?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escanea o rellena los datos abajo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 2. ACCIONES RÁPIDAS (Estilo Esencia con opacidad)
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Escanear',
                    subtitle: 'Código de barras',
                    color: colorPrincipal.withValues(alpha: 0.4),
                    onTap: () => Navigator.pushNamed(context, AppConstants.routeScan), 
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.search,
                    title: 'Buscar',
                    subtitle: 'Base de datos',
                    color: colorPrincipal.withValues(alpha: 0.2),
                    onTap: () => Navigator.pushNamed(context, '/search'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Divisor sutil
            Row(
              children: [
                Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('DATOS MANUALES', style: TextStyle(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
              ],
            ),
            
            const SizedBox(height: 32),

            // 3. FORMULARIO EN TARJETA NEUTRA
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nombre *',
                      prefixIcon: Icons.spa_outlined,
                      hint: 'Ej: Crema Hidratante',
                      validator: (v) => v?.trim().isEmpty == true ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _brandController,
                      label: 'Marca',
                      prefixIcon: Icons.branding_watermark_outlined,
                      hint: 'Ej: Nivea',
                    ),
                    const SizedBox(height: 20),
                    _buildDateSelector(
                      icon: Icons.calendar_today_outlined,
                      text: _expirationDate != null
                          ? 'Caduca: ${_formatDate(_expirationDate!)}'
                          : 'Fecha de caducidad',
                      isActive: _expirationDate != null,
                      onTap: () => _selectDate(
                        initialDate: _expirationDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        onDateSelected: (date) => setState(() => _expirationDate = date),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _paoController,
                      label: 'Duración tras abrir (PAO)',
                      prefixIcon: Icons.timer,
                      hint: 'Ej: 6 meses, 12M',
                    ),
                    const SizedBox(height: 20),
                    _buildCategoriesSection(theme),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Guardar en mi tocador',
                      onPressed: _saveProductManually,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                      size: ButtonSize.full,
                      icon: Icons.add_task_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required IconData icon,
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.outline))),
            Icon(Icons.edit_calendar_outlined, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _newCategoryController,
                label: 'Categoría',
                prefixIcon: Icons.category_outlined,
                hint: 'Ej: Facial',
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addCategory,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer, foregroundColor: theme.colorScheme.primary),
            ),
          ],
        ),
        if (_categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) => Chip(
              label: Text(cat, style: const TextStyle(fontSize: 11)),
              onDeleted: () => setState(() => _categories.remove(cat)),
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            )).toList(),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}