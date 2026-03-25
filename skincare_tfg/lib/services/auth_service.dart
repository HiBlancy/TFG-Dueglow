import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthService {
  // Credenciales válidas (después las conectarás a BD)
  static const String _validEmail = 'usuario@ejemplo.com';
  static const String _validPassword = '123456';
  
  // Simulación de base de datos
  static final Map<String, Map<String, String>> _users = {
    'usuario@ejemplo.com': {
      'password': '123456',
      'name': 'Usuario Demo',
    },
  };
  
  // Getters para SharedPreferences
  Future<SharedPreferences> get _prefs async => 
      await SharedPreferences.getInstance();
  
  // Guardar sesión
  Future<void> saveSession(String email, String name) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.prefUserEmail, email);
    await prefs.setString(AppConstants.prefUserName, name);
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
  }
  
  // Verificar sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }
  
  // Obtener datos del usuario
  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefUserEmail);
  }
  
  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefUserName);
  }
  
  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    final user = _users[email];
    if (user != null && user['password'] == password) {
      await saveSession(email, user['name'] ?? email.split('@').first);
      return true;
    }
    return false;
  }
  
  // Registrar nuevo usuario
  Future<bool> register(String email, String password, String name) async {
    if (_users.containsKey(email)) return false;
    
    _users[email] = {'password': password, 'name': name};
    return true;
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.prefUserEmail);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.setBool(AppConstants.prefIsLoggedIn, false);
  }
}