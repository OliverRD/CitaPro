class Booking {
  final int idCita;
  final int idNegocio;
  final String businessName;
  final String serviceName;
  final int idServicio;
  final int idProfesional;
  final String nombreProfesional;
  final String date;
  final String time;
  final String status;
  final double total;

  const Booking({
    required this.idCita,
    required this.idNegocio,
    required this.businessName,
    required this.serviceName,
    required this.idServicio,
    required this.idProfesional,
    required this.nombreProfesional,
    required this.date,
    required this.time,
    required this.status,
    required this.total,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final detalles = json['detalle_cita'] as List? ?? [];
    final servicio = detalles.isNotEmpty
        ? detalles.first['servicios'] as Map<String, dynamic>? ?? {}
        : {};
    final profesional = json['profesionales'] as Map<String, dynamic>? ?? {};
    final usuarioProfesional =
        profesional['usuarios'] as Map<String, dynamic>? ?? {};
    final negocio = json['negocio'] as Map<String, dynamic>? ?? {};

    return Booking(
      idCita: json['id_cita'] as int,
      idNegocio: json['id_negocio'] as int,
      businessName: negocio['nombre'] ?? 'Negocio',
      serviceName: servicio['nombre'] ?? 'Servicio',
      idServicio: servicio['id_servicio'] ?? 0,
      idProfesional: json['id_profesional'] as int,
      nombreProfesional: usuarioProfesional['nombreUser'] ?? 'Profesional',
      date: json['fecha_cita'] as String,
      time: (json['hora'] as String).substring(0, 5),
      status: json['estado'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }
}
