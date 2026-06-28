class ResumenDiaEntity {
  final int totalCitas;
  final int confirmadas;
  final int pendientes;
  final int canceladas;
  final double ingresosHoy;

  const ResumenDiaEntity({
    required this.totalCitas,
    required this.confirmadas,
    required this.pendientes,
    required this.canceladas,
    required this.ingresosHoy,
  });
}

class ProximaCitaEntity {
  final String hora;
  final String servicio;
  final String cliente;
  final String estado;

  const ProximaCitaEntity({
    required this.hora,
    required this.servicio,
    required this.cliente,
    required this.estado,
  });
}

class ServicioPopularEntity {
  final String nombre;
  final int totalCitas;

  const ServicioPopularEntity({required this.nombre, required this.totalCitas});
}

class AdminInfoEntity {
  final String nombre;
  final String? foto;

  const AdminInfoEntity({required this.nombre, this.foto});
}
