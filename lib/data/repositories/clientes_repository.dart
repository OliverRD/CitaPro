import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/repositories/i_clientes_repository.dart';
import 'package:flutter_application_1/domain/usecases/cliente_entity.dart';
import 'package:flutter_application_1/data/models/cliente_model.dart';

class ClientesRepository implements IClientesRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ClienteEntity>> getClientes(int idNegocio) async {
    final citasRes = await _supabase
        .from('citas')
        .select('id_userCliente')
        .eq('id_negocio', idNegocio);

    final idsClientes = (citasRes as List)
        .map((c) => c['id_userCliente'] as int)
        .toSet()
        .toList();

    if (idsClientes.isEmpty) return [];

    final res = await _supabase
        .from('usuarios')
        .select('''
          id_usuario, "nombreUser", "telefonoUser", "correoUser", foto,
          citas!citas_id_cliente_fkey(
            fecha_cita, total, estado,
            detalle_cita(
              servicios(nombre)
            )
          ),
          perfil_cliente_negocio(alergias, preferencias, observaciones)
        ''')
        .inFilter('id_usuario', idsClientes)
        .eq('citas.id_negocio', idNegocio)
        .eq('perfil_cliente_negocio.id_negocio', idNegocio);

    return (res as List).map((json) => ClienteModel.fromJson(json)).toList();
  }

  @override
  Future<ClienteEntity> getDetalleCliente(int idUsuario, int idNegocio) async {
    final res = await _supabase
        .from('usuarios')
        .select('''
          id_usuario, "nombreUser", "telefonoUser", "correoUser", foto,
          citas!citas_id_cliente_fkey(
            fecha_cita, total, estado,
            detalle_cita(
              servicios(nombre)
            )
          ),
          perfil_cliente_negocio(alergias, preferencias, observaciones)
        ''')
        .eq('id_usuario', idUsuario)
        .eq('citas.id_negocio', idNegocio)
        .eq('perfil_cliente_negocio.id_negocio', idNegocio)
        .single();

    return ClienteModel.fromJson(res);
  }

  @override
  Future<EstadisticasClientesEntity> getEstadisticas(int idNegocio) async {
    final res = await _supabase
        .from('citas')
        .select('id_userCliente, fecha_cita')
        .eq('id_negocio', idNegocio);

    final lista = res as List;
    final hace30Dias = DateTime.now().subtract(const Duration(days: 30));

    // Clientes únicos
    final Map<int, List<DateTime>> clienteFechas = {};
    for (final c in lista) {
      final id = c['id_userCliente'] as int;
      final fecha = DateTime.tryParse(c['fecha_cita'] ?? '');
      if (fecha != null) {
        clienteFechas.putIfAbsent(id, () => []).add(fecha);
      }
    }

    final totalAtendidos = clienteFechas.keys.length;

    // Nuevos: primera cita en últimos 30 días
    final nuevos = clienteFechas.values.where((fechas) {
      final primera = fechas.reduce((a, b) => a.isBefore(b) ? a : b);
      return primera.isAfter(hace30Dias);
    }).length;

    // Frecuentes: más de 6 citas
    final frecuentes = clienteFechas.values.where((f) => f.length > 6).length;

    return EstadisticasClientesEntity(
      totalAtendidos: totalAtendidos,
      clientesNuevos: nuevos,
      clientesFrecuentes: frecuentes,
    );
  }

  @override
  Future<void> guardarPerfilCliente({
    required int idUsuario,
    required int idNegocio,
    String? alergias,
    String? preferencias,
    String? observaciones,
  }) async {
    await _supabase.from('perfil_cliente_negocio').upsert({
      'id_usuario': idUsuario,
      'id_negocio': idNegocio,
      'alergias': alergias,
      'preferencias': preferencias,
      'observaciones': observaciones,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
