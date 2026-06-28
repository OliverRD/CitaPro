import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/repositories/i_solicitud_repository.dart';
import 'package:flutter_application_1/domain/usecases/solicitud_entity.dart';
import 'package:flutter_application_1/data/models/solicitud_model.dart';

class SolicitudRepository implements ISolicitudRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> crearSolicitud(SolicitudEntity solicitud) async {
    final model = SolicitudModel(
      idUsuario: solicitud.idUsuario,
      idCategoria: solicitud.idCategoria,
      nombreNegocio: solicitud.nombreNegocio,
      descripcion: solicitud.descripcion,
      telefono: solicitud.telefono,
      imagen: solicitud.imagen,
      direccion: solicitud.direccion,
      ciudad: solicitud.ciudad,
      provincia: solicitud.provincia,
      referencia: solicitud.referencia,
    );

    try {
      print(" Enviando solicitud: ${model.toJson()}");
      await _supabase.from('solicitudes_negocio').insert(model.toJson());
      print(" Solicitud insertada correctamente");
    } catch (e, stackTrace) {
      print(" ERROR al insertar: $e");
      print(" StackTrace: $stackTrace");
      throw e;
    }
  }
}
