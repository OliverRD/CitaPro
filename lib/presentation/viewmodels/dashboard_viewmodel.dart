import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/usecases/dashboard_entity.dart';
import 'package:flutter_application_1/data/repositories/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  AdminInfoEntity? adminInfo;
  ResumenDiaEntity? resumen;
  List<ProximaCitaEntity> proximasCitas = [];
  List<ServicioPopularEntity> serviciosPopulares = [];
  int? idNegocio;
  bool isLoading = false;
  String? error;

  Future<void> cargarDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');

      // Info del admin
      adminInfo = await _repository.getAdminInfo(user.id);

      // ID usuario
      final usuarioRes = await Supabase.instance.client
          .from('usuarios')
          .select('id_usuario')
          .eq('auth_id', user.id)
          .single();
      final idUsuario = usuarioRes['id_usuario'] as int;

      // ID negocio
      idNegocio = await _repository.getIdNegocio(idUsuario);

      // Cargar todo en paralelo
      final resultados = await Future.wait([
        _repository.getResumenDia(idNegocio!),
        _repository.getProximasCitas(idNegocio!),
        _repository.getServiciosPopulares(idNegocio!),
      ]);

      resumen = resultados[0] as ResumenDiaEntity;
      proximasCitas = resultados[1] as List<ProximaCitaEntity>;
      serviciosPopulares = resultados[2] as List<ServicioPopularEntity>;
    } catch (e) {
      error = 'Error al cargar el dashboard: $e';
      print('Dashboard error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
