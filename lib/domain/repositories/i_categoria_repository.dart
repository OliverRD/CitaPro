import 'package:flutter_application_1/domain/usecases/categoria_entity.dart';

abstract class ICategoriaRepository {
  Future<List<CategoriaEntity>> getCategorias();
}
