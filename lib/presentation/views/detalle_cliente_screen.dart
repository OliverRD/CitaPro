import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/presentation/viewmodels/clientes_viewmodel.dart';

class DetalleClienteScreen extends StatelessWidget {
  final int idNegocio;
  const DetalleClienteScreen({super.key, required this.idNegocio});

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'N/A';
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientesViewModel>();
    final cliente = vm.clienteSeleccionado;

    if (vm.isLoadingDetalle || cliente == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEFF6FF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF1E3A8A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del Cliente',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E3A8A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y datos básicos
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFDBEAFE),
                    backgroundImage: cliente.foto != null
                        ? NetworkImage(cliente.foto!)
                        : null,
                    child: cliente.foto == null
                        ? Text(
                            cliente.nombre.isNotEmpty
                                ? cliente.nombre[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2563EB),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cliente.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cliente.telefono,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cliente.correo,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (cliente.etiqueta.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cliente.etiqueta == 'frecuente'
                            ? const Color(0xFFDBEAFE)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cliente.etiqueta == 'frecuente'
                            ? 'Cliente Frecuente'
                            : 'Cliente Nuevo',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cliente.etiqueta == 'frecuente'
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: Text(
                      'Nueva Cita',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Historial
            _SeccionTitulo(titulo: 'Historial'),
            const SizedBox(height: 10),
            Row(
              children: [
                _TarjetaHistorial(
                  label: 'PRIMERA CITA',
                  valor: _formatFecha(cliente.primeraVisita),
                ),
                const SizedBox(width: 12),
                _TarjetaHistorial(
                  label: 'ÚLTIMA CITA',
                  valor: _formatFecha(cliente.ultimaVisita),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TarjetaHistorial(
                  label: 'TOTAL CITAS',
                  valor: '${cliente.totalCitas}',
                ),
                const SizedBox(width: 12),
                _TarjetaHistorial(
                  label: 'INVERTIDO',
                  valor: 'RD\$ ${cliente.totalInvertido.toStringAsFixed(0)}',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Servicios recibidos
            _SeccionTitulo(titulo: 'Servicios recibidos'),
            const SizedBox(height: 10),
            cliente.serviciosRecibidos.isEmpty
                ? Text(
                    'Sin servicios registrados',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cliente.serviciosRecibidos
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 24),

            // Perfil del cliente (editable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SeccionTitulo(titulo: 'Perfil del cliente'),
                TextButton(
                  onPressed: () => _mostrarEditorPerfil(context, vm),
                  child: Text(
                    'Editar',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ItemPerfil(
              icon: Icons.warning_amber_outlined,
              label: 'Alergias',
              valor: cliente.alergias ?? 'No registrado',
              color: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 10),
            _ItemPerfil(
              icon: Icons.favorite_outline,
              label: 'Preferencias',
              valor: cliente.preferencias ?? 'No registrado',
              color: const Color(0xFFDBEAFE),
              iconColor: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 10),
            _ItemPerfil(
              icon: Icons.note_outlined,
              label: 'Observaciones',
              valor: cliente.observaciones ?? 'No registrado',
              color: const Color(0xFFF1F5F9),
              iconColor: const Color(0xFF64748B),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _mostrarEditorPerfil(BuildContext context, ClientesViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Editar perfil del cliente',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            _CampoEditable(
              label: 'Alergias',
              controller: vm.alergiasController,
            ),
            const SizedBox(height: 12),
            _CampoEditable(
              label: 'Preferencias',
              controller: vm.preferenciasController,
            ),
            const SizedBox(height: 12),
            _CampoEditable(
              label: 'Observaciones',
              controller: vm.observacionesController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await vm.guardarPerfil(idNegocio);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Guardar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  WIDGETS REUTILIZABLES
class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E3A8A),
      ),
    );
  }
}

class _TarjetaHistorial extends StatelessWidget {
  final String label;
  final String valor;
  const _TarjetaHistorial({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPerfil extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;
  final Color iconColor;

  const _ItemPerfil({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoEditable extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _CampoEditable({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF1E3A8A),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEFF6FF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
