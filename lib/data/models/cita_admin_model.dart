import 'package:flutter_application_1/domain/usecases/cita_admin_entity.dart';

class CitaAdminModel extends CitaAdminEntity {
  const CitaAdminModel({
    required super.idCita,
    required super.nombreCliente,
    super.fotoCliente,
    required super.telefonoCliente,
    required super.nombreProfesional,
    required super.servicioPrincipal,
    required super.servicios,
    required super.duracionMinutos,
    required super.fechaCita,
    required super.hora,
    required super.estado,
    required super.total,
    super.motivo,
    super.horaInicioReal,
    super.horaFinReal,
  });

  factory CitaAdminModel.fromJson(Map<String, dynamic> json) {
    // Cliente
    final cliente = json['usuarios'] as Map<String, dynamic>? ?? {};
    final nombreCliente = cliente['nombreUser'] ?? 'Cliente';
    final fotoCliente = cliente['foto'];
    final telefonoCliente = cliente['telefonoUser'] ?? '';

    // Profesional
    final profesional = json['profesionales'] as Map<String, dynamic>? ?? {};
    final usuarioProfesional =
        profesional['usuarios'] as Map<String, dynamic>? ?? {};
    final nombreProfesional = usuarioProfesional['nombreUser'] ?? 'Profesional';

    // Servicios
    final detalles = json['detalle_cita'] as List? ?? [];
    final servicios = <String>[];
    int duracionTotal = 0;

    for (final d in detalles) {
      final servicio = d['servicios'] as Map<String, dynamic>? ?? {};
      final nombre = servicio['nombre'] ?? '';
      if (nombre.isNotEmpty) servicios.add(nombre);
      duracionTotal += (servicio['duracion'] as int? ?? 30);
    }

    final servicioPrincipal = servicios.isNotEmpty
        ? servicios.first
        : 'Servicio';

    return CitaAdminModel(
      idCita: json['id_cita'] as int,
      nombreCliente: nombreCliente,
      fotoCliente: fotoCliente,
      telefonoCliente: telefonoCliente,
      nombreProfesional: nombreProfesional,
      servicioPrincipal: servicioPrincipal,
      servicios: servicios,
      duracionMinutos: duracionTotal,
      fechaCita: DateTime.parse(json['fecha_cita']),
      hora: (json['hora'] as String).substring(0, 5),
      estado: json['estado'] ?? 'pendiente',
      total: (json['total'] as num).toDouble(),
      motivo: json['motivo_cancelacion'],
      horaInicioReal: json['hora_inicio_real'] != null
          ? (json['hora_inicio_real'] as String).substring(0, 5)
          : null,
      horaFinReal: json['hora_fin_real'] != null
          ? (json['hora_fin_real'] as String).substring(0, 5)
          : null,
    );
  }
}
