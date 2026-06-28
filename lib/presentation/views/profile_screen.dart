import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'login_view.dart';
import 'businessregistration_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isAdmin;
  const ProfileScreen({super.key, this.isAdmin = false});

  Future<void> _mostrarOpcionesFoto(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    final ImagePicker picker = ImagePicker();

    Future<void> procesarSeleccion(ImageSource source) async {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) Navigator.pop(context);
        File archivoImagen = File(image.path);
        await viewModel.subirFotoUsuario(archivoImagen);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Foto de perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Tomar foto con la cámara'),
                  onTap: () => procesarSeleccion(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Seleccionar desde la galería'),
                  onTap: () => procesarSeleccion(ImageSource.gallery),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final String? fotoUrl = viewModel.userPhotoUrl;
          final ImageProvider imageProvider =
              (fotoUrl != null && fotoUrl.isNotEmpty)
              ? NetworkImage(fotoUrl)
              : const NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
                    )
                    as ImageProvider;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(backgroundImage: imageProvider),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Cita',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    'Pro',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF475569),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Foto de perfil
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.blue,
                                    child: CircleAvatar(
                                      radius: 46,
                                      backgroundImage: imageProvider,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _mostrarOpcionesFoto(
                                        context,
                                        viewModel,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                viewModel.userName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF6D28D9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isAdmin ? 'Administrador' : 'Miembro Premium',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Información de cuenta
                        _buildSectionCard(
                          title: 'Información de la Cuenta',
                          editText: 'Editar',
                          onEditPressed: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Correo Electrónico',
                                viewModel.userEmail,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Número de Teléfono',
                                '+1 (555) 123-4567',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Banner según rol
                        if (isAdmin) ...[
                          _buildSectionCard(
                            title: 'Mi Negocio',
                            child: Column(
                              children: [
                                _buildConfigRow(
                                  Icons.store_outlined,
                                  'Información del negocio',
                                ),
                                const Divider(),
                                _buildConfigRow(
                                  Icons.people_outline,
                                  'Gestionar profesionales',
                                ),
                                const Divider(),
                                _buildConfigRow(
                                  Icons.design_services_outlined,
                                  'Gestionar servicios',
                                ),
                                const Divider(),
                                _buildConfigRow(
                                  Icons.bar_chart_outlined,
                                  'Reportes y estadísticas',
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BusinessIntroView(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1D4ED8),
                                    Color(0xFF6D28D9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¿Tienes un negocio?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Regístrate y comienza a gestionar tus citas hoy mismo.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Configuración general
                        _buildSectionCard(
                          title: 'Configuración',
                          child: Column(
                            children: [
                              _buildConfigRow(
                                Icons.credit_card,
                                'Métodos de Pago',
                              ),
                              const Divider(),
                              _buildConfigRow(
                                Icons.location_on_outlined,
                                'Direcciones Guardadas',
                              ),
                              const Divider(),
                              _buildConfigRow(
                                Icons.notifications_outlined,
                                'Preferencias de Notificación',
                              ),
                              const Divider(),
                              _buildConfigRow(
                                Icons.lock_outline,
                                'Seguridad y Privacidad',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Cerrar sesión
                        TextButton.icon(
                          onPressed: () async {
                            await viewModel.signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginView(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String editText = 'Editar',
    VoidCallback? onEditPressed,
    bool showAddIcon = false,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (onEditPressed != null)
                TextButton(
                  onPressed: onEditPressed,
                  child: Text(
                    editText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (showAddIcon)
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
