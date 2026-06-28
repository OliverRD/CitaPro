import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/auth/login_with_google_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginViewModel(
    this._loginUseCase,
    LoginWithGoogleUseCase loginWithGoogleUseCase,
  );

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _errorMessage = '';

  Map<String, dynamic>? _currentUser;

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

  Future<Object?> loginWithGoogle() async {}
}
