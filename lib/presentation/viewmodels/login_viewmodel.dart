import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/auth/login_with_google_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  // 🔥 CORRECCIÓN 1: Guardar el caso de uso de Google como variable de clase
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  LoginViewModel(
    this._loginUseCase,
    this._loginWithGoogleUseCase, // Asignación correcta en constructor
  );

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;

  // Getters públicos
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
    notifyListeners();
  }

  // LOGIN TRADICIONAL
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    _currentUser = null; // Limpiamos usuario previo
    notifyListeners();

    try {
      // 🔥 CORRECCIÓN 2: El UseCase debe retornar el mapa/modelo del usuario autenticado
      final userResult = await _loginUseCase.call(
        email: email,
        password: password,
      );

      _currentUser =
          userResult; // Ahora la vista sí podrá leer el id_rol y nombreUser
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🔥 CORRECCIÓN 3: Implementación real del login con Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = '';
    _currentUser = null;
    notifyListeners();

    try {
      // Llama a tu caso de uso de Google (debe retornar también el mapa de usuario de Supabase)
      final userResult = await _loginWithGoogleUseCase.call();

      _currentUser = userResult;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
