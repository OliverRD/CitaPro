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
      if (userUuid == null)
        throw Exception('No se obtuvo el UUID del usuario.');

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
    required String cedula,
    required String email,
    required String password,
    required String cellphone,
  }) async {
    try {
      print('=== Iniciando registro: $email ===');

      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user != null) {
        final nameParts = name.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : name;
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        final passwordhash = Crypt.sha256(password).toString();

        await _supabaseClient.from('usuarios').insert({
          'nombreUser': firstName,
          'apellidoUser': lastName,
          'correoUser': email,
          'password_hash': passwordhash,
          'auth_id': response.user!.id,
          'cedula': cedula,
          'id_rol': 1,
          'activo': true,
        });

        print('Usuario registrado con éxito en la base de datos');
      }
    } on AuthException catch (e) {
      print('Error Auth Registro: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error DB Registro: $e');
      throw Exception('Error en base de datos: $e');
    }
  }
}
