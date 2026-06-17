import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  bool _isLoading = false;
  String _userName = 'Cargando...';
  String _userEmail = '';

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;

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
            .select('nombreUser, apellidoUser')
            .eq('auth_id', user.id)
            .maybeSingle();

        if (data != null) {
          _userName = '${data['nombreUser']} ${data['apellidoUser']}'.trim();
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

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}