import 'package:flutter_application_1/domain/usecases/cliente_entity.dart';

abstract class IClientesRepository {
  Future<List<ClienteEntity>> getClientes(int idNegocio);
  Future<ClienteEntity> getDetalleCliente(int idUsuario, int idNegocio);
  Future<EstadisticasClientesEntity> getEstadisticas(int idNegocio);
  Future<void> guardarPerfilCliente({
    required int idUsuario,
    required int idNegocio,
    String? alergias,
    String? preferencias,
    String? observaciones,
  });
}
