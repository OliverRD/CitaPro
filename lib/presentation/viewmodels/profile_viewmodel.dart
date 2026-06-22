import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;
  
  // Bandera nativa para saber si el ViewModel fue destruido
  bool _isDisposed = false;

  String get userName => _userName;
  String get userEmail => _userEmail;
<<<<<<< HEAD

  String? _userPhotoUrl;
  String? get userPhotoUrl => _userPhotoUrl;

  ProfileViewModel() {
    loadUserData();
  }
=======
  bool get isLoading => _isLoading;
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83

  Future<void> loadUserData() async {
    try {
      if (_isDisposed) return;

      final user = _supabaseClient.auth.currentUser;
<<<<<<< HEAD
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
=======

      // Intentamos cargar de los metadatos de Google primero por seguridad
      if (user != null) {
        _userName = user.userMetadata?['full_name'] ?? 'Usuario de Google';
        _userEmail = user.email ?? '';
      } else {
        _userName = 'Usuario';
        _userEmail = '';
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83
      }

    } catch (e) {
      print('Error al cargar datos de usuario: $e');
      _userName = 'Error al cargar';
    } finally {
      // SOLO si el componente sigue vivo, cambiamos el estado y notificamos
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
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
<<<<<<< HEAD
}
=======

  @override
  void dispose() {
    _isDisposed = true; // Marcamos como destruido antes de llamar al super
    super.dispose();
  }
}
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83
