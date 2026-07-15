import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

final supabase = Supabase.instance.client;

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _citas = [];
  double _totalGastado = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final user = supabase.auth.currentUser;
      if (user == null || user.email == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final usuarioData = await supabase
          .from('usuarios')
          .select('id_usuario')
          .eq('correoUser', user.email!)
          .single();

      final int idNumericoCliente = usuarioData['id_usuario'];

      final List<Map<String, dynamic>> response = await supabase
          .from('citas')
          .select('''
            *,
            negocio:id_negocio ( nombre ),
            profesionales:id_profesional (
              usuarios:id_usuario ( nombreUser )
            ),
            detalle_cita (
              precio,
              cantidad,
              servicios:id_servicio ( nombre )
            )
          ''')
          .eq('id_userCliente', idNumericoCliente)
          .order('fecha_cita', ascending: false);

      double sumatoriaGlobal = 0.0;

      for (var cita in response) {
        final detalles = cita['detalle_cita'] as List<dynamic>? ?? [];
        double costoTotalCita = 0.0;

        for (var det in detalles) {
          final double precioUnitario = det['precio'] != null
              ? double.parse(det['precio'].toString())
              : 0.0;
          final int cantidad = det['cantidad'] != null
              ? int.parse(det['cantidad'].toString())
              : 1;
          costoTotalCita += (precioUnitario * cantidad);
        }

        cita['total_calculado'] = costoTotalCita;
        sumatoriaGlobal += costoTotalCita;
      }

      if (!mounted) return;
      setState(() {
        _citas = response;
        _totalGastado = sumatoriaGlobal;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en CitaPro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportarReporte() {
    if (_citas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos en el historial para exportar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();
    buffer.writeln('==================================');
    buffer.writeln('       REPORTE DE CITAPRO         ');
    buffer.writeln('==================================');
    buffer.writeln('Inversión Total: \$${_totalGastado.toStringAsFixed(2)}');
    buffer.writeln('Total de Citas: ${_citas.length}');
    buffer.writeln('Fecha de Emisión: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('==================================\n');
    buffer.writeln('DETALLE DE SERVICIOS:\n');

    for (var i = 0; i < _citas.length; i++) {
      final cita = _citas[i];
      final String negocio = cita['negocio'] != null 
          ? cita['negocio']['nombre'] ?? 'Establecimiento' 
          : 'Establecimiento';
      
      String servicio = 'Servicio Solicitado';
      final detalles = cita['detalle_cita'] as List<dynamic>? ?? [];
      if (detalles.isNotEmpty && detalles.first['servicios'] != null) {
        servicio = detalles.first['servicios']['nombre'] ?? 'Servicio Solicitado';
        if (detalles.length > 1) {
          servicio += ' (+${detalles.length - 1} más)';
        }
      }

      final String fecha = cita['fecha_cita'] != null 
          ? cita['fecha_cita'].toString().substring(0, 10) 
          : 'Sin fecha';
      final double total = cita['total_calculado'] ?? 0.0;

      buffer.writeln('${i + 1}. $servicio');
      buffer.writeln('   Negocio: $negocio');
      buffer.writeln('   Fecha: $fecha');
      buffer.writeln('   Costo: \$${total.toStringAsFixed(2)}');
      buffer.writeln('----------------------------------');
    }

    Share.share(buffer.toString(), subject: 'Reporte Historial CitaPro');
  }

  Future<void> _eliminarCita(dynamic idCita, int index) async {
    try {
      await supabase.from('detalle_cita').delete().eq('id_cita', idCita);
      await supabase.from('historial_citas').delete().eq('id_cita', idCita);
      await supabase.from('citas').delete().eq('id_cita', idCita);

      if (!mounted) return;
      
      setState(() {
        final citaEliminada = _citas[index];
        _totalGastado -= (citaEliminada['total_calculado'] ?? 0.0);
        _citas.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita eliminada del historial con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D47A1);
    const Color backgroundColor = Color(0xFFF5F7FA);
    const Color cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _cargarHistorial,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de Servicios',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lleva el control de tus citas pasadas y tu inversión total.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: cardColor,
                            ),
                            onPressed: () {}, // Espacio para filtros por fecha en el futuro
                            icon: const Icon(
                              Icons.tune,
                              size: 18,
                              color: Colors.grey,
                            ),
                            label: const Text(
                              'Filtrar por fecha',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: cardColor,
                            ),
                            onPressed: _exportarReporte,
                            icon: const Icon(
                              Icons.file_upload_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            label: const Text(
                              'Exportar Reporte',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildStatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue[50]!,
                      title: 'TOTAL GASTADO',
                      value: '\$${_totalGastado.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Citas Recientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _citas.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Text(
                                'No tienes registros en tu historial.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _citas.length,
                            itemBuilder: (context, index) {
                              final cita = _citas[index];

                              final String nombreNegocio = cita['negocio'] != null
                                  ? cita['negocio']['nombre'] ?? 'Establecimiento'
                                  : 'Establecimiento';

                              String nombreEspecialista = 'Por asignar';
                              if (cita['profesionales'] != null &&
                                  cita['profesionales']['usuarios'] != null) {
                                nombreEspecialista = cita['profesionales']['usuarios']['nombreUser'] ?? 'Por asignar';
                              }

                              String nombreServicio = 'Servicio Solicitado';
                              final detalles = cita['detalle_cita'] as List<dynamic>? ?? [];
                              if (detalles.isNotEmpty && detalles.first['servicios'] != null) {
                                nombreServicio = detalles.first['servicios']['nombre'] ?? 'Servicio Solicitado';
                                if (detalles.length > 1) {
                                  nombreServicio += ' (+${detalles.length - 1})';
                                }
                              }

                              final double totalCita = cita['total_calculado'] ?? 0.0;

                              String fechaFormateada = 'Sin fecha';
                              if (cita['fecha_cita'] != null) {
                                String fechaStr = cita['fecha_cita'].toString();
                                fechaFormateada = fechaStr.length >= 10
                                    ? fechaStr.substring(0, 10)
                                    : fechaStr;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: _buildAppointmentCard(
                                  imageUrl: cita['imagen_url'] ??
                                      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&q=80&w=150',
                                  serviceName: nombreServicio,
                                  businessName: nombreNegocio,
                                  date: fechaFormateada,
                                  specialistName: nombreEspecialista,
                                  specialistAvatar: cita['especialista_avatar'] ??
                                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100',
                                  price: '\$${totalCita.toStringAsFixed(2)}',
                                  onDelete: () {
                                    _eliminarCita(cita['id_cita'], index);
                                  },
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String imageUrl,
    required String serviceName,
    required String businessName,
    required String date,
    required String specialistName,
    required String specialistAvatar,
    required String price,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          businessName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FECHA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESPECIALISTA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(specialistAvatar),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        specialistName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COSTO TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}