class CitaAdminEntity {
  final int idCita;
  final String nombreCliente;
  final String? fotoCliente;
  final String telefonoCliente;
  final String nombreProfesional;
  final String servicioPrincipal;
  final List<String> servicios;
  final int duracionMinutos;
  final DateTime fechaCita;
  final String hora;
  final String estado;
  final double total;
  final String? motivo;
  final String? horaInicioReal;
  final String? horaFinReal;

  const CitaAdminEntity({
    required this.idCita,
    required this.nombreCliente,
    this.fotoCliente,
    required this.telefonoCliente,
    required this.nombreProfesional,
    required this.servicioPrincipal,
    required this.servicios,
    required this.duracionMinutos,
    required this.fechaCita,
    required this.hora,
    required this.estado,
    required this.total,
    this.motivo,
    this.horaInicioReal,
    this.horaFinReal,
  });

  // Calcula si la cita debe finalizarse automáticamente
  bool get debeFinalizarAutomaticamente {
    if (estado != 'en_curso' || horaInicioReal == null) return false;
    final partes = horaInicioReal!.split(':');
    if (partes.length < 2) return false;
    final inicio = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
    final finEsperado = inicio.add(Duration(minutes: duracionMinutos));
    return DateTime.now().isAfter(finEsperado);
  }
}
