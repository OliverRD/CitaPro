import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/presentation/viewmodels/solicitud_viewmodel.dart';

class BusinessFormScreen extends StatefulWidget {
  final int idCategoria;

  const BusinessFormScreen({super.key, required this.idCategoria});

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  final PageController _pageController = PageController();
  late SolicitudViewModel _viewModel;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = SolicitudViewModel();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _enviar() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      print("👤 Usuario auth: ${user?.id}");

      if (user == null) {
        print(" No hay usuario logueado");
        return;
      }

      final response = await Supabase.instance.client
          .from('usuarios')
          .select('id_usuario')
          .eq('auth_id', user.id)
          .single();

      print(" Usuario encontrado: $response");

      final idUsuario = response['id_usuario'] as int;

      await _viewModel.enviarSolicitud(
        idUsuario: idUsuario,
        idCategoria: widget.idCategoria,
      );
    } catch (e, stackTrace) {
      print(" ERROR en _enviar: $e");
      print(" StackTrace: $stackTrace");
    }

    if (_viewModel.enviado && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2563EB),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Solicitud enviada!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu solicitud está en revisión. Te notificaremos cuando sea aprobada.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Volver al inicio',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF6FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () {
              if (_currentPage == 0) {
                Navigator.pop(context);
              } else {
                _prevPage();
              }
            },
          ),
          title: Column(
            children: [
              Text(
                _currentPage == 0 ? 'Paso 1 de 2' : 'Paso 2 de 2',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _currentPage == 0 ? 0.5 : 1.0,
                backgroundColor: const Color(0xFFE2E8F0),
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _Paso1(onNext: _nextPage),
            _Paso2(onEnviar: _enviar),
          ],
        ),
      ),
    );
  }
}

//  Formulario 1
class _Paso1 extends StatelessWidget {
  final VoidCallback onNext;
  const _Paso1({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuéntanos más sobre\ntu negocio',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa los datos básicos para personalizar tu perfil.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 28),

          // Imagen opcional
          Center(
            child: GestureDetector(
              onTap: () {
                ImagePicker().pickImage(source: ImageSource.gallery).then((
                  pickedFile,
                ) {
                  if (pickedFile != null) {
                    vm.imagenUrl = pickedFile.path;
                    vm.notify();
                  }
                });
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Logo del negocio\n(opcional)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nombre
          _Label('Nombre del negocio *'),
          _Campo(
            controller: vm.nombreController,
            hint: 'Ej. Serene Health Clinic',
            onChanged: (_) => vm.notify(),
          ),
          const SizedBox(height: 16),

          // Teléfono
          _Label('Teléfono'),
          _Campo(
            controller: vm.telefonoController,
            hint: '+1 829 123 4567',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          _Label('Descripción del negocio *'),
          _Campo(
            controller: vm.descripcionController,
            hint: 'Describe brevemente los servicios y especialidades...',
            maxLines: 4,
            maxLength: 200,
            onChanged: (_) => vm.notify(),
          ),
          const SizedBox(height: 28),

          const SizedBox(height: 24),

          // Separador redes sociales
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Redes sociales (opcional)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 16),

          // Instagram
          _Label('Instagram'),
          _CampoRed(
            controller: vm.instagramController,
            hint: 'instagram.com/tu_negocio',
            icon: Icons.camera_alt_outlined,
            iconColor: const Color(0xFFE1306C),
            iconBg: const Color(0xFFFCE7F3),
          ),
          const SizedBox(height: 12),

          // Facebook
          _Label('Facebook'),
          _CampoRed(
            controller: vm.facebookController,
            hint: 'facebook.com/tu_negocio',
            icon: Icons.facebook_outlined,
            iconColor: const Color(0xFF1877F2),
            iconBg: const Color(0xFFDBEAFE),
          ),
          const SizedBox(height: 12),

          // WhatsApp
          _Label('WhatsApp Business'),
          _CampoRed(
            controller: vm.whatsappController,
            hint: '+1 829 123 4567',
            icon: Icons.chat_outlined,
            iconColor: const Color(0xFF25D366),
            iconBg: const Color(0xFFDCFCE7),
            keyboardType: TextInputType.phone,
            helperText: 'Se usará para recibir citas directas.',
          ),
          const SizedBox(height: 12),

          // TikTok o Sitio Web
          _Label('TikTok o Sitio Web'),
          _CampoRed(
            controller: vm.tiktokController,
            hint: 'https://www.ejemplo.com',
            icon: Icons.language_outlined,
            iconColor: const Color(0xFF64748B),
            iconBg: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 28),

          // Botón siguiente
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.paso1Valido ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
              ),
              child: Text(
                'Continuar →',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

//  Formulario 2
class _Paso2 extends StatelessWidget {
  final VoidCallback onEnviar;
  const _Paso2({required this.onEnviar});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Dónde se encuentra\ntu negocio?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra la dirección física para que tus clientes puedan encontrarte.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 28),

          // Dirección
          _Label('Dirección (Obligatorio)'),
          _Campo(
            controller: vm.direccionController,
            hint: 'Calle, número, oficina',
            onChanged: (_) => vm.notify(),
          ),
          const SizedBox(height: 16),

          // Ciudad y Provincia en fila
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Ciudad (Obligatorio)'),
                    _Campo(
                      controller: vm.ciudadController,
                      hint: 'Ej. Santiago',
                      onChanged: (_) => vm.notify(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Provincia (Obligatorio)'),
                    _Campo(
                      controller: vm.provinciaController,
                      hint: 'Ej. Santiago',
                      onChanged: (_) => vm.notify(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Referencia
          _Label('Referencia (opcional)'),
          _Campo(
            controller: vm.referenciaController,
            hint: 'Ej. Frente al parque central',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Por qué necesitamos tu ubicación?\nEsto nos permite calcular distancias para tus clientes y mostrarte en resultados de búsqueda locales.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF1E3A8A),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Error
          if (vm.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vm.error!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.redAccent,
                ),
              ),
            ),

          // Botón enviar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.paso2Valido && !vm.isLoading ? onEnviar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Enviar solicitud →',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

//  WIDGETS REUTILIZABLES
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E3A8A),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;

  const _Campo({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E3A8A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}

class _CampoRed extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final TextInputType? keyboardType;
  final String? helperText;

  const _CampoRed({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.keyboardType,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF1E3A8A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              helperText!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
      ],
    );
  }
}
