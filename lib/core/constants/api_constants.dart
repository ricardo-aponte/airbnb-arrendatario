class ApiConstants {
  // Dominio raíz del servidor
  static const String serverDomain = 'https://api.airbnbmob2.online';

  // URL base para todas las peticiones de Dio
  static const String baseUrl = '$serverDomain/api';

  /// Normaliza la URL de las fotos para que Image.network() las cargue sin errores
  static String formatImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';

    String cleanUrl = url.trim();

    // Si la BD guardó la URL con localhost:3001, la reemplaza por el dominio real
    if (cleanUrl.contains('http://localhost:3001')) {
      return cleanUrl.replaceFirst('http://localhost:3001', serverDomain);
    }

    if (cleanUrl.contains('http://localhost')) {
      return cleanUrl.replaceFirst('http://localhost', serverDomain);
    }

    // Si ya es una URL completa (http o https), se devuelve tal cual
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    // Si el backend devuelve una ruta relativa (ej: "/fotos/casa.jpg" o "fotos/casa.jpg")
    if (cleanUrl.startsWith('/')) {
      return '$serverDomain$cleanUrl';
    } else {
      return '$serverDomain/$cleanUrl';
    }
  }
}