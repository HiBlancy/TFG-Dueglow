import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import 'api_config.dart';
import 'notification_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  final supabase = Supabase.instance.client;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> saveSession(String token, Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
    await prefs.setString(AppConstants.prefUserEmail, userData['email'] ?? '');
    await prefs.setString(AppConstants.prefUserName, userData['name'] ?? '');
    await prefs.setString(AppConstants.prefUserId, userData['_id'] ?? '');
    await prefs.setString(AppConstants.prefUserPhone, userData['phone'] ?? '');
    await prefs.setString(AppConstants.prefUserBD, userData['birthDate'] ?? '');
    await prefs.setString(
      AppConstants.prefUserProfileImage,
      userData['profileImage'] ?? '',
    );
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);

    print(
      '✅ Sesión guardada - Email: ${userData['email']}, Name: ${userData['name']}',
    );
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  /// Returns the token's expiry date extracted from the JWT `exp` claim.
  /// If the token is not a valid JWT or has no `exp`, returns null.
  DateTime? getTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is! Map<String, dynamic>) return null;

      final exp = json['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  bool isTokenValid(
    String token, {
    Duration clockSkew = const Duration(seconds: 30),
  }) {
    final expiryUtc = getTokenExpiry(token);
    if (expiryUtc == null) return token.isNotEmpty;
    return DateTime.now().toUtc().isBefore(expiryUtc.subtract(clockSkew));
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    final name = prefs.getString(AppConstants.prefUserName);
    return name;
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    final email = prefs.getString(AppConstants.prefUserEmail);
    return email;
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefUserId);
  }

  Future<String?> getUserPhone() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefUserPhone);
  }

  Future<String?> getUserBirthDate() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefUserBD);
  }

  Future<String?> getUserProfileImage() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefUserProfileImage);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey);
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔐 Verificando autenticación: $isLoggedIn');
    return isLoggedIn;
  }

  // Register con Supabase
  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final res = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );
      if (res.user == null) return null;

      final insertResult = await supabase.from('profiles').insert({
        'id': res.user!.id,
        'name': name,
        'email': email.trim(),
      }).select();

      final profile = insertResult.first;
      final userData = {
        '_id': res.user!.id,
        'email': email.trim(),
        'name': name,
        'phone': profile['phone'] ?? '',
        'birthDate': profile['birth_date'] ?? '',
        'profileImage': profile['profile_image'] ?? '',
      };
      final session = supabase.auth.currentSession;
      final token = session?.accessToken ?? '';
      await saveSession(token, userData);

      return {'token': token, 'user': userData};
    } catch (e) {
      print('Error en register: $e');
      return null;
    }
  }

  // Login con Supabase
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.user == null) return null;

      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();

      final userData = {
        '_id': res.user!.id,
        'email': res.user!.email ?? email.trim(),
        'name': profileData?['name'] ?? res.user!.userMetadata?['name'] ?? '',
        'phone': profileData?['phone'] ?? '',
        'birthDate': profileData?['birth_date'] ?? '',
        'profileImage': profileData?['profile_image'] ?? '',
      };
      final session = supabase.auth.currentSession;
      final token = session?.accessToken ?? '';
      await saveSession(token, userData);

      return {'token': token, 'user': userData};
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    try {
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (profileData == null) return null;

      final userData = {
        '_id': session.user.id,
        'email': session.user.email ?? '',
        'name': profileData['name'] ?? '',
        'phone': profileData['phone'] ?? '',
        'birthDate': profileData['birth_date'] ?? '',
        'profileImage': profileData['profile_image'] ?? '',
      };
      await saveSession(session.accessToken, userData);
      return userData;
    } catch (e) {
      print('❌ Error al obtener perfil: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUser({
    String? name,
    String? phone,
    String? birthDate,
    String? password,
    String? profileImage,
  }) async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    try {
      final Map<String, dynamic> updateData = {};
      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (phone != null && phone.isNotEmpty) updateData['phone'] = phone;
      if (birthDate != null && birthDate.isNotEmpty)
        updateData['birth_date'] = birthDate;
      if (profileImage != null && profileImage.isNotEmpty)
        updateData['profile_image'] = profileImage;

      // Actualizar perfil en tabla profiles
      if (updateData.isNotEmpty) {
        await supabase
            .from('profiles')
            .update(updateData)
            .eq('id', session.user.id);
      }

      // Si se proporciona una nueva contraseña, actualizarla en auth
      if (password != null && password.isNotEmpty) {
        await supabase.auth.updateUser(UserAttributes(password: password));
      }

      // Obtener los datos actualizados
      final updatedProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();

      final userData = {
        '_id': session.user.id,
        'email': session.user.email ?? '',
        'name': updatedProfile['name'] ?? '',
        'phone': updatedProfile['phone'] ?? '',
        'birthDate': updatedProfile['birth_date'] ?? '',
        'profileImage': updatedProfile['profile_image'] ?? '',
      };
      await saveSession(session.accessToken, userData);
      return userData;
    } catch (e) {
      print('❌ Error al actualizar usuario: $e');
      return null;
    }
  }

  Future<bool> deleteAccount() async {
  final session = supabase.auth.currentSession;
  if (session == null) return false;

  try {
    // Cambia la URL por la que te proporcionó Supabase al desplegar la Edge Function
    final String functionUrl = 'https://ycbiqgjzcpvvqieffmel.supabase.co/functions/v1/smart-handler';

    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await logout();
      return true;
    } else {
      print('❌ Error al borrar cuenta: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Error al borrar cuenta: $e');
    return false;
  }
}

  Future<Map<String, dynamic>?> uploadProfileImage(File imageFile) async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    try {
      // Generar nombre único
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${session.user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'avatars/$fileName';

      // Subir a Storage
      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Obtener URL pública
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // Actualizar campo profile_image en tabla profiles
      await supabase
          .from('profiles')
          .update({'profile_image': imageUrl})
          .eq('id', session.user.id);

      // Obtener perfil actualizado
      final updatedProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();

      final userData = {
        '_id': session.user.id,
        'email': session.user.email ?? '',
        'name': updatedProfile['name'] ?? '',
        'phone': updatedProfile['phone'] ?? '',
        'birthDate': updatedProfile['birth_date'] ?? '',
        'profileImage': updatedProfile['profile_image'] ?? '',
      };
      await saveSession(session.accessToken, userData);
      return userData;
    } catch (e) {
      print('❌ Error al subir imagen: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> deleteProfileImage() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    try {
      // Obtener la URL actual de la imagen
      final currentProfile = await supabase
          .from('profiles')
          .select('profile_image')
          .eq('id', session.user.id)
          .single();

      final oldImageUrl = currentProfile['profile_image'] as String?;
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        // Extraer el nombre del archivo de la URL pública (asumiendo formato estándar)
        final fileName = oldImageUrl.split('/').last;
        // Eliminar del storage
        await supabase.storage.from('avatars').remove([fileName]);
      }

      // Limpiar el campo profile_image en la tabla
      await supabase
          .from('profiles')
          .update({'profile_image': null})
          .eq('id', session.user.id);

      // Obtener perfil actualizado
      final updatedProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();

      final userData = {
        '_id': session.user.id,
        'email': session.user.email ?? '',
        'name': updatedProfile['name'] ?? '',
        'phone': updatedProfile['phone'] ?? '',
        'birthDate': updatedProfile['birth_date'] ?? '',
        'profileImage': updatedProfile['profile_image'] ?? '',
      };
      await saveSession(session.accessToken, userData);
      return userData;
    } catch (e) {
      print('❌ Error al eliminar imagen: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    await NotificationService.instance.cancelAll();
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(AppConstants.prefUserEmail);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserPhone);
    await prefs.remove(AppConstants.prefUserBD);
    await prefs.remove(AppConstants.prefUserProfileImage);
    await prefs.setBool(AppConstants.prefIsLoggedIn, false);
    print('👋 Sesión cerrada');
  }
}
