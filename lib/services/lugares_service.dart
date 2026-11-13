import 'package:dio/dio.dart';
import '../models/lugar_model.dart';
import 'api_client.dart';

class LugaresService {
  /// Obtiene todos los lugares pertenecientes a un arrendatario
  Future<List<LugarModel>> getLugaresPorArrendatario(int arrendatarioId) async {
    try {
      final response = await ApiClient.dio.get(
        '/lugares/arrendatario/$arrendatarioId',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => LugarModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  /// Obtiene el detalle de un lugar por su ID
  Future<LugarModel> getLugarPorId(int lugarId) async {
    try {
      final response = await ApiClient.dio.get('/lugares/$lugarId');
      return LugarModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

/// Crea un lugar nuevo (sin fotos) y devuelve el LugarModel con su nuevo ID
  Future<LugarModel> crearLugar(LugarModel lugar) async {
    try {
      final body = lugar.toJson();
      // Esto imprimirá en la Debug Console de VS Code el JSON exacto enviado
      print('=== ENVIANDO A POST /lugares ===');
      print(body);

      final response = await ApiClient.dio.post(
        '/lugares',
        data: body,
      );
      return LugarModel.fromJson(response.data);
    } on DioException catch (e) {
      print('=== ERROR DEL SERVIDOR ===');
      print('Status: ${e.response?.statusCode}');
      print('Respuesta: ${e.response?.data}');
      throw Exception(_extractError(e));
    }
  }

  /// Actualiza los datos de un lugar existente
  Future<LugarModel> actualizarLugar(int id, LugarModel lugar) async {
    try {
      final response = await ApiClient.dio.put(
        '/lugares/$id',
        data: lugar.toJson(),
      );
      return LugarModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  /// Sube una foto asociada al ID del lugar mediante multipart/form-data
  /// Sube una foto asociada al ID del lugar mediante multipart/form-data
  Future<LugarModel> subirFoto(int lugarId, String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      // No pasamos contentType manual para que Dio agregue el boundary automáticamente
      final response = await ApiClient.dio.post(
        '/lugares/$lugarId/foto',
        data: formData,
      );
      return LugarModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al subir foto: ${_extractError(e)}');
    }
  }

  String _extractError(DioException e) {
    final status = e.response?.statusCode;
    final path = e.requestOptions.path;

    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return '[HTTP $status en $path] ${data['message']}';
        }
        final firstError = data.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return '[HTTP $status en $path] ${firstError.first}';
        }
      }
    }
    return 'Error de servidor ($status) en la ruta $path';
  }
}