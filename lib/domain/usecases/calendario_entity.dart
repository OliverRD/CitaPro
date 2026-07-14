class CalendarioCitaEntity {
  final int idCita;
  final String nombreCliente;
  final String? fotoCliente;
  final String servicioPrincipal;
  final String hora;
  final String horaFin;
  final String estado;

  const CalendarioCitaEntity({
    required this.idCita,
    required this.nombreCliente,
    this.fotoCliente,
    required this.servicioPrincipal,
    required this.hora,
    required this.horaFin,
    required this.estado,
  });
}
