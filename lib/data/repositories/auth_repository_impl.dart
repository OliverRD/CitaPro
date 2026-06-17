import 'package:supabase_flutter/supabase_flutter.dart';
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
      print(' [Supabase Login] Intentando iniciar sesión para: $email');

      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userUuid = response.user?.id;
      if (userUuid == null) throw Exception('No se pudo obtener el ID único del usuario.');

      print('[Supabase Login] Auth exitoso en la nube. Buscando perfil de usuario...');

      final List<Map<String, dynamic>> data = await _supabaseClient
          .from('usuarios')
          .select()
          .eq('auth_id', userUuid); 

      if (data.isEmpty) {
        throw Exception('El usuario está autenticado, pero no se encontró su perfil en la base de datos.');
      }

      print('[Supabase Login] Perfil extraído con éxito: ${data.first}');
      
      return data.first;

    } on AuthException catch (e) {
      print('[Supabase Auth Login Error]: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('[Supabase Unexpected Login Error]: ${e.toString()}');
      throw Exception('Ocurrió un error inesperado al iniciar sesión.');
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String cedula,
    required String email,
    required String password,
  }) async {
    try {
      print('[Supabase Registro] Iniciando registro para: $email');
      
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name}, 
      );

      print('[Supabase Registro] Auth exitoso. ID generado: ${response.user?.id}');

      if (response.user != null) {
        final nameParts = name.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : name;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        print('[Supabase Registro] Intentando insertar en tabla usuarios...');
        
        await _supabaseClient.from('usuarios').insert({
          'nombreUser': firstName,
          'apellidoUser': lastName,
          'correoUser': email,
          'auth_id': response.user!.id, 
          'cedula': cedula,
          'id_rol': 2,                  
          'activo': true,
        });

        print('[Supabase Registro] ¡Usuario insertado con éxito en la tabla!');
      }
    } on AuthException catch (e) {
      print('[Supabase Auth Registro Error]: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('[Supabase Database Registro Error]: ${e.toString()}');
      throw Exception('Error en base de datos: ${e.toString()}');
    }
  }
}