import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/repositories/i_calendario_repository.dart';
import 'package:flutter_application_1/domain/usecases/calendario_entity.dart';
import 'package:flutter_application_1/data/models/calendario_model.dart';

class CalendarioRepository implements ICalendarioRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<CalendarioCitaEntity>> getCitasPorFecha(
    int idNegocio,
    String fecha,
  ) async {
    final res = await _supabase
        .from('citas')
        .select('''
          id_cita, hora, estado,
          usuarios!citas_id_cliente_fkey(nombreUser, foto),
          detalle_cita(
            servicios(nombre, duracion)
          )
        ''')
        .eq('id_negocio', idNegocio)
        .eq('fecha_cita', fecha)
        .not('estado', 'in', '("cancelada","rechazada")')
        .order('hora', ascending: true);

    return (res as List).map((json) => CalendarioModel.fromJson(json)).toList();
  }
}
