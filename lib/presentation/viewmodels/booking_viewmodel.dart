import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart'; // Ajusta la ruta de tu modelo si es necesario

class BookingViewModel extends ChangeNotifier {
  String _barberiaSeleccionada = '';
  
  // 🔥 Las listas ahora viven aquí y no se borrarán al cambiar de pantalla
  final List<Booking> _upcomingBookings = [];
  final List<Booking> _pastBookings = [];

  String get barberiaSeleccionada => _barberiaSeleccionada;
  List<Booking> get upcomingBookings => _upcomingBookings;
  List<Booking> get pastBookings => _pastBookings;

  void seleccionarBarberia(String nombre) {
    _barberiaSeleccionada = nombre;
    notifyListeners();
  }

  // 🔥 Método para confirmar y trasladar la cita de forma segura
  void confirmarCita(Booking booking) {
    booking.status = 'Activo'; 
    _pastBookings.add(booking);
    _upcomingBookings.remove(booking);
    _barberiaSeleccionada = ''; // Limpiamos la selección activa de la Home
    notifyListeners(); // Notifica a todas las pantallas el cambio en tiempo real
  }

  // 🔥 Método para remover la cita al cancelar
  void cancelarCita(Booking booking) {
    _upcomingBookings.remove(booking);
    _pastBookings.remove(booking);
    _barberiaSeleccionada = '';
    notifyListeners();
  }
}