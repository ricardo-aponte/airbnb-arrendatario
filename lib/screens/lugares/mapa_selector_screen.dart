import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaSelectorScreen extends StatefulWidget {
  final LatLng ubicacionInicial;

  const MapaSelectorScreen({
    super.key,
    // Coordenadas por defecto en Santa Cruz (-17.7833, -63.1821)
    this.ubicacionInicial = const LatLng(-17.7833, -63.1821),
  });

  @override
  State<MapaSelectorScreen> createState() => _MapaSelectorScreenState();
}

class _MapaSelectorScreenState extends State<MapaSelectorScreen> {
  late LatLng _ubicacionSeleccionada;

  @override
  void initState() {
    super.initState();
    _ubicacionSeleccionada = widget.ubicacionInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context, _ubicacionSeleccionada);
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _ubicacionSeleccionada,
              initialZoom: 14.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _ubicacionSeleccionada = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nur.airbnb_arrendatario',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _ubicacionSeleccionada,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Toca en el mapa para mover el marcador',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lat: ${_ubicacionSeleccionada.latitude.toStringAsFixed(5)} | '
                      'Lng: ${_ubicacionSeleccionada.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, _ubicacionSeleccionada);
                        },
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Guardar esta ubicación'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}