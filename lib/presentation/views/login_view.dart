import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>(); 
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

  void _navigateBasedOnRol(int idRol) {
    if (!mounted) return;
    
    setState(() {
      _localLoading = false;
    });

    switch (idRol) {
      case 1:
      case 2:
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
        break;
      default:
        setState(() {
          _localError = 'Rol no autorizado o no asignado en la base de datos (Rol: $idRol)';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    // 🔥 UNIFICACIÓN DE CARGA: Si cualquiera de los dos estados está cargando, bloqueamos la UI
    final bool estaCargando = _localLoading || viewModel.isLoading;

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
            child: Form(
              key: _formKey, 
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
                    enabled: !estaCargando, // Desactiva el input si está cargando
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu correo electrónico';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Contraseña'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    enabled: !estaCargando, // Desactiva el input si está cargando
                    obscureText: viewModel.obscurePassword,
                    onSuffixTap: viewModel.togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: viewModel.rememberMe,
                            onChanged: estaCargando ? null : viewModel.toggleRememberMe,
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
                        onPressed: estaCargando ? null : () {},
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

                  // Mostrar mensajes de error limpios y traducidos
                  if (_localError.isNotEmpty || viewModel.errorMessage.isNotEmpty) ...[
                    Text(
                      _localError.isNotEmpty ? _localError : viewModel.errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // BOTÓN DE INICIAR SESIÓN TRADICIONAL CORREGIDO
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: estaCargando
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF1D4ED8), Color(0xFF6D28D9)],
                            ),
                      color: estaCargando ? Colors.grey.shade400 : null,
                    ),
                    child: ElevatedButton(
                      onPressed: estaCargando
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _localLoading = true;
                                  _localError = '';
                                });

                                final exito = await viewModel.login(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );

                                if (exito && mounted) {
                                  final userData = viewModel.currentUser;
                                  if (userData != null) {
                                    final int idRol = userData['id_rol'] ?? 1;
                                    _navigateBasedOnRol(idRol);
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      _localLoading = false;
                                    });
                                  }
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
                      child: estaCargando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
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

                  // BOTÓN DE GOOGLE CORREGIDO (Inmune a spam de clics)
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Google',
                          iconPath: 'assets/google_logo.png',
                          isGoogle: true,
                          onTap: estaCargando
                              ? null
                              : () async {
                                  print('=== BOTÓN GOOGLE CLICKEADO ===');
                                  FocusScope.of(context).unfocus(); 
                                  
                                  setState(() {
                                    _localLoading = true;
                                    _localError = '';
                                  });
                                  
                                  final exito = await viewModel.loginWithGoogle();
                                  
                                  if (exito && mounted) {
                                    final user = viewModel.currentUser;
                                    final int idRol = user != null ? (user['id_rol'] ?? 1) : 1;
                                    _navigateBasedOnRol(idRol);
                                  } else {
                                    if (mounted) {
                                      setState(() {
                                        _localLoading = false;
                                        // Dejamos que lea la traducción del ViewModel sin sobreescribirla
                                        _localError = ''; 
                                      });
                                    }
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Apple',
                          icon: Icons.apple,
                          isGoogle: false,
                          onTap: estaCargando
                              ? null
                              : () {
                                  print('Apple login presionado');
                                },
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
                        onTap: estaCargando
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Regístrate ahora',
                          style: TextStyle(
                            color: estaCargando ? Colors.grey : const Color(0xFF2563EB),
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
    bool enabled = true,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
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
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    IconData? icon,
    String? iconPath,
    required bool isGoogle,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: onTap == null ? Colors.grey.shade300 : const Color(0xFFE2E8F0), 
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: onTap == null ? Colors.grey.shade50 : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGoogle
              ? Icon(Icons.g_mobiledata, 
                  color: onTap == null ? Colors.grey : Colors.red, 
                  size: 26)
              : Icon(icon, 
                  color: onTap == null ? Colors.grey : Colors.black, 
                  size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: onTap == null ? Colors.grey : const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}