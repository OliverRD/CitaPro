import 'package:flutter_application_1/domain/usecases/categoria_entity.dart';

class CategoriaModel extends CategoriaEntity {
  const CategoriaModel({
    required super.idCategoria,
    required super.nombreCateg,
    required super.descripcionCateg,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: json['id_categoria'],
      nombreCateg: json['nombreCateg'],
      descripcionCateg: json['descripcionCateg'],
    );
  }
}
