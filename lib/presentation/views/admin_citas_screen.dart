import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/presentation/viewmodels/citas_admin_viewmodel.dart';
import 'package:flutter_application_1/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_application_1/domain/usecases/cita_admin_entity.dart';
import 'detalle_cita_admin_screen.dart';

class AdminCitasScreen extends StatefulWidget {
  const AdminCitasScreen({super.key});

  @override
  State<AdminCitasScreen> createState() => _AdminCitasScreenState();
}

class _AdminCitasScreenState extends State<AdminCitasScreen> {
  late CitasAdminViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CitasAdminViewModel();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final dashVM = Provider.of<DashboardViewModel>(context, listen: false);
    if (dashVM.idNegocio != null) {
      await _viewModel.cargarCitas(dashVM.idNegocio!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF6FF),
        body: SafeArea(
          child: Consumer<CitasAdminViewModel>(
            builder: (context, vm, _) {
              final dashVM = Provider.of<DashboardViewModel>(
                context,
                listen: false,
              );

              return RefreshIndicator(
                color: const Color(0xFF2563EB),
                onRefresh: _cargarDatos,
                child: CustomScrollView(
                  slivers: [
                    // Encabezado
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Citas',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                            IconButton(
                              onPressed: _cargarDatos,
                              icon: const Icon(
                                Icons.refresh_outlined,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filtros
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: vm.filtros.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final filtro = vm.filtros[i];
                            final activo = vm.filtroActual == filtro;
                            return GestureDetector(
                              onTap: () =>
                                  vm.cambiarFiltro(filtro, dashVM.idNegocio!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: activo
                                      ? const Color(0xFF2563EB)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: activo
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  _labelFiltro(filtro),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: activo
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Lista o estados
                    if (vm.isLoading)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      )
                    else if (vm.error != null)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                vm.error!,
                                style: GoogleFonts.poppins(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (vm.citas.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF94A3B8),
                                size: 56,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay citas',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            // Agrupar por fecha
                            final cita = vm.citas[index];
                            final mostrarFecha =
                                index == 0 ||
                                vm.citas[index - 1].fechaCita != cita.fechaCita;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (mostrarFecha) ...[
                                  if (index != 0) const SizedBox(height: 16),
                                  Text(
                                    _formatFechaGrupo(cita.fechaCita),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                _TarjetaCita(
                                  cita: cita,
                                  onTap: () async {
                                    await vm.cargarDetalle(cita.idCita);
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChangeNotifierProvider.value(
                                                value: vm,
                                                child: DetalleCitaAdminScreen(
                                                  idNegocio: dashVM.idNegocio!,
                                                ),
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  onConfirmar: () async {
                                    final ok = await vm.confirmarCita(
                                      cita.idCita,
                                      dashVM.idNegocio!,
                                    );
                                    if (ok && context.mounted) {
                                      _mostrarSnack(
                                        context,
                                        'Cita confirmada',
                                        Colors.green,
                                      );
                                    }
                                  },
                                  onRechazar: () => _mostrarDialogoRechazo(
                                    context,
                                    vm,
                                    cita,
                                    dashVM.idNegocio!,
                                  ),
                                ),
                              ],
                            );
                          }, childCount: vm.citas.length),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _labelFiltro(String filtro) {
    switch (filtro) {
      case 'todas':
        return 'Todas';
      case 'pendiente':
        return 'Pendientes';
      case 'confirmada':
        return 'Confirmadas';
      case 'en_curso':
        return 'En curso';
      case 'completada':
        return 'Completadas';
      case 'rechazada':
        return 'Rechazadas';
      case 'cancelada':
        return 'Canceladas';
      default:
        return filtro;
    }
  }

  String _formatFechaGrupo(DateTime fecha) {
    final hoy = DateTime.now();
    final manana = hoy.add(const Duration(days: 1));
    if (fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day)
      return 'Hoy, ${_formatFecha(fecha)}';
    if (fecha.year == manana.year &&
        fecha.month == manana.month &&
        fecha.day == manana.day)
      return 'Mañana, ${_formatFecha(fecha)}';
    return _formatFecha(fecha);
  }

  String _formatFecha(DateTime fecha) {
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
    return '${fecha.day} de ${meses[fecha.month - 1]}';
  }

  void _mostrarSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _mostrarDialogoRechazo(
    BuildContext context,
    CitasAdminViewModel vm,
    CitaAdminEntity cita,
    int idNegocio,
  ) {
    String? motivoSeleccionado;
    final otroController = TextEditingController();

    final motivos = [
      'Profesional no disponible.',
      'Negocio cerrado.',
      'Emergencia.',
      'Otro.',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                'Motivo del rechazo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),
              ...motivos.map(
                (m) => RadioListTile<String>(
                  value: m,
                  groupValue: motivoSeleccionado,
                  activeColor: const Color(0xFF2563EB),
                  title: Text(m, style: GoogleFonts.poppins(fontSize: 14)),
                  onChanged: (v) => setStateModal(() => motivoSeleccionado = v),
                ),
              ),
              if (motivoSeleccionado == 'Otro.') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: otroController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Escribe el motivo...',
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEFF6FF),
                    border: OutlineInputBorder(
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: motivoSeleccionado == null
                      ? null
                      : () async {
                          final motivo = motivoSeleccionado == 'Otro.'
                              ? otroController.text.trim()
                              : motivoSeleccionado!;

                          if (motivoSeleccionado == 'Otro.' && motivo.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'El motivo es obligatorio.',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          final ok = await vm.rechazarCita(
                            cita.idCita,
                            motivo,
                            idNegocio,
                          );
                          if (ok && context.mounted) {
                            _mostrarSnack(
                              context,
                              'Cita rechazada',
                              Colors.redAccent,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Confirmar rechazo',
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
      ),
    );
  }
}

class _TarjetaCita extends StatelessWidget {
  final CitaAdminEntity cita;
  final VoidCallback onTap;
  final VoidCallback onConfirmar;
  final VoidCallback onRechazar;

  const _TarjetaCita({
    required this.cita,
    required this.onTap,
    required this.onConfirmar,
    required this.onRechazar,
  });

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return const Color(0xFF16A34A);
      case 'pendiente':
        return const Color(0xFFF59E0B);
      case 'en_curso':
        return const Color(0xFF2563EB);
      case 'completada':
        return const Color(0xFF64748B);
      case 'rechazada':
      case 'cancelada':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return const Color(0xFFDCFCE7);
      case 'pendiente':
        return const Color(0xFFFEF3C7);
      case 'en_curso':
        return const Color(0xFFDBEAFE);
      case 'completada':
        return const Color(0xFFF1F5F9);
      case 'rechazada':
      case 'cancelada':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return 'CONFIRMADA';
      case 'pendiente':
        return 'PENDIENTE';
      case 'en_curso':
        return 'EN CURSO';
      case 'completada':
        return 'COMPLETADA';
      case 'rechazada':
        return 'RECHAZADA';
      case 'cancelada':
        return 'CANCELADA';
      default:
        return estado.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: cita.estado == 'en_curso'
              ? Border.all(color: const Color(0xFF2563EB), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Barra de color izquierda + contenido
            IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: _colorEstado(cita.estado),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cita.hora,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _bgEstado(cita.estado),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _labelEstado(cita.estado),
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: _colorEstado(cita.estado),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cita.servicioPrincipal,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                          Text(
                            cita.nombreCliente,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botones solo para pendientes
            if (cita.estado == 'pendiente') ...[
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRechazar,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Rechazar',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirmar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Confirmar',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
