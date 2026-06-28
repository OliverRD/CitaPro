import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/repositories/i_dashboard_repository.dart';
import 'package:flutter_application_1/domain/usecases/dashboard_entity.dart';
import 'package:flutter_application_1/data/models/dashboard_model.dart';

class DashboardRepository implements IDashboardRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<AdminInfoEntity> getAdminInfo(String authId) async {
    final res = await _supabase
        .from('usuarios')
        .select('nombreUser, foto')
        .eq('auth_id', authId)
        .single();
    return AdminInfoModel.fromJson(res);
  }

  @override
  Future<int> getIdNegocio(int idUsuario) async {
    final res = await _supabase
        .from('negocio')
        .select('id_negocio')
        .eq('id_usuario_admin', idUsuario)
        .single();
    return res['id_negocio'] as int;
  }

  @override
  Future<ResumenDiaEntity> getResumenDia(int idNegocio) async {
    final hoy = DateTime.now().toIso8601String().substring(0, 10);

    final citas = await _supabase
        .from('citas')
        .select('estado')
        .eq('id_negocio', idNegocio)
        .eq('fecha_cita', hoy);

    final lista = citas as List;
    final total = lista.length;
    final confirmadas = lista.where((c) => c['estado'] == 'confirmada').length;
    final pendientes = lista.where((c) => c['estado'] == 'pendiente').length;
    final canceladas = lista.where((c) => c['estado'] == 'cancelada').length;

    // Ingresos del día
    final pagos = await _supabase
        .from('pagos')
        .select('monto')
        .eq('id_negocio', idNegocio)
        .eq('estado_pago', 'pagado')
        .gte('fecha_pago', '${hoy}T00:00:00')
        .lte('fecha_pago', '${hoy}T23:59:59');

    final ingresos = (pagos as List).fold<double>(
      0,
      (sum, p) => sum + (p['monto'] as num).toDouble(),
    );

    return ResumenDiaEntity(
      totalCitas: total,
      confirmadas: confirmadas,
      pendientes: pendientes,
      canceladas: canceladas,
      ingresosHoy: ingresos,
    );
  }

  @override
  Future<List<ProximaCitaEntity>> getProximasCitas(int idNegocio) async {
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final horaActual =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final res = await _supabase
        .from('citas')
        .select('''
          hora, estado,
          usuarios!citas_id_cliente_fkey(nombreUser),
          detalle_cita(
            servicios(nombre)
          )
        ''')
        .eq('id_negocio', idNegocio)
        .eq('fecha_cita', hoy)
        .gte('hora', horaActual)
        .inFilter('estado', ['pendiente', 'confirmada'])
        .order('hora')
        .limit(5);

    return (res as List)
        .map((json) => ProximaCitaModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ServicioPopularEntity>> getServiciosPopulares(
    int idNegocio,
  ) async {
    final res = await _supabase
        .from('detalle_cita')
        .select('''
        id_servicio,
        servicios!inner(nombre, id_negocio)
      ''')
        .eq('servicios.id_negocio', idNegocio);

    final lista = res as List;
    final Map<int, Map<String, dynamic>> agrupado = {};

    for (final item in lista) {
      final idServicio = item['id_servicio'] as int;
      final nombreServicio = item['servicios']['nombre'] as String;

      if (agrupado.containsKey(idServicio)) {
        agrupado[idServicio]!['count'] =
            (agrupado[idServicio]!['count'] as int) + 1;
      } else {
        agrupado[idServicio] = {'nombre': nombreServicio, 'count': 1};
      }
    }

    // Ordenar por más solicitado
    final ordenado = agrupado.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return ordenado
        .take(4)
        .map(
          (e) => ServicioPopularEntity(
            nombre: e['nombre'] as String,
            totalCitas: e['count'] as int,
          ),
        )
        .toList();
  }
}
