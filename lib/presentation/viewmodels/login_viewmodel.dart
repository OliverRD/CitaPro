import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/login_with_google_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  LoginViewModel(this._loginUseCase, this._loginWithGoogleUseCase) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        print("Sesión detectada automáticamente: ${session.user.email}");
        notifyListeners();
      }
    });
  }

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

  Future<bool> login(String email, String password) async {

    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _loginUseCase.call(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      
      final errorString = e.toString();
      
      if (errorString.contains('Email not confirmed')) {
        _errorMessage = 'Por favor, revisa tu correo electrónico y confirma tu cuenta antes de iniciar sesión.';
      } else if (errorString.contains('User already registered')) {
        _errorMessage = 'Este correo ya está registrado. Intenta iniciar sesión en lugar de registrarte.';
      } else {
        _errorMessage = errorString.replaceAll('Exception: ', '');
      }
      
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final Map<String, dynamic>? user = await _loginWithGoogleUseCase.call();
      _isLoading = false;

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true; 
      } else {
        _errorMessage = 'El inicio de sesión fue cancelado.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}