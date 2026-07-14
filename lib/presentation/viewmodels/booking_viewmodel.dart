import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/booking_model.dart';

class BookingViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Booking> upcomingBookings = [];
  List<Booking> pastBookings = [];
  bool isLoading = false;
  String? error;

  List<Map<String, dynamic>> serviciosDisponibles = [];
  List<Map<String, dynamic>> profesionalesDisponibles = [];

  List<Map<String, dynamic>> serviciosSeleccionados = [];
  Map<String, dynamic>? profesionalSeleccionado;
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  bool isLoadingServicios = false;
  bool isLoadingProfesionales = false;
  bool isGuardando = false;
  String? errorFormulario;

  bool profesionalOcupado = false;
  bool isValidando = false;

  Future<void> cargarMisCitas() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');

      final usuarioRes = await _supabase
          .from('usuarios')
          .select('id_usuario')
          .eq('auth_id', user.id)
          .single();
      final idUsuario = usuarioRes['id_usuario'] as int;

      final hoy = DateTime.now().toIso8601String().substring(0, 10);

      final res = await _supabase
          .from('citas')
          .select('''
            id_cita, id_negocio, id_profesional, fecha_cita, hora, estado, total,
            negocio(nombre),
            profesionales(usuarios(nombreUser)),
            detalle_cita(servicios(id_servicio, nombre))
          ''')
          .eq('id_userCliente', idUsuario)
          .order('fecha_cita', ascending: true)
          .order('hora', ascending: true);

      final todas = (res as List).map((j) => Booking.fromJson(j)).toList();

      upcomingBookings = todas
          .where(
            (b) =>
                b.date.compareTo(hoy) >= 0 &&
                ['pendiente', 'confirmada', 'en_curso'].contains(b.status),
          )
          .toList();

      pastBookings = todas
          .where(
            (b) =>
                b.date.compareTo(hoy) < 0 ||
                ['completada', 'cancelada', 'rechazada'].contains(b.status),
          )
          .toList();
    } catch (e) {
      error = 'Error al cargar citas: $e';
      print('BookingViewModel: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarServicios(int idNegocio) async {
    isLoadingServicios = true;
    serviciosSeleccionados.clear();
    notifyListeners();

    try {
      final res = await _supabase
          .from('servicios')
          .select('id_servicio, nombre, precio, duracion')
          .eq('id_negocio', idNegocio)
          .eq('activo', true);
      serviciosDisponibles = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Error cargando servicios: $e');
    } finally {
      isLoadingServicios = false;
      notifyListeners();
    }
  }

  Future<void> cargarProfesionales(int idNegocio) async {
    isLoadingProfesionales = true;
    profesionalSeleccionado = null;
    notifyListeners();

    try {
      final res = await _supabase
          .from('profesionales')
          .select('id_profesional, especialidad, usuarios(nombreUser)')
          .eq('id_negocio', idNegocio);
      profesionalesDisponibles = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Error cargando profesionales: $e');
    } finally {
      isLoadingProfesionales = false;
      notifyListeners();
    }
  }

  void toggleServicio(Map<String, dynamic> servicio) {
    final id = servicio['id_servicio'] as int;
    final existe = serviciosSeleccionados.any((s) => s['id_servicio'] == id);
    if (existe) {
      serviciosSeleccionados.removeWhere((s) => s['id_servicio'] == id);
    } else {
      serviciosSeleccionados.add(servicio);
    }
    notifyListeners();
  }

  double get totalCalculado => serviciosSeleccionados.fold(
    0,
    (sum, s) => sum + (s['precio'] as num).toDouble(),
  );

  int get duracionTotal => serviciosSeleccionados.fold(
    0,
    (sum, s) => sum + (s['duracion'] as int? ?? 30),
  );

  void seleccionarProfesional(Map<String, dynamic> profesional) {
    profesionalSeleccionado = profesional;
    notifyListeners();
    validarDisponibilidad();
  }

  void seleccionarFecha(DateTime fecha) {
    fechaSeleccionada = fecha;
    notifyListeners();
    validarDisponibilidad();
  }

  void seleccionarHora(TimeOfDay hora) {
    horaSeleccionada = hora;
    notifyListeners();
    validarDisponibilidad();
  }

  Future<void> validarDisponibilidad() async {
    if (profesionalSeleccionado == null ||
        fechaSeleccionada == null ||
        horaSeleccionada == null)
      return;

    isValidando = true;
    profesionalOcupado = false;
    notifyListeners();

    try {
      final fechaStr = fechaSeleccionada!.toIso8601String().substring(0, 10);
      final horaStr =
          '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:'
          '${horaSeleccionada!.minute.toString().padLeft(2, '0')}:00';
      final idProfesional = profesionalSeleccionado!['id_profesional'] as int;

      final res = await _supabase
          .from('citas')
          .select('id_cita')
          .eq('id_profesional', idProfesional)
          .eq('fecha_cita', fechaStr)
          .eq('hora', horaStr)
          .not('estado', 'in', '("cancelada","rechazada")');

      profesionalOcupado = (res as List).isNotEmpty;
    } catch (e) {
      print('Error validando disponibilidad: $e');
    } finally {
      isValidando = false;
      notifyListeners();
    }
  }

  bool get formularioValido =>
      serviciosSeleccionados.isNotEmpty &&
      profesionalSeleccionado != null &&
      fechaSeleccionada != null &&
      horaSeleccionada != null &&
      !profesionalOcupado;

  Future<bool> guardarCita(int idNegocio) async {
    if (!formularioValido) return false;

    isGuardando = true;
    errorFormulario = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');

      final usuarioRes = await _supabase
          .from('usuarios')
          .select('id_usuario')
          .eq('auth_id', user.id)
          .single();
      final idUsuario = usuarioRes['id_usuario'] as int;

      final fechaStr = fechaSeleccionada!.toIso8601String().substring(0, 10);
      final horaStr =
          '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:'
          '${horaSeleccionada!.minute.toString().padLeft(2, '0')}:00';
      final idProfesional = profesionalSeleccionado!['id_profesional'] as int;

      // INSERT en citas con el total sumado
      final citaRes = await _supabase
          .from('citas')
          .insert({
            'id_userCliente': idUsuario,
            'id_negocio': idNegocio,
            'id_profesional': idProfesional,
            'fecha_cita': fechaStr,
            'hora': horaStr,
            'total': totalCalculado,
            'estado': 'pendiente',
          })
          .select('id_cita')
          .single();

      final idCita = citaRes['id_cita'] as int;

      // INSERT en detalle_cita — uno por cada servicio seleccionado
      for (final servicio in serviciosSeleccionados) {
        await _supabase.from('detalle_cita').insert({
          'id_cita': idCita,
          'id_servicio': servicio['id_servicio'] as int,
          'cantidad': 1,
          'precio': (servicio['precio'] as num).toDouble(),
        });
      }

      _limpiarFormulario();
      await cargarMisCitas();
      return true;
    } catch (e) {
      errorFormulario = 'Error al guardar la cita: $e';
      print('Error guardando cita: $e');
      return false;
    } finally {
      isGuardando = false;
      notifyListeners();
    }
  }

  // ── Cancelar cita ────────────────────────────────────────────
  Future<bool> cancelarCita(int idCita) async {
    try {
      await _supabase
          .from('citas')
          .update({'estado': 'cancelada'})
          .eq('id_cita', idCita);
      await cargarMisCitas();
      return true;
    } catch (e) {
      print('Error cancelando cita: $e');
      return false;
    }
  }

  Future<void> cancelarCitaConMotivo(int idCita, String motivo) async {
    try {
      await _supabase
          .from('citas')
          .update({'estado': 'cancelada', 'motivo_cancelacion': motivo})
          .eq('id_cita', idCita);
      await cargarMisCitas();
    } catch (e) {
      print('Error cancelando con motivo: $e');
    }
  }

  void _limpiarFormulario() {
    serviciosSeleccionados.clear();
    profesionalSeleccionado = null;
    fechaSeleccionada = null;
    horaSeleccionada = null;
    errorFormulario = null;
    profesionalOcupado = false;
  }
}
