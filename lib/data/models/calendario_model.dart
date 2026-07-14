import 'package:flutter_application_1/domain/usecases/calendario_entity.dart';

class CalendarioModel extends CalendarioCitaEntity {
  const CalendarioModel({
    required super.idCita,
    required super.nombreCliente,
    super.fotoCliente,
    required super.servicioPrincipal,
    required super.hora,
    required super.horaFin,
    required super.estado,
  });

  factory CalendarioModel.fromJson(Map<String, dynamic> json) {
    final cliente = json['usuarios'] as Map<String, dynamic>? ?? {};
    final detalles = json['detalle_cita'] as List? ?? [];
    final servicio = detalles.isNotEmpty
        ? detalles.first['servicios'] as Map<String, dynamic>? ?? {}
        : {};

    final hora = (json['hora'] as String).substring(0, 5);
    final duracion = servicio['duracion'] as int? ?? 30;

    // Calcula hora fin sumando duración
    final partes = hora.split(':');
    final inicioMinutos = int.parse(partes[0]) * 60 + int.parse(partes[1]);
    final finMinutos = inicioMinutos + duracion;
    final horaFin =
        '${(finMinutos ~/ 60).toString().padLeft(2, '0')}:'
        '${(finMinutos % 60).toString().padLeft(2, '0')}';

    return CalendarioModel(
      idCita: json['id_cita'] as int,
      nombreCliente: cliente['nombreUser'] ?? 'Cliente',
      fotoCliente: cliente['foto'],
      servicioPrincipal: servicio['nombre'] ?? 'Servicio',
      hora: hora,
      horaFin: horaFin,
      estado: json['estado'] as String,
    );
  }
}
