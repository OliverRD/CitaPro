import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/repositories/i_citas_admin_repository.dart';
import 'package:flutter_application_1/domain/usecases/cita_admin_entity.dart';
import 'package:flutter_application_1/data/models/cita_admin_model.dart';

class CitasAdminRepository implements ICitasAdminRepository {
  final _supabase = Supabase.instance.client;

  String get _select => '''
    id_cita, fecha_cita, hora, estado, total,
    motivo_cancelacion, hora_inicio_real, hora_fin_real,
    usuarios!citas_id_cliente_fkey(
      nombreUser, foto, telefonoUser
    ),
    profesionales(
      usuarios(nombreUser)
    ),
    detalle_cita(
      servicios(nombre, duracion)
    )
  ''';

  @override
  Future<List<CitaAdminEntity>> getCitas(
    int idNegocio, {
    String? filtroEstado,
  }) async {
    var query = _supabase
        .from('citas')
        .select(_select)
        .eq('id_negocio', idNegocio);

    if (filtroEstado != null && filtroEstado != 'todas') {
      query = query.eq('estado', filtroEstado);
    }

    final res = await query
        .order('fecha_cita', ascending: true)
        .order('hora', ascending: true);

    return (res as List).map((json) => CitaAdminModel.fromJson(json)).toList();
  }

  @override
  Future<CitaAdminEntity> getDetalleCita(int idCita) async {
    final res = await _supabase
        .from('citas')
        .select(_select)
        .eq('id_cita', idCita)
        .single();
    return CitaAdminModel.fromJson(res);
  }

  @override
  Future<void> confirmarCita(int idCita) async {
    await _supabase
        .from('citas')
        .update({'estado': 'confirmada'})
        .eq('id_cita', idCita);
  }

  @override
  Future<void> rechazarCita(int idCita, String motivo) async {
    await _supabase
        .from('citas')
        .update({'estado': 'rechazada', 'motivo_cancelacion': motivo})
        .eq('id_cita', idCita);
  }

  @override
  Future<void> iniciarCita(int idCita) async {
    final horaStr = await _getHoraActual();
    await _supabase
        .from('citas')
        .update({'estado': 'en_curso', 'hora_inicio_real': horaStr})
        .eq('id_cita', idCita);
  }

  @override
  Future<void> finalizarCita(int idCita) async {
    final now = DateTime.now();
    final horaStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00';

    await _supabase
        .from('citas')
        .update({'estado': 'completada', 'hora_fin_real': horaStr})
        .eq('id_cita', idCita);
  }

  // Helper para obtener la hora actual como String
  Future<String> _getHoraActual() async {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:00';
  }
}
