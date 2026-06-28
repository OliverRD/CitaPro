import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  bool _isLoading = false;
  String _userName = 'Cargando...';
  String _userEmail = '';
  String _userPhone = '';

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  String? _userPhotoUrl;
  String? get userPhotoUrl => _userPhotoUrl;

  ProfileViewModel() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        _userEmail = user.email ?? '';

        // Obtiene los datos del usuario desde la tabla de usuarios
        final data = await _supabaseClient
            .from('usuarios')
            .select('nombreUser')
            .eq('auth_id', user.id)
            .maybeSingle();

        if (data != null) {
          _userName = (data['nombreUser'] ?? '').toString().trim();
        } else {
          _userName = user.userMetadata?['full_name'] ?? 'Usuario';
        }
      }
    } catch (e) {
      _userName = 'Error al cargar';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para subir la foto de perfil del usuario
  Future<void> subirFotoUsuario(File archivoImagen) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception("No hay ningún usuario autenticado.");
      final String userId = user.id;

      final String nombreArchivo = 'avatar_$userId.png';

      await _supabaseClient.storage
          .from('usuarios')
          .upload(
            nombreArchivo,
            archivoImagen,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String urlPublica = _supabaseClient.storage
          .from('usuarios')
          .getPublicUrl(nombreArchivo);

      await _supabaseClient
          .from('usuarios')
          .update({'foto': urlPublica})
          .eq('auth_id', userId);

      _userPhotoUrl = urlPublica;
    } catch (e) {
      debugPrint('Error al subir la foto de perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}
