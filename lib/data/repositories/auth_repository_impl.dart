import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypt/crypt.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('=== Intentando login: $email ===');

      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      final userUuid = response.user?.id;
      if (userUuid == null) {
        throw Exception('No se obtuvo el UUID del usuario.');
      }

      final List<Map<String, dynamic>> data = await _supabaseClient
          .from('usuarios')
          .select()
          .eq('auth_id', userUuid);

      if (data.isEmpty) {
        throw Exception('Perfil de usuario no encontrado.');
      }

      return data.first;
    } on AuthException catch (e) {
      print('Error Auth Login: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error Inesperado Login: $e');
      throw Exception('Ocurrió un error inesperado al iniciar sesión.');
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String cellphone,
  }) async {
    try {
      print('=== 1. Iniciando registro en Supabase Auth ===');

      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombreUser': name.trim(),
          'telefonoUser': cellphone,
          'id_rol': 1,
          'activo': true,
        },
      );

      if (response.user != null) {
        print(
          '=== 2. ¡ÉXITO! Auth creó el usuario y el Trigger llenó la tabla usuarios ===',
        );
      }
    } on AuthException catch (e) {
      print('Error Auth Registro: { code: ${e.code}, message: ${e.message} }');
      throw Exception(e.message);
    } catch (e) {
      print('Error General Registro: $e');
      throw Exception('Error inesperado: $e');
    }
  }
}
