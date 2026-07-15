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
        if (context.mounted) Navigator.pop(context); // Cierra el BottomSheet
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
    final viewModel = context.watch<ProfileViewModel>();

    final String? fotoUrl = viewModel.userPhotoUrl;
    final ImageProvider imageProvider = (fotoUrl != null && fotoUrl.isNotEmpty)
        ? NetworkImage(fotoUrl)
        : const NetworkImage(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
            ) as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Cita',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextSpan(
                    text: 'Pro',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E293B),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => viewModel.loadUserData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Avatar y Cabecera de Nombre
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF4F46E5),
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundImage: imageProvider,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      _mostrarOpcionesFoto(context, viewModel),
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
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            viewModel.userName.isNotEmpty
                                ? viewModel.userName
                                : 'Usuario',
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
                              isAdmin ? 'Administrador' : 'Miembro',
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

                    // Información de cuenta dinámica
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
                            viewModel.userPhone.isNotEmpty
                                ? viewModel.userPhone
                                : 'No registrado',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Paneles dinámicos por Rol
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
                              builder: (context) => const BusinessIntroView(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
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

                    // ==========================================
                    // SECCIÓN DE CONFIGURACIÓN DESPLEGABLE (FIX)
                    // ==========================================
                    _buildSectionCard(
                      title: 'Configuración',
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent, // Quita las líneas internas molestas del tile
                        ),
                        child: Column(
                          children: [
                            // 1. Métodos de Pago
                            _buildExpandableRow(
                              icon: Icons.credit_card,
                              label: 'Métodos de Pago',
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5), size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Agregar nueva tarjeta',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4F46E5),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No tienes métodos de pago guardados.',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),

                            // 2. Direcciones Guardadas
                            _buildExpandableRow(
                              icon: Icons.location_on_outlined,
                              label: 'Direcciones Guardadas',
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF4F46E5)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () {},
                                        icon: const Icon(Icons.my_location, size: 16, color: Color(0xFF4F46E5)),
                                        label: const Text('Usar ubicación actual', style: TextStyle(color: Color(0xFF4F46E5))),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'No has agregado direcciones de entrega/servicio.',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),

                            // 3. Preferencias de Notificación
                            _buildExpandableRow(
                              icon: Icons.notifications_outlined,
                              label: 'Preferencias de Notificación',
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Column(
                                    children: [
                                      _buildSwitchRow('Notificaciones Push', true),
                                      _buildSwitchRow('Alertas por Correo', false),
                                      _buildSwitchRow('Recordatorios de Citas', true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),

                            // 4. Seguridad y Privacidad
                            _buildExpandableRow(
                              icon: Icons.lock_outline,
                              label: 'Seguridad y Privacidad',
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildActionLink('Cambiar contraseña de CitaPro'),
                                      const SizedBox(height: 12),
                                      _buildActionLink('Autenticación de dos pasos (MFA)'),
                                      const SizedBox(height: 12),
                                      _buildActionLink('Políticas de Privacidad de Datos'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón Cerrar Sesión
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
            color: Colors.black.withOpacity(0.02),
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
      leading: Icon(icon, color: const Color(0xFF4F46E5)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  // WIDGET AUXILIAR: Crea cada fila desplegable elegante
  Widget _buildExpandableRow({
    required IconData icon,
    required String label,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: const Color(0xFF4F46E5)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
      ),
      iconColor: const Color(0xFF4F46E5),
      collapsedIconColor: Colors.grey,
      childrenPadding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      expandedAlignment: Alignment.topLeft,
      children: children,
    );
  }

  // WIDGET AUXILIAR: Switch elegante para los ajustes de notificaciones
  Widget _buildSwitchRow(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
            Switch(
              value: initialValue,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) {
                setState(() {
                  initialValue = val;
                });
              },
            ),
          ],
        );
      },
    );
  }

  // WIDGET AUXILIAR: Enlaces de acción para seguridad y políticas
  Widget _buildActionLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}