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

  Future<Map<String, dynamic>?> signInWithGoogle();
}