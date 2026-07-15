import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/presentation/viewmodels/calendario_viewmodel.dart';
import 'package:flutter_application_1/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_application_1/domain/usecases/calendario_entity.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  late CalendarioViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarioViewModel();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final dashVM = Provider.of<DashboardViewModel>(context, listen: false);

    if (dashVM.idNegocio == null) {
      await dashVM.cargarDashboard();
    }

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
          child: Consumer2<CalendarioViewModel, DashboardViewModel>(
            builder: (context, vm, dashVM, _) {
              // Espera a que el idNegocio esté disponible
              if (dashVM.idNegocio == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );
              }

              return Column(
                children: [
                  _Encabezado(vm: vm, idNegocio: dashVM.idNegocio!),
                  _SelectorDias(vm: vm, idNegocio: dashVM.idNegocio!),
                  const SizedBox(height: 8),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2563EB),
                            ),
                          )
                        : vm.error != null
                        ? Center(
                            child: Text(
                              vm.error!,
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF2563EB),
                            onRefresh: _cargarDatos,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: vm.horasDelDia.length,
                              itemBuilder: (context, index) {
                                final hora = vm.horasDelDia[index];
                                final citasHora = vm.citasEnHora(hora);
                                return _FilaHora(hora: hora, citas: citasHora);
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final CalendarioViewModel vm;
  final int idNegocio;

  const _Encabezado({required this.vm, required this.idNegocio});

  String _nombreMes(int mes) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return meses[mes - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_nombreMes(vm.fechaSeleccionada.month)} ${vm.fechaSeleccionada.year}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          Row(
            children: [
              _BotonNavMes(
                icono: Icons.chevron_left,
                onTap: () => vm.mesAnterior(idNegocio),
              ),
              const SizedBox(width: 4),
              _BotonNavMes(
                icono: Icons.chevron_right,
                onTap: () => vm.mesSiguiente(idNegocio),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonNavMes extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;

  const _BotonNavMes({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icono, size: 20, color: const Color(0xFF2563EB)),
      ),
    );
  }
}

class _SelectorDias extends StatelessWidget {
  final CalendarioViewModel vm;
  final int idNegocio;

  const _SelectorDias({required this.vm, required this.idNegocio});

  @override
  Widget build(BuildContext context) {
    // Genera los días de la semana visible (7 días desde el lunes de la semana actual)
    final hoy = vm.fechaSeleccionada;
    final lunesDeEstaSemana = hoy.subtract(Duration(days: hoy.weekday - 1));
    final dias = List.generate(
      7,
      (i) => lunesDeEstaSemana.add(Duration(days: i)),
    );

    const nombresDias = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) {
          final dia = dias[i];
          final seleccionado =
              dia.day == vm.fechaSeleccionada.day &&
              dia.month == vm.fechaSeleccionada.month &&
              dia.year == vm.fechaSeleccionada.year;
          final esHoy =
              dia.day == DateTime.now().day &&
              dia.month == DateTime.now().month &&
              dia.year == DateTime.now().year;

          return GestureDetector(
            onTap: () => vm.cambiarFecha(dia, idNegocio),
            child: Container(
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: seleccionado
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nombresDias[i],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: seleccionado
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dia.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: seleccionado
                          ? Colors.white
                          : esHoy
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilaHora extends StatelessWidget {
  final int hora;
  final List<CalendarioCitaEntity> citas;

  const _FilaHora({required this.hora, required this.citas});

  String _formatHora(int h) => '${h.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _formatHora(hora),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Línea vertical
          Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 1,
                height: citas.isEmpty ? 50 : null,
                color: const Color(0xFFE2E8F0),
              ),
              if (citas.isNotEmpty)
                Expanded(
                  child: Container(width: 1, color: const Color(0xFFE2E8F0)),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Contenido de la hora
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: citas.isEmpty
                  ? Container(
                      height: 50,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Disponible',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: citas
                          .map((c) => _TarjetaCitaCalendario(cita: c))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCitaCalendario extends StatelessWidget {
  final CalendarioCitaEntity cita;

  const _TarjetaCitaCalendario({required this.cita});

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
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return 'Confirmado';
      case 'pendiente':
        return 'Pendiente';
      case 'en_curso':
        return 'En curso';
      case 'completada':
        return 'Completada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _colorEstado(cita.estado), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar cliente
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFDBEAFE),
            backgroundImage: cita.fotoCliente != null
                ? NetworkImage(cita.fotoCliente!)
                : null,
            child: cita.fotoCliente == null
                ? Text(
                    cita.nombreCliente[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.nombreCliente,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  cita.servicioPrincipal,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${cita.hora} - ${cita.horaFin} AM',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _bgEstado(cita.estado),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _labelEstado(cita.estado),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _colorEstado(cita.estado),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
