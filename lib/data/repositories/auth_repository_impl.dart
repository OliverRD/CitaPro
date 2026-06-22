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
<<<<<<< HEAD

=======
      
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83
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
<<<<<<< HEAD
      print('=== Iniciando registro: $email ===');

=======
      print('=== Iniciando registro sincronizado ===');
      
      // 1. Registro en Auth (El Trigger creará la fila en 'usuarios' automáticamente)
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

<<<<<<< HEAD
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
=======
      final user = response.user;
      
      if (user == null) {
        throw Exception('No se pudo crear el usuario en Auth.');
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83
      }

      // 2. Hash de contraseña
      final passwordhash = Crypt.sha256(password).toString();
      
      // 3. ACTUALIZAR (Ya no hacemos insert)
      // Buscamos la fila que el Trigger acaba de crear y actualizamos los datos extra
      await _supabaseClient.from('usuarios').update({
        'nombreUser': name,
        'password_hash': passwordhash,
        'cedula': cedula,
        'id_rol': 2,
        'activo': true,
      }).eq('auth_id', user.id); 

      print('Registro y actualización exitosos');
      
    } catch (e) {
      print('=== ERROR EN REGISTRO: $e ===');
      rethrow; 
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      print('=== [Repository] Iniciando OAuth Google Externo ===');
      
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.citapro://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication, 
        queryParams: {
          'prompt': 'select_account',
        },
      );
    } catch (e) {
      print('=== [Repository] Error en flujo Google: $e ===');
      rethrow;
    }
  }
}
