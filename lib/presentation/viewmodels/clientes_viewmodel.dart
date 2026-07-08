import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/cliente_entity.dart';
import 'package:flutter_application_1/data/repositories/clientes_repository.dart';

class ClientesViewModel extends ChangeNotifier {
  final ClientesRepository _repository = ClientesRepository();

  List<ClienteEntity> clientes = [];
  List<ClienteEntity> clientesFiltrados = [];
  EstadisticasClientesEntity? estadisticas;
  ClienteEntity? clienteSeleccionado;
  bool isLoading = false;
  bool isLoadingDetalle = false;
  String? error;

  // Controladores para editar perfil
  final alergiasController = TextEditingController();
  final preferenciasController = TextEditingController();
  final observacionesController = TextEditingController();

  Future<void> cargarClientes(int idNegocio) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _repository.getClientes(idNegocio),
        _repository.getEstadisticas(idNegocio),
      ]);

      clientes = resultados[0] as List<ClienteEntity>;
      clientesFiltrados = List.from(clientes);
      estadisticas = resultados[1] as EstadisticasClientesEntity;
    } catch (e) {
      error = 'Error al cargar clientes: $e';
      print('Error ClientesViewModel: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDetalle(int idUsuario, int idNegocio) async {
    isLoadingDetalle = true;
    notifyListeners();

    try {
      clienteSeleccionado = await _repository.getDetalleCliente(
        idUsuario,
        idNegocio,
      );
      alergiasController.text = clienteSeleccionado?.alergias ?? '';
      preferenciasController.text = clienteSeleccionado?.preferencias ?? '';
      observacionesController.text = clienteSeleccionado?.observaciones ?? '';
    } catch (e) {
      print('Error detalle cliente: $e');
    } finally {
      isLoadingDetalle = false;
      notifyListeners();
    }
  }

  Future<void> guardarPerfil(int idNegocio) async {
    if (clienteSeleccionado == null) return;
    try {
      await _repository.guardarPerfilCliente(
        idUsuario: clienteSeleccionado!.idUsuario,
        idNegocio: idNegocio,
        alergias: alergiasController.text.trim(),
        preferencias: preferenciasController.text.trim(),
        observaciones: observacionesController.text.trim(),
      );
    } catch (e) {
      print('Error guardando perfil: $e');
    }
  }

  void buscarCliente(String query) {
    if (query.isEmpty) {
      clientesFiltrados = List.from(clientes);
    } else {
      clientesFiltrados = clientes
          .where((c) => c.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    alergiasController.dispose();
    preferenciasController.dispose();
    observacionesController.dispose();
    super.dispose();
  }
}
