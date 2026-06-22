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
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    try {
      if (_isDisposed) return;

      final user = _supabaseClient.auth.currentUser;

      // Intentamos cargar de los metadatos de Google primero por seguridad
      if (user != null) {
        _userName = user.userMetadata?['full_name'] ?? 'Usuario de Google';
        _userEmail = user.email ?? '';
      } else {
        _userName = 'Usuario';
        _userEmail = '';
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

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  void dispose() {
    _isDisposed = true; // Marcamos como destruido antes de llamar al super
    super.dispose();
  }
}