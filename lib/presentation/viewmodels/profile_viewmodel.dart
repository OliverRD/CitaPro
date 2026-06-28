import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isLoading = false;
  String _userName = 'Cargando...';
  String _userEmail = '';
  String _userPhone = '';
  String? _userPhotoUrl;
  String _errorMessage = '';

  // Getters públicos
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String? get userPhotoUrl => _userPhotoUrl;
  String get errorMessage => _errorMessage;

  ProfileViewModel() {
    // Escucha de forma activa los cambios de sesión globales (Login / Logout)
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((
      data,
    ) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        // Si hay una nueva sesión activa, cargamos los datos del usuario correspondiente
        await loadUserData();
      } else if (event == AuthChangeEvent.signedOut) {
        // 🔥 Si se cierra la sesión, limpiamos el estado por completo inmediatamente
        _clearUserData();
      }
    });
  }

  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        _userEmail = user.email ?? '';

        final data = await _supabaseClient
            .from('usuarios')
            .select('*')
            .eq('auth_id', user.id)
            .maybeSingle();

        if (data != null) {
          _userName =
              (data['nombreUser'] ??
                      user.userMetadata?['full_name'] ??
                      'Usuario')
                  .toString()
                  .trim();
          _userPhone = (data['telefono'] ?? '').toString().trim();

          if (data['foto'] != null &&
              data['foto'].toString().isNotEmpty &&
              data['foto'] != 'NULL') {
            _userPhotoUrl = data['foto'].toString();
          } else {
            _userPhotoUrl = null;
          }
        } else {
          _userName = user.userMetadata?['full_name'] ?? 'Usuario';
          _userPhone = '';
          _userPhotoUrl = null;
        }
      } else {
        _clearUserData();
      }
    } catch (e) {
      _userName = 'Error al cargar';
      _errorMessage = e.toString();
      debugPrint('--- ❌ ERROR EN PROFILE_VIEWMODEL: $e');
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  void _clearUserData() {
    _userName = 'Cargando...';
    _userEmail = '';
    _userPhone = '';
    _userPhotoUrl = null;
    _errorMessage = '';
    if (hasListeners) notifyListeners();
  }

  Future<void> subirFotoUsuario(File archivoImagen) async {
    try {
      _isLoading = true;
      _errorMessage = '';
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
            fileOptions: const FileOptions(cacheControl: '0', upsert: true),
          );

      final String urlPublica = _supabaseClient.storage
          .from('usuarios')
          .getPublicUrl(nombreArchivo);
      final String urlConCacheBuster =
          '$urlPublica?v=${DateTime.now().millisecondsSinceEpoch}';

      await _supabaseClient
          .from('usuarios')
          .update({'foto': urlConCacheBuster})
          .eq('auth_id', userId);

      _userPhotoUrl = urlConCacheBuster;
    } catch (e) {
      debugPrint('Error al subir la foto de perfil: $e');
      _errorMessage = 'No se pudo actualizar la foto de perfil.';
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  void dispose() {
    // Cancelamos la suscripción al destruir el ViewModel para evitar fugas de memoria
    _authSubscription?.cancel();
    super.dispose();
  }
}
