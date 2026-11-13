import 'foto_model.dart';
import 'reserva_model.dart';
import 'usuario_model.dart';

class LugarModel {
  final int? id;
  final String nombre;
  final String descripcion;
  final int cantPersonas;
  final int cantCamas;
  final int cantBanios;
  final int cantHabitaciones;
  final bool tieneWifi;
  final int cantVehiculosParqueo;
  final double precioNoche;
  final double costoLimpieza;
  final String ciudad;
  final double latitud;
  final double longitud;
  final int arrendatarioId;
  final List<FotoModel> fotos;
  final List<ReservaModel> reservas;
  final UsuarioModel? arrendatario;

  LugarModel({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantPersonas,
    required this.cantCamas,
    required this.cantBanios,
    required this.cantHabitaciones,
    required this.tieneWifi,
    required this.cantVehiculosParqueo,
    required this.precioNoche,
    required this.costoLimpieza,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
    required this.arrendatarioId,
    this.fotos = const [],
    this.reservas = const [],
    this.arrendatario,
  });

  /// Obtiene la primera foto del lugar o null si no tiene fotos
  String? get primeraFotoUrl => fotos.isNotEmpty ? fotos.first.fullUrl : null;

  /// Indica si el lugar cuenta con parqueo
  bool get tieneParqueo => cantVehiculosParqueo > 0;

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  factory LugarModel.fromJson(Map<String, dynamic> json) {
    return LugarModel(
      id: json['id'] != null ? _parseInt(json['id']) : null,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      cantPersonas: _parseInt(json['cantPersonas']),
      cantCamas: _parseInt(json['cantCamas']),
      cantBanios: _parseInt(json['cantBanios']),
      cantHabitaciones: _parseInt(json['cantHabitaciones']),
      tieneWifi: _parseInt(json['tieneWifi']) == 1,
      cantVehiculosParqueo: _parseInt(json['cantVehiculosParqueo']),
      precioNoche: _parseDouble(json['precioNoche']),
      costoLimpieza: _parseDouble(json['costoLimpieza']),
      ciudad: json['ciudad']?.toString() ?? '',
      // Por defecto coordenadas de Santa Cruz si vienen vacías
      latitud: _parseDouble(json['latitud'], -17.7833),
      longitud: _parseDouble(json['longitud'], -63.1821),
      arrendatarioId: _parseInt(json['arrendatario_id']),
      fotos: json['fotos'] != null
          ? (json['fotos'] as List).map((f) => FotoModel.fromJson(f)).toList()
          : [],
      reservas: json['reservas'] != null
          ? (json['reservas'] as List)
              .map((r) => ReservaModel.fromJson(r))
              .toList()
          : [],
      arrendatario: json['arrendatario'] != null
          ? UsuarioModel.fromJson(json['arrendatario'])
          : null,
    );
  }

  /// Cuerpo JSON exacto requerido por POST /api/lugares y PUT /api/lugares/:id
/// Cuerpo JSON exacto requerido por POST /api/lugares y PUT /api/lugares/:id
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'cantPersonas': cantPersonas,
      'cantCamas': cantCamas,
      'cantBanios': cantBanios,
      'cantHabitaciones': cantHabitaciones,
      'tieneWifi': tieneWifi ? 1 : 0,
      'cantVehiculosParqueo': cantVehiculosParqueo,
      'precioNoche': precioNoche,
      'costoLimpieza': costoLimpieza,
      'ciudad': ciudad,
      'latitud': latitud.toStringAsFixed(4),
      'longitud': longitud.toStringAsFixed(4),
      'arrendatario_id': arrendatarioId,
    };
  }
}