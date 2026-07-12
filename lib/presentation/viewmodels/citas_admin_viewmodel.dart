import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/cita_admin_entity.dart';
import 'package:flutter_application_1/data/repositories/citas_admin_repository.dart';

class CitasAdminViewModel extends ChangeNotifier {
  final CitasAdminRepository _repository = CitasAdminRepository();

  List<CitaAdminEntity> citas = [];
  CitaAdminEntity? citaSeleccionada;
  bool isLoading = false;
  bool isLoadingAccion = false;
  String? error;
  String filtroActual = 'todas';
  Timer? _timer;

  final List<String> filtros = [
    'todas',
    'pendiente',
    'confirmada',
    'en_curso',
    'completada',
    'rechazada',
    'cancelada',
  ];

  Future<void> cargarCitas(int idNegocio) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      citas = await _repository.getCitas(
        idNegocio,
        filtroEstado: filtroActual == 'todas' ? null : filtroActual,
      );
      // Cargar citas y ordenarlas por fecha de cita descendente
      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));

      _iniciarTimerAutomatico(idNegocio);
    } catch (e) {
      error = 'Error al cargar citas: $e';
      print('CitasAdminViewModel: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDetalle(int idCita) async {
    try {
      citaSeleccionada = await _repository.getDetalleCita(idCita);
      notifyListeners();
    } catch (e) {
      print('Error detalle cita: $e');
    }
  }

  void cambiarFiltro(String filtro, int idNegocio) {
    filtroActual = filtro;
    cargarCitas(idNegocio);
  }

  Future<bool> confirmarCita(int idCita, int idNegocio) async {
    return await _ejecutarAccion(
      () => _repository.confirmarCita(idCita),
      idNegocio,
      idCita,
    );
  }

  Future<bool> rechazarCita(int idCita, String motivo, int idNegocio) async {
    return await _ejecutarAccion(
      () => _repository.rechazarCita(idCita, motivo),
      idNegocio,
      idCita,
    );
  }

  Future<bool> iniciarCita(int idCita, int idNegocio) async {
    return await _ejecutarAccion(
      () => _repository.iniciarCita(idCita),
      idNegocio,
      idCita,
    );
  }

  Future<bool> finalizarCita(int idCita, int idNegocio) async {
    return await _ejecutarAccion(
      () => _repository.finalizarCita(idCita),
      idNegocio,
      idCita,
    );
  }

  Future<bool> _ejecutarAccion(
    Future<void> Function() accion,
    int idNegocio,
    int idCita,
  ) async {
    isLoadingAccion = true;
    notifyListeners();

    try {
      await accion();
      // Recarga la cita seleccionada y la lista
      await cargarDetalle(idCita);
      await cargarCitas(idNegocio);
      return true;
    } catch (e) {
      error = 'Error: $e';
      print('Error acción: $e');
      return false;
    } finally {
      isLoadingAccion = false;
      notifyListeners();
    }
  }

  // Timer que revisa cada minuto si alguna cita en_curso debe finalizarse
  void _iniciarTimerAutomatico(int idNegocio) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final citasEnCurso = citas.where((c) => c.estado == 'en_curso').toList();

      for (final cita in citasEnCurso) {
        if (cita.debeFinalizarAutomaticamente) {
          print('Finalizando cita ${cita.idCita} automáticamente');
          await _repository.finalizarCita(cita.idCita);
        }
      }

      if (citasEnCurso.isNotEmpty) {
        await cargarCitas(idNegocio);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
