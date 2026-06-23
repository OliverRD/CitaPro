import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'login_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Función interna para desplegar el menú inferior de opciones de foto
  Future<void> _mostrarOpcionesFoto(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    final ImagePicker picker = ImagePicker();

    Future<void> procesarSeleccion(ImageSource source) async {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70, // Optimiza el tamaño para el Storage de Supabase
      );

      if (image != null) {
        if (context.mounted) Navigator.pop(context); // Cierra el menú inferior
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
              children: <Widget>[
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
    // Gestiona el estado de la pantalla mediante Provider
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
                        // Foto Central del Perfil
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
                                  color: const Color(0xFF6D28D9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Miembro Premium',
                                  style: TextStyle(
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
                                viewModel.userPhone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildSectionCard(
                          title: 'Métodos de Pago',
                          showAddIcon: true,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1D4ED8), Color(0xFF6D28D9)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Icon(Icons.nfc, color: Colors.white),
                                    Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Tarjeta Principal',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '•••• •••• •••• 4242',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildSectionCard(
                          title: 'Direcciones Guardadas',
                          child: Column(
                            children: [
                              _buildAddressRow(
                                Icons.home_outlined,
                                'Casa',
                                '123 Market St, San Francisco...',
                              ),
                              const Divider(height: 20),
                              _buildAddressRow(
                                Icons.business_center_outlined,
                                'Oficina',
                                '456 Tech Blvd, Suite 200...',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Cierra la sesión actual y redirige al login
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

  Widget _buildAddressRow(IconData icon, String label, String address) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                ),
              ),
              Text(
                address,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
      ],
    );
  }
}
