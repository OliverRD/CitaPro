import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/login_viewmodel.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _cellphoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  late AuthRepository _authRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authRepository = Provider.of<AuthRepository>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cedulaController.dispose();
    _cellphoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los Términos de Servicio.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.signUp(
        name: _nameController.text.trim(),
        cedula: _cedulaController.text.trim(),
        cellphone: _cellphoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada con éxito!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorString = e.toString();
        String mensajeTraducido = errorString.replaceAll('Exception: ', '');

        if (errorString.contains('User already registered')) {
          mensajeTraducido = 'Este correo ya se encuentra registrado. Intenta iniciar sesión.';
        } else if (errorString.contains('Email not confirmed')) {
          mensajeTraducido = 'Cuenta registrada. Por favor confirma tu correo electrónico antes de ingresar.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeTraducido)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final bool estaCargandoTodo = _isLoading || loginViewModel.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
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
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0061FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Únete a CitaPro y gestiona tus citas sin interrupciones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInputField(
                      label: 'Nombre Completo',
                      hint: 'Ej. Juan Ramos',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      enabled: !estaCargandoTodo,
                      validator: (value) =>
                          value!.isEmpty ? 'Ingresa tu nombre completo' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      label: 'Cédula',
                      hint: 'Ej. 1.234.567-8',
                      icon: Icons.badge_outlined,
                      controller: _cedulaController,
                      enabled: !estaCargandoTodo,
                      validator: (value) =>
                          value!.isEmpty ? 'Ingresa tu cédula' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      label: 'Correo Electrónico',
                      hint: 'tu@correo.com',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      enabled: !estaCargandoTodo,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      label: 'Número de Celular',
                      hint: 'Ej. +18291234567',
                      icon: Icons.phone_outlined,
                      controller: _cellphoneController,
                      enabled: !estaCargandoTodo,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu número de celular';
                        }
                        if (!RegExp(r'^\+?\d{7,15}$').hasMatch(value)) {
                          return 'Número no válido';
                        }
                        return null;
                      },
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isPasswordObscured,
                          enabled: !estaCargandoTodo,
                          validator: (value) =>
                              value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: const TextStyle(color: Colors.black26),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: estaCargandoTodo ? null : () => setState(
                                () => _isPasswordObscured = !_isPasswordObscured,
                              ),
                            ),
                            filled: true,
                            fillColor: estaCargandoTodo ? Colors.grey.shade100 : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          activeColor: const Color(0xFF5113D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: estaCargandoTodo
                              ? null
                              : (value) => setState(() => _acceptTerms = value ?? false),
                        ),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: 'Acepto los '),
                                TextSpan(
                                  text: 'Términos de Servicio',
                                  style: TextStyle(
                                    color: Color(0xFF0061FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' y '),
                                TextSpan(
                                  text: 'Política de Privacidad',
                                  style: TextStyle(
                                    color: Color(0xFF0061FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: estaCargandoTodo ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: estaCargandoTodo ? Colors.grey.shade400 : const Color(0xFF5113D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: estaCargandoTodo
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'O regístrate con',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata,
                            color: Colors.red,
                            onTap: estaCargandoTodo
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final usuario = await _authRepository.signInWithGoogle();
                                    if (usuario != null && mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Apple',
                            icon: Icons.apple,
                            color: Colors.black,
                            onTap: estaCargandoTodo ? null : () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        GestureDetector(
                          onTap: estaCargandoTodo ? null : () => Navigator.pop(context),
                          child: Text(
                            'Inicia sesión',
                            style: TextStyle(
                              fontSize: 14,
                              color: estaCargandoTodo ? Colors.grey : const Color(0xFF0061FF),
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
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap, 
  }) {
    return OutlinedButton.icon(
      onPressed: onTap, 
      icon: Icon(icon, color: onTap == null ? Colors.grey : color, size: 24),
      label: Text(
        label,
        style: TextStyle(
          color: onTap == null ? Colors.grey : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: onTap == null ? Colors.grey.shade50 : Colors.white,
      ),
    );
  }
}