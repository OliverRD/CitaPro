import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/domain/repositories/i_categoria_repository.dart';
import 'package:flutter_application_1/domain/usecases/categoria_entity.dart';
import 'package:flutter_application_1/data/models/categoria_model.dart';

class CategoriaRepository implements ICategoriaRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<CategoriaEntity>> getCategorias() async {
    final response = await _supabase
        .from('categorias')
        .select('id_categoria, "nombreCateg", "descripcionCateg"');

    return (response as List)
        .map((json) => CategoriaModel.fromJson(json))
        .toList();
  }
}
