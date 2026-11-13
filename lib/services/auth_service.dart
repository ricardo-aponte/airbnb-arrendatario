import 'package:dio/dio.dart';
import '../models/usuario_model.dart';
import 'api_client.dart';

class AuthService {
  Future<UsuarioModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/arrendatario/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );
      return UsuarioModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<UsuarioModel> registro({
    required String nombreCompleto,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/arrendatario/registro',
        data: {
          'nombrecompleto': nombreCompleto.trim(),
          'email': email.trim(),
          'password': password,
          'telefono': telefono.trim(),
        },
      );
      return UsuarioModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          if (e.response?.statusCode == 500) {
            return 'El correo electrónico ya está registrado o hubo un error en el servidor.';
          }
          return data['message'].toString();
        }
        // Errores de validación de Laravel (status 404 en el mock)
        final firstErrorList = data.values.first;
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          return firstErrorList.first.toString();
        }
      }
    }
    return 'Error de conexión con el servidor. Verifica que Mockoon esté activo.';
  }
}