import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
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
    required String cedula,
    required String email,
    required String password,
    required String cellphone,
  }) async {
    try {
      print('=== Iniciando registro Auth: $email ===');

      // 1. Registro puro en Auth.
      // Se envían los metadatos necesarios dentro de 'data'. 
      // El Trigger en tu panel de Supabase se encargará de interceptar esta creación 
      // y generar la fila correspondiente en la tabla 'usuarios' de forma segura y única.
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'cedula': cedula,     
          'cellphone': cellphone,
        },
      );
      
      print('Usuario registrado en Auth de forma limpia. El Trigger gestiona la tabla usuarios.');
      
    } on AuthException catch (e) {
      print('Error Auth Registro: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error Inesperado Registro: $e');
      throw Exception('Error al registrar usuario.');
    }
  }

  @override
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('=== Iniciando Auth con Google en Supabase ===');

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut(); 

      final bool iniciado = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.citapro://login-callback/',
      );

      if (!iniciado) return null;

      // 🔥 IMPORTANTE: Damos un pequeño margen de tiempo (1.5 segundos) 
      // para que el Trigger asíncrono en la nube termine de estructurar el perfil.
      await Future.delayed(const Duration(milliseconds: 1500));

      final User? user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final List<Map<String, dynamic>> data = await _supabaseClient
          .from('usuarios')
          .select()
          .eq('auth_id', user.id);

      // Si el Trigger procesó la entrada de Google con éxito, retornamos el perfil obtenido.
      if (data.isNotEmpty) {
        return data.first;
      }

      return null;
    } on AuthException catch (e) {
      print('Error Auth Google: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error inesperado en Google Sign In: $e');
      throw Exception('Ocurrió un error inesperado al conectar con Google.');
    }
  }
}