// lib/screens/edit_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/main_toolbar.dart';
import '../services/auth_service.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final name = await _authService.getUserName();
      final phone = await _authService.getUserPhone();
      final birthDate = await _authService.getUserBirthDate();
      
      String formattedBirthDate = '';
      if (birthDate != null && birthDate.isNotEmpty) {
        formattedBirthDate = _formatDateForDisplay(birthDate);
      }
      
      if (mounted) {
        _nameController = TextEditingController(text: name ?? '');
        _phoneController = TextEditingController(text: phone ?? '');
        _birthDateController = TextEditingController(text: formattedBirthDate);
        _passwordController = TextEditingController();
        _confirmPasswordController = TextEditingController();
        
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDateForDisplay(String dateStr) {
    if (dateStr.contains('/')) return dateStr;
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text.isNotEmpty && 
        _passwordController.text != _confirmPasswordController.text) {
      _showCustomSnackBar('Las contraseñas no coinciden', isError: true);
      return;
    }
    
    setState(() => _isSaving = true);
    
    String? formattedBirthDate;
    if (_birthDateController.text.isNotEmpty) {
      formattedBirthDate = _convertToISODate(_birthDateController.text);
    }
    
    final result = await _authService.updateUser(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      birthDate: formattedBirthDate,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );
    
    setState(() => _isSaving = false);
    
    if (result != null && mounted) {
      _showCustomSnackBar('Perfil actualizado correctamente');
      Navigator.pop(context, true);
    } else if (mounted) {
      _showCustomSnackBar('Error al actualizar el perfil', isError: true);
    }
  }
  
  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    
    if (_birthDateController.text.isNotEmpty) {
      try {
        if (_birthDateController.text.contains('/')) {
          final parts = _birthDateController.text.split('/');
          initialDate = DateTime(
            int.parse(parts[2]), 
            int.parse(parts[1]), 
            int.parse(parts[0])
          );
        } else {
          initialDate = DateTime.parse(_birthDateController.text);
        }
      } catch (e) {
        initialDate = DateTime.now();
      }
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    
    if (picked != null) {
      setState(() {
        _birthDateController.text = _formatDateForUI(picked);
      });
    }
  }

  String _formatDateForUI(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _convertToISODate(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        final date = DateTime(
          int.parse(parts[2]), 
          int.parse(parts[1]), 
          int.parse(parts[0])
        );
        return date.toIso8601String().split('T')[0];
      }
      return dateStr;
    } catch (e) {
      print('❌ Error parsing date: $e');
      return dateStr;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomAppBar(
      title: 'Editar Perfil',
      showDrawer: true,
      showBackButton: true,
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 10),
                  _buildProfileAvatar(theme),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nombre',
                    prefixIcon: Icons.person,
                    hint: 'Tu nombre',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    prefixIcon: Icons.phone,
                    hint: '+34 123 456 789',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        controller: _birthDateController,
                        label: 'Fecha de nacimiento',
                        prefixIcon: Icons.cake,
                        hint: 'DD/MM/AAAA',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'Cambiar contraseña (opcional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Nueva contraseña',
                    prefixIcon: Icons.lock,
                    obscureText: _obscurePassword,
                    showVisibilityToggle: true,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar contraseña',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    showVisibilityToggle: true,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (_passwordController.text.isNotEmpty && value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, size: 70, color: theme.colorScheme.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 3), // Efecto de recorte
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 20, color: theme.colorScheme.onPrimary),
                onPressed: () {
                  _showCustomSnackBar('Próximamente: Cambiar foto de perfil');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return context.primaryButton(
      _isSaving ? 'Guardando...' : 'Guardar Cambios',
      _saveChanges,
      size: ButtonSize.full,
      icon: Icons.save,
    );
  }
}