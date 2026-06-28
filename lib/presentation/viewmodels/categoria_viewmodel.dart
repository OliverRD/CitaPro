import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/usecases/categoria_entity.dart';
import 'package:flutter_application_1/data/repositories/categoria_repository.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaRepository _repository = CategoriaRepository();

  List<CategoriaEntity> categorias = [];
  CategoriaEntity? selectedCategoria;
  bool isLoading = false;
  String? error;

  Future<void> loadCategorias() async {
    isLoading = true;
    notifyListeners();

    try {
      categorias = await _repository.getCategorias();
      error = null;
    } catch (e) {
      error = 'Error al cargar categorías';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCategoria(CategoriaEntity categoria) {
    selectedCategoria = categoria;
    notifyListeners();
  }
}
