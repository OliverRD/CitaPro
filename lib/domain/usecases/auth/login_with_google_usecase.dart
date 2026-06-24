import '../../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<Map<String, dynamic>?> call() async {
    return await repository.signInWithGoogle();
  }
}