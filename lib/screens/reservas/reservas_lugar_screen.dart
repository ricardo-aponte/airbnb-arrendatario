import 'package:flutter/material.dart';
import '../../models/lugar_model.dart';
import '../../models/reserva_model.dart';
import '../../services/reservas_service.dart';
import '../../widgets/reserva_card.dart';

class ReservasLugarScreen extends StatefulWidget {
  final LugarModel lugar;

  const ReservasLugarScreen({
    super.key,
    required this.lugar,
  });

  @override
  State<ReservasLugarScreen> createState() => _ReservasLugarScreenState();
}

class _ReservasLugarScreenState extends State<ReservasLugarScreen> {
  final ReservasService _reservasService = ReservasService();

  List<ReservaModel> _reservas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    if (widget.lugar.id == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lista = await _reservasService.getReservasPorLugar(widget.lugar.id!);
      setState(() {
        _reservas = lista;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas - ${widget.lugar.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarReservas,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarReservas,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reservas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarReservas,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Icon(Icons.event_busy_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Este lugar aún no tiene reservas registradas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservas,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _reservas.length,
        itemBuilder: (context, index) {
          final reserva = _reservas[index];
          return ReservaCard(
            reserva: reserva,
            fotoLugarUrl: widget.lugar.primeraFotoUrl,
          );
        },
      ),
    );
  }
}