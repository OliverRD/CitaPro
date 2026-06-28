import 'package:flutter_application_1/domain/usecases/dashboard_entity.dart';

abstract class IDashboardRepository {
  Future<AdminInfoEntity> getAdminInfo(String authId);
  Future<int> getIdNegocio(int idUsuario);
  Future<ResumenDiaEntity> getResumenDia(int idNegocio);
  Future<List<ProximaCitaEntity>> getProximasCitas(int idNegocio);
  Future<List<ServicioPopularEntity>> getServiciosPopulares(int idNegocio);
}
