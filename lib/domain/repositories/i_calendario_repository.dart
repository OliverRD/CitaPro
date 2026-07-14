import 'package:flutter_application_1/domain/usecases/calendario_entity.dart';

abstract class ICalendarioRepository {
  Future<List<CalendarioCitaEntity>> getCitasPorFecha(
    int idNegocio,
    String fecha,
  );
}
