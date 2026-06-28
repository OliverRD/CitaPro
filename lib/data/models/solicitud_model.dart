import 'package:flutter_application_1/domain/usecases/solicitud_entity.dart';

class SolicitudModel extends SolicitudEntity {
  const SolicitudModel({
    super.idSolicitud,
    required super.idUsuario,
    required super.idCategoria,
    required super.nombreNegocio,
    super.descripcion,
    super.telefono,
    super.imagen,
    super.direccion,
    super.ciudad,
    super.provincia,
    super.referencia,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'id_categoria': idCategoria,
      'nombre_negocio': nombreNegocio,
      'descripcion': descripcion,
      'instagram': instagram,
      'facebook': facebook,
      'whatsapp': whatsapp,
      'tiktok': tiktok,
      'telefono': telefono,
      'imagen': imagen,
      'direccion': direccion,
      'ciudad': ciudad,
      'provincia': provincia,
      'referencia': referencia,
      'estado_solicitud': 'pendiente',
      'negocio_creado': false,
    };
  }
}
