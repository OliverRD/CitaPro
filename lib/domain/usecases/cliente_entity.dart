class ClienteEntity {
  final int idUsuario;
  final String nombre;
  final String telefono;
  final String correo;
  final String? foto;
  final int totalCitas;
  final DateTime? ultimaVisita;
  final DateTime? primeraVisita;
  final double totalInvertido;
  final List<String> serviciosRecibidos;
  final String? alergias;
  final String? preferencias;
  final String? observaciones;

  const ClienteEntity({
    required this.idUsuario,
    required this.nombre,
    required this.telefono,
    required this.correo,
    this.foto,
    required this.totalCitas,
    this.ultimaVisita,
    this.primeraVisita,
    required this.totalInvertido,
    required this.serviciosRecibidos,
    this.alergias,
    this.preferencias,
    this.observaciones,
  });

  String get etiqueta {
    final ahora = DateTime.now();
    final hace30Dias = ahora.subtract(const Duration(days: 30));
    if (primeraVisita != null && primeraVisita!.isAfter(hace30Dias)) {
      return 'nuevo';
    } else if (totalCitas > 6) {
      return 'frecuente';
    }
    return '';
  }
}

class EstadisticasClientesEntity {
  final int totalAtendidos;
  final int clientesNuevos;
  final int clientesFrecuentes;

  const EstadisticasClientesEntity({
    required this.totalAtendidos,
    required this.clientesNuevos,
    required this.clientesFrecuentes,
  });
}
