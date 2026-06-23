import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart'; 
import '../viewmodels/login_viewmodel.dart';
import 'main_navigation_screen.dart'; 
import 'register_screen.dart'; 

class LoginView extends StatefulWidget { 
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _localLoading = false; 
  String _localError = '';    

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final authRepository = Provider.of<AuthRepository>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 1, 8, 65),
                    borderRadius: BorderRadius.circular(17), 
                    border: Border.all(color: Colors.grey, width: 1.5),                  
                  ), 
                  height: 80,
                  width: 80,
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Cita',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      'Pro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Ingresa tus datos para continuar en CitaPro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabel('Correo Electrónico'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'juan@Gmail.com',
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: 20),

                _buildLabel('Contraseña'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: viewModel.obscurePassword,
                  onSuffixTap: viewModel.togglePasswordVisibility,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.rememberMe,
                          onChanged: viewModel.toggleRememberMe,
                          activeColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Mantener sesión\niniciada',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Olvidaste tu\ncontraseña?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_localError.isNotEmpty) ...[
                  Text(
                    _localError,
                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF6D28D9),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _localLoading
                        ? null
                        : () async {
                            setState(() {
                              _localLoading = true;
                              _localError = '';
                            });

                            try {
                              final userData = await authRepository.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );

                              if (mounted) {
                                print('Sesión iniciada para: ${userData['nombreUser']} con Rol ID: ${userData['id_rol']}');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('¡Bienvenido, ${userData['nombreUser']}!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _localError = e.toString().replaceAll('Exception: ', '');
                              });
                            } finally {
                              if (mounted) {
                                setState(() => _localLoading = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _localLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'O continúa con',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 24),

                // Botones de Google y Apple
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        context: context, // <-- SE CORRIGIÓ: Pasamos el context actual
                        label: 'Google',
                        iconPath: 'assets/google_logo.png',
                        isGoogle: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSocialButton(
                        context: context, // <-- SE CORRIGIÓ: Pasamos el context actual
                        label: 'Apple',
                        icon: Icons.apple,
                        isGoogle: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Regístrate ahora',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF64748B),
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context, // <-- SE CORRIGIÓ: Parámetro explícito de contexto
    required String label,
    IconData? icon,
    String? iconPath,
    required bool isGoogle,
  }) {
    return OutlinedButton(
      onPressed: isGoogle
          ? () async {
              final viewModel = Provider.of<LoginViewModel>(context, listen: false);
              await viewModel.signInWithGoogle();
            }
          : () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGoogle
              ? const Icon(Icons.g_mobiledata, color: Colors.red, size: 26)
              : Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}