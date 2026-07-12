import 'package:flutter_application_1/domain/usecases/cita_admin_entity.dart';

abstract class ICitasAdminRepository {
  Future<List<CitaAdminEntity>> getCitas(int idNegocio, {String? filtroEstado});
  Future<CitaAdminEntity> getDetalleCita(int idCita);
  Future<void> confirmarCita(int idCita);
  Future<void> rechazarCita(int idCita, String motivo);
  Future<void> iniciarCita(int idCita);
  Future<void> finalizarCita(int idCita);
}
