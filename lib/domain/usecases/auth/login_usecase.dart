import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  // Tu método actual de login por email
  Future<Map<String, dynamic>> call({required String email, required String password}) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Por favor, ingresa un correo electrónico válido.');
    }
    if (password.isEmpty || password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres.');
    }
    return await repository.signInWithEmailAndPassword(email: email, password: password);
  }

  // --- AÑADE ESTE MÉTODO AQUÍ PARA QUE EL VIEWMODEL DEJE DE DAR ERROR ---
  Future<void> executeGoogleLogin() async {
    return await repository.signInWithGoogle();
  }
}