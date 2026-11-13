class UsuarioModel {
  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;

  UsuarioModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombreCompleto: json['nombrecompleto']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombrecompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
    };
  }
}