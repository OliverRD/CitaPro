import 'package:flutter_application_1/domain/usecases/solicitud_entity.dart';

abstract class ISolicitudRepository {
  Future<void> crearSolicitud(SolicitudEntity solicitud);
}
