import 'package:flutter_application_1/domain/usecases/dashboard_entity.dart';

class AdminInfoModel extends AdminInfoEntity {
  const AdminInfoModel({required super.nombre, super.foto});

  factory AdminInfoModel.fromJson(Map<String, dynamic> json) {
    return AdminInfoModel(
      nombre: json['nombreUser'] ?? 'Administrador',
      foto: json['foto'],
    );
  }
}

class ProximaCitaModel extends ProximaCitaEntity {
  const ProximaCitaModel({
    required super.hora,
    required super.servicio,
    required super.cliente,
    required super.estado,
  });

  factory ProximaCitaModel.fromJson(Map<String, dynamic> json) {
    final hora = json['hora'].toString().substring(0, 5);
    final servicios = json['detalle_cita'] as List?;
    final servicio = servicios != null && servicios.isNotEmpty
        ? servicios.first['servicios']['nombre']
        : 'Servicio';
    final cliente = json['usuarios']['nombreUser'] ?? 'Cliente';
    final estado = json['estado'] ?? 'pendiente';

    return ProximaCitaModel(
      hora: hora,
      servicio: servicio,
      cliente: cliente,
      estado: estado,
    );
  }
}

class ServicioPopularModel extends ServicioPopularEntity {
  const ServicioPopularModel({
    required super.nombre,
    required super.totalCitas,
  });

  factory ServicioPopularModel.fromJson(Map<String, dynamic> json) {
    return ServicioPopularModel(
      nombre: json['servicios']['nombre'],
      totalCitas: json['count'],
    );
  }
}
