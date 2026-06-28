class SolicitudEntity {
  final int? idSolicitud;
  final int idUsuario;
  final int idCategoria;
  final String nombreNegocio;
  final String? descripcion;
  final String? telefono;
  final String? imagen;
  final String? instagram;
  final String? facebook;
  final String? whatsapp;
  final String? tiktok;
  final String? direccion;
  final String? ciudad;
  final String? provincia;
  final String? referencia;

  const SolicitudEntity({
    this.idSolicitud,
    required this.idUsuario,
    required this.idCategoria,
    required this.nombreNegocio,
    this.descripcion,
    this.telefono,
    this.imagen,
    this.instagram,
    this.facebook,
    this.whatsapp,
    this.tiktok,
    this.direccion,
    this.ciudad,
    this.provincia,
    this.referencia,
  });
}
