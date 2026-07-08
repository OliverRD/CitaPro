import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/presentation/viewmodels/clientes_viewmodel.dart';
import 'package:flutter_application_1/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_application_1/domain/usecases/cliente_entity.dart';
import 'detalle_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late ClientesViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ClientesViewModel();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final dashVM = Provider.of<DashboardViewModel>(context, listen: false);
    if (dashVM.idNegocio != null) {
      await _viewModel.cargarClientes(dashVM.idNegocio!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF6FF),
        body: SafeArea(
          child: Consumer<ClientesViewModel>(
            builder: (context, vm, _) {
              return RefreshIndicator(
                color: const Color(0xFF2563EB),
                onRefresh: _cargarDatos,
                child: CustomScrollView(
                  slivers: [
                    // Encabezado
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clientes',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tarjetas estadísticas
                            if (vm.estadisticas != null)
                              Row(
                                children: [
                                  _TarjetaEstadistica(
                                    label: 'Atendidos',
                                    valor: '${vm.estadisticas!.totalAtendidos}',
                                    color: const Color(0xFF2563EB),
                                    bg: const Color(0xFFDBEAFE),
                                  ),
                                  const SizedBox(width: 10),
                                  _TarjetaEstadistica(
                                    label: 'Nuevos',
                                    valor: '${vm.estadisticas!.clientesNuevos}',
                                    color: const Color(0xFF16A34A),
                                    bg: const Color(0xFFDCFCE7),
                                  ),
                                  const SizedBox(width: 10),
                                  _TarjetaEstadistica(
                                    label: 'Frecuentes',
                                    valor:
                                        '${vm.estadisticas!.clientesFrecuentes}',
                                    color: const Color(0xFFF59E0B),
                                    bg: const Color(0xFFFEF3C7),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),

                            // Buscador
                            TextField(
                              controller: _searchController,
                              onChanged: vm.buscarCliente,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Buscar clientes...',
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_outlined,
                                  color: Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
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
                          ],
                        ),
                      ),
                    ),

                    // Lista
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
                          child: Text(
                            vm.error!,
                            style: GoogleFonts.poppins(color: Colors.redAccent),
                          ),
                        ),
                      )
                    else if (vm.clientesFiltrados.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No hay clientes aún',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final cliente = vm.clientesFiltrados[index];
                            return _TarjetaCliente(
                              cliente: cliente,
                              onTap: () async {
                                final dashVM = Provider.of<DashboardViewModel>(
                                  context,
                                  listen: false,
                                );
                                await vm.cargarDetalle(
                                  cliente.idUsuario,
                                  dashVM.idNegocio!,
                                );
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChangeNotifierProvider.value(
                                            value: vm,
                                            child: DetalleClienteScreen(
                                              idNegocio: dashVM.idNegocio!,
                                            ),
                                          ),
                                    ),
                                  );
                                }
                              },
                            );
                          }, childCount: vm.clientesFiltrados.length),
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
}

// TARJETA ESTADÍSTICA
class _TarjetaEstadistica extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  final Color bg;

  const _TarjetaEstadistica({
    required this.label,
    required this.valor,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TARJETA CLIENTE
class _TarjetaCliente extends StatelessWidget {
  final ClienteEntity cliente;
  final VoidCallback onTap;

  const _TarjetaCliente({required this.cliente, required this.onTap});

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'Ninguna';
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

  Color _colorEtiqueta(String etiqueta) {
    switch (etiqueta) {
      case 'frecuente':
        return const Color(0xFF2563EB);
      case 'nuevo':
        return const Color(0xFF16A34A);
      default:
        return Colors.transparent;
    }
  }

  Color _bgEtiqueta(String etiqueta) {
    switch (etiqueta) {
      case 'frecuente':
        return const Color(0xFFDBEAFE);
      case 'nuevo':
        return const Color(0xFFDCFCE7);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final etiqueta = cliente.etiqueta;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cliente.nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      if (etiqueta.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _bgEtiqueta(etiqueta),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            etiqueta.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _colorEtiqueta(etiqueta),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cliente.telefono.isNotEmpty
                            ? cliente.telefono
                            : 'Sin teléfono',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Última: ${_formatFecha(cliente.ultimaVisita)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${cliente.totalCitas} citas totales',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
