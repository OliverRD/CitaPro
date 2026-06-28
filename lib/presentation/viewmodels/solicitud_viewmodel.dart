import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/solicitud_entity.dart';
import 'package:flutter_application_1/data/repositories/solicitud_repository.dart';

class SolicitudViewModel extends ChangeNotifier {
  final SolicitudRepository _repository = SolicitudRepository();

  // Controladores paso 1
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final descripcionController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final whatsappController = TextEditingController();
  final tiktokController = TextEditingController();

  // Controladores paso 2
  final direccionController = TextEditingController();
  final ciudadController = TextEditingController();
  final provinciaController = TextEditingController();
  final referenciaController = TextEditingController();

  String? imagenUrl;
  bool isLoading = false;
  String? error;
  bool enviado = false;

  // Validaciones paso 1
  bool get paso1Valido =>
      nombreController.text.trim().isNotEmpty &&
      descripcionController.text.trim().length >= 20;

  // Validaciones paso 2
  bool get paso2Valido =>
      direccionController.text.trim().isNotEmpty &&
      ciudadController.text.trim().isNotEmpty &&
      provinciaController.text.trim().isNotEmpty;

  void notify() => notifyListeners();

  Future<void> enviarSolicitud({
    required int idUsuario,
    required int idCategoria,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repository.crearSolicitud(
        SolicitudEntity(
          idUsuario: idUsuario,
          idCategoria: idCategoria,
          nombreNegocio: nombreController.text.trim(),
          descripcion: descripcionController.text.trim(),
          instagram: instagramController.text.trim().isEmpty
              ? null
              : instagramController.text.trim(),
          facebook: facebookController.text.trim().isEmpty
              ? null
              : facebookController.text.trim(),
          whatsapp: whatsappController.text.trim().isEmpty
              ? null
              : whatsappController.text.trim(),
          tiktok: tiktokController.text.trim().isEmpty
              ? null
              : tiktokController.text.trim(),
          telefono: telefonoController.text.trim(),
          imagen: imagenUrl,
          direccion: direccionController.text.trim(),
          ciudad: ciudadController.text.trim(),
          provincia: provinciaController.text.trim(),
          referencia: referenciaController.text.trim(),
        ),
      );
      enviado = true;
    } catch (e) {
      error = 'Error al enviar la solicitud. Intenta de nuevo.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    descripcionController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    whatsappController.dispose();
    tiktokController.dispose();
    direccionController.dispose();
    ciudadController.dispose();
    provinciaController.dispose();
    referenciaController.dispose();
    super.dispose();
  }
}
