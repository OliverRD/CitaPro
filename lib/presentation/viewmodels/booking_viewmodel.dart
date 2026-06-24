// lib/presentation/viewmodels/booking_viewmodel.dart
import 'package:flutter/material.dart';

class BookingViewModel extends ChangeNotifier {
  // Aquí creamos la variable que guardará la barbería seleccionada
  String? _barberiaSeleccionada;

  // Un "getter" para poder leer la variable desde las pantallas
  String? get barberiaSeleccionada => _barberiaSeleccionada;

  // Función para cambiar la barbería seleccionada y refrescar las pantallas
  void seleccionarBarberia(String nombreBarberia) {
    _barberiaSeleccionada = nombreBarberia;
    notifyListeners(); // ¡Esto es lo que hace la magia de actualizar la UI!
  }
}