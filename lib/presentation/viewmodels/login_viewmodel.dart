import 'package:flutter/material.dart';
import '../../domain/usecases/auth/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginViewModel(this._loginUseCase);

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  String get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _loginUseCase.call(email: email, password: password);
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

  // MÉTODO COMPLETO PARA GOOGLE SIGN IN
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _loginUseCase.executeGoogleLogin();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}