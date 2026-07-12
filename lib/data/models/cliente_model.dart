import 'package:flutter_application_1/domain/usecases/cliente_entity.dart';

class ClienteModel extends ClienteEntity {
  const ClienteModel({
    required super.idUsuario,
    required super.nombre,
    required super.telefono,
    required super.correo,
    super.foto,
    required super.totalCitas,
    super.ultimaVisita,
    super.primeraVisita,
    required super.totalInvertido,
    required super.serviciosRecibidos,
    super.alergias,
    super.preferencias,
    super.observaciones,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    final citas = json['citas'] as List? ?? [];

    DateTime? ultimaVisita;
    DateTime? primeraVisita;
    double totalInvertido = 0;
    final servicios = <String>{};

    // ANTES — suma todas las citas sin filtrar:
    /* for (final cita in citas) {
      final fecha = DateTime.tryParse(cita['fecha_cita'] ?? '');
      if (fecha != null) {
        if (ultimaVisita == null || fecha.isAfter(ultimaVisita)) {
          ultimaVisita = fecha;
        }
        if (primeraVisita == null || fecha.isBefore(primeraVisita)) {
          primeraVisita = fecha;
        }
      }
      totalInvertido += (cita['total'] as num?)?.toDouble() ?? 0;

      final detalles = cita['detalle_cita'] as List? ?? [];
      for (final detalle in detalles) {
        final nombreServicio = detalle['servicios']?['nombre'];
        if (nombreServicio != null) servicios.add(nombreServicio);
      }
    }*/

    // DESPUÉS — solo suma citas completadas o en curso:
    for (final cita in citas) {
      final estado = cita['estado'] as String? ?? '';

      // fechas: consideramos todas para saber primera y última visita real
      // pero solo de citas que sí se realizaron
      final contable = ['completada', 'en_curso'].contains(estado);

      final fecha = DateTime.tryParse(cita['fecha_cita'] ?? '');
      if (fecha != null && contable) {
        if (ultimaVisita == null || fecha.isAfter(ultimaVisita)) {
          ultimaVisita = fecha;
        }
        if (primeraVisita == null || fecha.isBefore(primeraVisita)) {
          primeraVisita = fecha;
        }
      }

      // solo suma el dinero de citas que sí se pagaron/completaron
      if (contable) {
        totalInvertido += (cita['total'] as num?)?.toDouble() ?? 0;
      }

      // solo agrega servicios de citas que sí se realizaron
      if (contable) {
        final detalles = cita['detalle_cita'] as List? ?? [];
        for (final detalle in detalles) {
          final nombreServicio = detalle['servicios']?['nombre'];
          if (nombreServicio != null) servicios.add(nombreServicio);
        }
      }
    }

    final perfil = json['perfil_cliente_negocio'] as List?;
    final perfilData = perfil != null && perfil.isNotEmpty
        ? perfil.first
        : null;

    return ClienteModel(
      idUsuario: json['id_usuario'] as int,
      nombre: json['nombreUser'] ?? 'Sin nombre',
      telefono: json['telefonoUser'] ?? '',
      correo: json['correoUser'] ?? '',
      foto: json['foto'],
      totalCitas: citas.length,
      ultimaVisita: ultimaVisita,
      primeraVisita: primeraVisita,
      totalInvertido: totalInvertido,
      serviciosRecibidos: servicios.toList(),
      alergias: perfilData?['alergias'],
      preferencias: perfilData?['preferencias'],
      observaciones: perfilData?['observaciones'],
    );
  }
}
