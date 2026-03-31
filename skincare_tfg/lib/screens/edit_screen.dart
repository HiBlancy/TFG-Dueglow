// lib/screens/edit_screen.dart
import 'package:flutter/material.dart';
import 'package:skincare_tfg/widgets/custom_button.dart';
import 'package:skincare_tfg/widgets/custom_text_field.dart';
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
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  setState(() => _isLoading = true);
  
  final name = await _authService.getUserName();
  final phone = await _authService.getUserPhone();
  final birthDate = await _authService.getUserBirthDate();
  final userId = await _authService.getUserId();
  final token = await _authService.getToken(); // Add this
  
  print('🔑 Token: ${token?.substring(0, 20)}...'); // Print first 20 chars of token
  print('👤 User ID from SharedPreferences: $userId');
  
  if (mounted) {
    _nameController = TextEditingController(text: name ?? '');
    _phoneController = TextEditingController(text: phone ?? '');
    _birthDateController = TextEditingController(text: birthDate ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _userId = userId ?? '';
    
    print('📝 Will update user with ID: $_userId');
    
    setState(() => _isLoading = false);
  }
}

  Future<void> _saveChanges() async {
    print('🔍 Iniciando guardado...');
  print('📝 Nombre: ${_nameController.text}');
  print('📞 Teléfono: ${_phoneController.text}');
  print('📅 Fecha: ${_birthDateController.text}');
  print('🔑 Contraseña: ${_passwordController.text.isNotEmpty ? "***" : "vacía"}');
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    // Validar que las contraseñas coincidan si se ingresó una
    if (_passwordController.text.isNotEmpty && 
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      setState(() => _isSaving = false);
      return;
    }

    
    String? formattedBirthDate;
  if (_birthDateController.text.isNotEmpty) {
    formattedBirthDate = _convertToISODate(_birthDateController.text);
  }
  
  final result = await _authService.updateUser(
    userId: _userId,
    name: _nameController.text.isNotEmpty ? _nameController.text : null,
    phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
    birthDate: formattedBirthDate, // Enviar en formato ISO
    password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
  );
    
    setState(() => _isSaving = false);
    
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el perfil')),
      );
    }
    
  }
  

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateController.text.isNotEmpty 
          ? _parseDate(_birthDateController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
    return CustomAppBar(
      title: 'Editar Perfil',
      showDrawer: true,
      showBackButton: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 10),
                  _buildProfileAvatar(),
                  const SizedBox(height: 24),
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
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Cambiar contraseña (opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, size: 70, color: Colors.white),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: Cambiar foto de perfil')),
                  );
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
    _saveChanges,  // Siempre pasa la función
    //enabled: !_isSaving,  // Deshabilita el botón mientras guarda
    size: ButtonSize.full,
    icon: Icons.save,
  );
}

  String _convertToISODate(String dateStr) {
  try {
    final parts = dateStr.split('/');
    // parts[0] = día, parts[1] = mes, parts[2] = año
    final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    return date.toIso8601String();
  } catch (e) {
    return dateStr; // Si falla, devolver el original
  }
}
}