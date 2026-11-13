import 'usuario_model.dart';

class ReservaModel {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final double precioTotal;
  final double precioLimpieza;
  final double precioNoches;
  final double precioServicio;
  final UsuarioModel? cliente;

  ReservaModel({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioTotal,
    required this.precioLimpieza,
    required this.precioNoches,
    required this.precioServicio,
    this.cliente,
  });

  /// Calcula la cantidad de noches entre fechaInicio y fechaFin
  int get cantidadNoches {
    try {
      final inicio = DateTime.parse(fechaInicio);
      final fin = DateTime.parse(fechaFin);
      final diferencia = fin.difference(inicio).inDays;
      return diferencia > 0 ? diferencia : 1;
    } catch (_) {
      return 1;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      fechaInicio: json['fechaInicio']?.toString() ?? '',
      fechaFin: json['fechaFin']?.toString() ?? '',
      precioTotal: _parseDouble(json['precioTotal']),
      precioLimpieza: _parseDouble(json['precioLimpieza']),
      precioNoches: _parseDouble(json['precioNoches']),
      precioServicio: _parseDouble(json['precioServicio']),
      cliente: json['cliente'] != null
          ? UsuarioModel.fromJson(json['cliente'])
          : null,
    );
  }
}