import 'package:dio/dio.dart';
import '../models/reserva_model.dart';
import 'api_client.dart';

class ReservasService {
  /// Obtiene la lista de reservas de un lugar específico por su ID
  Future<List<ReservaModel>> getReservasPorLugar(int lugarId) async {
    try {
      final response = await ApiClient.dio.get('/reservas/lugar/$lugarId');
      final data = response.data;

      // Según el backend, devuelve el objeto Lugar con la clave "reservas" adentro
      if (data is Map<String, dynamic> && data['reservas'] is List) {
        return (data['reservas'] as List)
            .map((json) => ReservaModel.fromJson(json))
            .toList();
      }

      // Respaldo por si el endpoint devolviera una lista directa
      if (data is List) {
        return data.map((json) => ReservaModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      // Si devuelve 404 ("Reserva no encontrada"), retornamos lista vacía
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('No se pudieron cargar las reservas del lugar.');
    }
  }
}