import '../core/constants/api_constants.dart';

class FotoModel {
  final int id;
  final String url;
  final int lugarId;

  FotoModel({
    required this.id,
    required this.url,
    required this.lugarId,
  });

  /// Devuelve la URL lista para usar en Image.network()
  String get fullUrl => ApiConstants.formatImageUrl(url);

  factory FotoModel.fromJson(Map<String, dynamic> json) {
    return FotoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      url: json['url']?.toString() ?? '',
      lugarId: json['lugar_id'] is int
          ? json['lugar_id']
          : int.tryParse(json['lugar_id']?.toString() ?? '0') ?? 0,
    );
  }
}