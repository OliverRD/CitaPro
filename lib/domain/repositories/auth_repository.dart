
abstract class AuthRepository {
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String name,
    required String cedula,
    required String email,
    required String password,
    required String cellphone,
  });
<<<<<<< HEAD
}
=======

  // === AGREGAMOS ESTA LÍNEA PARA EL INICIO DE SESIÓN CON GOOGLE ===
  Future<void> signInWithGoogle();
}
>>>>>>> b57d11898422f73e9bfb75eea34b5e0b68f53f83
