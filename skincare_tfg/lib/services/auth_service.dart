import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  
  // Credenciales válidas (después las conectarás a BD)
  static const String _validEmail = 'usuario@ejemplo.com';
  static const String _validPassword = '123456';
  
  // Simulación de base de datos de usuarios registrados
  // En una app real, esto estaría en una base de datos
  static Map<String, Map<String, String>> _users = {
    'usuario@ejemplo.com': {
      'password': '123456',
      'name': 'Usuario Demo',
    },
  };
  
  // Guardar sesión
  Future<void> saveSession(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
    await prefs.setBool(_keyIsLoggedIn, true);
  }
  
  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
  
  // Obtener email del usuario logueado
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }
  
  // Obtener nombre del usuario logueado
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }
  
  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    print('Intentando login con: $email');
    
    // Verificar si el usuario existe y la contraseña es correcta
    final user = _users[email];
    if (user != null && user['password'] == password) {
      await saveSession(email, user['name'] ?? email.split('@')[0]);
      return true;
    }
    return false;
  }
  
  // Registrar nuevo usuario
  Future<bool> register(String email, String password, String name) async {
    print('Intentando registrar: $email');
    
    // Verificar si el usuario ya existe
    if (_users.containsKey(email)) {
      return false; // Usuario ya existe
    }
    
    // Registrar nuevo usuario
    _users[email] = {
      'password': password,
      'name': name,
    };
    
    print('Usuario registrado exitosamente. Usuarios totales: ${_users.length}');
    print('Usuarios registrados: ${_users.keys.toList()}');
    
    return true;
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
  
  // Método para debugging - obtener todos los usuarios
  List<String> getAllUsers() {
    return _users.keys.toList();
  }
}