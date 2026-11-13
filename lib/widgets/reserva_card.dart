import 'package:flutter/material.dart';
import '../models/reserva_model.dart';

class ReservaCard extends StatelessWidget {
  final ReservaModel reserva;
  final String? fotoLugarUrl;

  const ReservaCard({
    super.key,
    required this.reserva,
    this.fotoLugarUrl,
  });

  /// Convierte "2026-12-01" a "01/12/2026" para igualar el formato del boceto
  String _formatearFecha(String fechaIso) {
    try {
      final partes = fechaIso.split('T').first.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return fechaIso;
    } catch (_) {
      return fechaIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreCliente = reserva.cliente?.nombreCompleto ?? 'Cliente';
    final noches = reserva.cantidadNoches;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Primera foto del lugar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 85,
                height: 85,
                child: fotoLugarUrl != null && fotoLugarUrl!.isNotEmpty
                    ? Image.network(
                        fotoLugarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(width: 16),

            // 2. Detalles de la reserva (Noches, Fechas, Cliente y Precio Total)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$noches ${noches == 1 ? 'Noche' : 'Noches'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inicio de ${_formatearFecha(reserva.fechaInicio)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                  Text(
                    'Fin de ${_formatearFecha(reserva.fechaFin)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Cliente $nombreCliente',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reserva.precioTotal.toStringAsFixed(0)} \$',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.hotel_outlined,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}