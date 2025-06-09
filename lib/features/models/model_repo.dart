import 'dart:convert';

import 'package:http/http.dart' as http;

import 'model.dart';

class ModelRepository {
  final String baseUrl = 'https://myprinter.tr/db/getAllModels';

  Future<List<Model>> fetchModels() async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Model.fromJson(e)).toList();
    } else {
      throw Exception('Modeller alınamadı');
    }
  }
}
