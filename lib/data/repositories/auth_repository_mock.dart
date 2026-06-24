import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryMock implements AuthRepository {
  @override
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (email == 'test@citapro.com' && password == '123456') {
      return {
        'nombreUser': 'Usuario',
        'apellidoUser': 'Prueba',
        'correoUser': email,
        'auth_id': 'mock-uuid-123',
        'id_rol': 2,
      };
    } else {
      throw Exception('Correo electrónico o contraseña incorrectos.');
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
    await Future.delayed(const Duration(milliseconds: 1500));

    if (email.contains('error')) {
      throw Exception('Este correo ya está registrado.');
    }
    return; // Éxito
  }

  // === MÉTODO SIMULADO PARA GOOGLE (MOCK) ===
  @override
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    print('=== Simulando Auth con Google (Mock activo) ===');
    
    // Simula el tiempo que tarda el usuario seleccionando su cuenta de Google
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Retorna una estructura idéntica a la que espera tu base de datos de Supabase
    return {
      'nombreUser': 'Carlos',
      'apellidoUser': 'Google Mock',
      'correoUser': 'carlos.google.mock@gmail.com',
      'auth_id': 'mock-google-uuid-999',
      'id_rol': 1,
      'activo': true,
    };
  }
}