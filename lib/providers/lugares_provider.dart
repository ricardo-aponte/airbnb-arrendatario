import 'package:flutter/material.dart';
import '../models/lugar_model.dart';
import '../services/lugares_service.dart';

class LugaresProvider extends ChangeNotifier {
  final LugaresService _lugaresService = LugaresService();

  List<LugarModel> _misLugares = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LugarModel> get misLugares => _misLugares;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga la lista de lugares del arrendatario desde la API
  Future<void> cargarMisLugares(int arrendatarioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _misLugares = await _lugaresService.getLugaresPorArrendatario(arrendatarioId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda un lugar (creación o edición) y sube las fotos nuevas seleccionadas
Future<bool> guardarLugar({
    required LugarModel lugar,
    required List<String> rutasFotosNuevas,
    bool esEdicion = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      LugarModel lugarGuardado;

      // 1. Guardar los datos del lugar (POST o PUT)
      if (esEdicion && lugar.id != null) {
        lugarGuardado = await _lugaresService.actualizarLugar(lugar.id!, lugar);
      } else {
        lugarGuardado = await _lugaresService.crearLugar(lugar);
      }

      // 2. Intentar subir cada foto por separado
      if (lugarGuardado.id != null && rutasFotosNuevas.isNotEmpty) {
        for (final ruta in rutasFotosNuevas) {
          try {
            await _lugaresService.subirFoto(lugarGuardado.id!, ruta);
          } catch (fotoError) {
            // Guardamos la advertencia pero no cancelamos la creación del lugar
            _errorMessage = fotoError.toString().replaceFirst('Exception: ', '');
          }
        }
      }

      // 3. Recargar siempre la lista para ver el lugar creado
      await cargarMisLugares(lugar.arrendatarioId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}