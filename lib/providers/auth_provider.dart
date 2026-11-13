import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UsuarioModel? _usuario;
  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _errorMessage;

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _usuario != null;

  static const String _storageKey = 'arrendatario_session';

  AuthProvider() {
    verificarSesionGuardada();
  }

  Future<void> verificarSesionGuardada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_storageKey);
      if (userJson != null) {
        _usuario = UsuarioModel.fromJson(jsonDecode(userJson));
      }
    } catch (_) {
      _usuario = null;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      await _guardarSesion(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar({
    required String nombreCompleto,
    required String email,
    required String password,
    required String telefono,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.registro(
        nombreCompleto: nombreCompleto,
        email: email,
        password: password,
        telefono: telefono,
      );
      await _guardarSesion(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _guardarSesion(UsuarioModel user) async {
    _usuario = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}