import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/calendario_entity.dart';
import 'package:flutter_application_1/data/repositories/calendario_repository.dart';

class CalendarioViewModel extends ChangeNotifier {
  final CalendarioRepository _repository = CalendarioRepository();

  DateTime fechaSeleccionada = DateTime.now();
  List<CalendarioCitaEntity> citas = [];
  bool isLoading = false;
  String? error;

  Future<void> cargarCitas(int idNegocio) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fechaStr = fechaSeleccionada.toIso8601String().substring(0, 10);
      citas = await _repository.getCitasPorFecha(idNegocio, fechaStr);
    } catch (e) {
      error = 'Error al cargar el calendario: $e';
      print('CalendarioViewModel: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void cambiarFecha(DateTime fecha, int idNegocio) {
    fechaSeleccionada = fecha;
    cargarCitas(idNegocio);
  }

  void mesAnterior(int idNegocio) {
    fechaSeleccionada = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month - 1,
      1,
    );
    notifyListeners();
    cargarCitas(idNegocio);
  }

  void mesSiguiente(int idNegocio) {
    fechaSeleccionada = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month + 1,
      1,
    );
    notifyListeners();
    cargarCitas(idNegocio);
  }

  // Horas del día para mostrar en el calendario (8am - 8pm)
  List<int> get horasDelDia => List.generate(13, (i) => i + 8);

  // Obtiene las citas que corresponden a una hora específica
  List<CalendarioCitaEntity> citasEnHora(int hora) {
    return citas.where((c) {
      final h = int.tryParse(c.hora.split(':')[0]) ?? -1;
      return h == hora;
    }).toList();
  }
}
