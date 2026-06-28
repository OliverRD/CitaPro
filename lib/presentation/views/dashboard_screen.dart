import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_application_1/domain/usecases/dashboard_entity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _viewModel.cargarDashboard();
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF2563EB),
          onPressed: () => _mostrarAccionesRapidas(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Consumer<DashboardViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              );
            }

            if (vm.error != null) {
              return Center(
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
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.cargarDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Reintentar',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFF2563EB),
                onRefresh: vm.cargarDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Encabezado(info: vm.adminInfo),
                      const SizedBox(height: 24),
                      _SeccionTitulo(
                        titulo: 'Resumen del día',
                        fecha: _fechaHoy(),
                      ),
                      const SizedBox(height: 12),
                      _TarjetasResumen(resumen: vm.resumen),
                      const SizedBox(height: 24),
                      _TarjetaIngresos(ingresos: vm.resumen?.ingresosHoy ?? 0),
                      const SizedBox(height: 24),
                      _SeccionTitulo(titulo: 'Próximas citas'),
                      const SizedBox(height: 12),
                      _ListaProximasCitas(citas: vm.proximasCitas),
                      const SizedBox(height: 24),
                      _SeccionTitulo(titulo: 'Servicios populares'),
                      const SizedBox(height: 12),
                      _ServiciosPopulares(servicios: vm.serviciosPopulares),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _fechaHoy() {
    final now = DateTime.now();
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${now.day} de ${meses[now.month - 1]}';
  }

  void _mostrarAccionesRapidas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Acciones rápidas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            _AccionRapida(
              icon: Icons.add_circle_outline,
              label: 'Agregar servicio',
              onTap: () {},
            ),
            _AccionRapida(
              icon: Icons.schedule_outlined,
              label: 'Agregar horario',
              onTap: () {},
            ),
            _AccionRapida(
              icon: Icons.calendar_today_outlined,
              label: 'Ver citas',
              onTap: () {},
            ),
            _AccionRapida(
              icon: Icons.settings_outlined,
              label: 'Configurar negocio',
              onTap: () {},
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ENCABEZADO
class _Encabezado extends StatelessWidget {
  final AdminInfoEntity? info;
  const _Encabezado({this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFDBEAFE),
          backgroundImage: info?.foto != null
              ? NetworkImage(info!.foto!)
              : null,
          child: info?.foto == null
              ? const Icon(
                  Icons.person_outline,
                  color: Color(0xFF2563EB),
                  size: 26,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola,',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                info?.nombre ?? 'Administrador',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF2563EB),
            size: 28,
          ),
        ),
      ],
    );
  }
}

// SECCIÓN TÍTULO
class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final String? fecha;
  const _SeccionTitulo({required this.titulo, this.fecha});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        if (fecha != null)
          Text(
            fecha!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
      ],
    );
  }
}

// TARJETAS RESUMEN
class _TarjetasResumen extends StatelessWidget {
  final ResumenDiaEntity? resumen;
  const _TarjetasResumen({this.resumen});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _TarjetaEstado(
          label: 'Citas totales',
          valor: '${resumen?.totalCitas ?? 0}',
          icon: Icons.calendar_month_outlined,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFDBEAFE),
        ),
        _TarjetaEstado(
          label: 'Confirmadas',
          valor: '${resumen?.confirmadas ?? 0}',
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF16A34A),
          iconBg: const Color(0xFFDCFCE7),
        ),
        _TarjetaEstado(
          label: 'Pendientes',
          valor: '${resumen?.pendientes ?? 0}',
          icon: Icons.access_time_outlined,
          iconColor: const Color(0xFFF59E0B),
          iconBg: const Color(0xFFFEF3C7),
        ),
        _TarjetaEstado(
          label: 'Canceladas',
          valor: '${resumen?.canceladas ?? 0}',
          icon: Icons.cancel_outlined,
          iconColor: const Color(0xFFDC2626),
          iconBg: const Color(0xFFFEE2E2),
        ),
      ],
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _TarjetaEstado({
    required this.label,
    required this.valor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// TARJETA INGRESOS
class _TarjetaIngresos extends StatelessWidget {
  final double ingresos;
  const _TarjetaIngresos({required this.ingresos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresos de hoy',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RD\$ ${ingresos.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Pagos completados hoy',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PRÓXIMAS CITAS
class _ListaProximasCitas extends StatelessWidget {
  final List<ProximaCitaEntity> citas;
  const _ListaProximasCitas({required this.citas});

  @override
  Widget build(BuildContext context) {
    if (citas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hay citas próximas hoy',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }

    return Column(
      children: citas.map((cita) => _ItemCita(cita: cita)).toList(),
    );
  }
}

class _ItemCita extends StatelessWidget {
  final ProximaCitaEntity cita;
  const _ItemCita({required this.cita});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return const Color(0xFF16A34A);
      case 'pendiente':
        return const Color(0xFFF59E0B);
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
      case 'cancelada':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        children: [
          Column(
            children: [
              Text(
                cita.hora,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.servicio,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  cita.cliente,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _bgEstado(cita.estado),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cita.estado,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _colorEstado(cita.estado),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SERVICIOS POPULARES
class _ServiciosPopulares extends StatelessWidget {
  final List<ServicioPopularEntity> servicios;
  const _ServiciosPopulares({required this.servicios});

  @override
  Widget build(BuildContext context) {
    if (servicios.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Sin datos aún',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: servicios.map((s) => _TarjetaServicio(servicio: s)).toList(),
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  final ServicioPopularEntity servicio;
  const _TarjetaServicio({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_outline, color: Color(0xFF2563EB), size: 20),
          const SizedBox(height: 6),
          Text(
            servicio.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          Text(
            '${servicio.totalCitas} citas',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ACCIÓN RÁPIDA 
class _AccionRapida extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AccionRapida({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E3A8A),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFFCBD5E1),
      ),
    );
  }
}
