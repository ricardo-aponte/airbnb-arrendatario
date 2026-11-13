import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/foto_model.dart';
import '../../models/lugar_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lugares_provider.dart';
import 'mapa_selector_screen.dart';
import '../reservas/reservas_lugar_screen.dart';

class LugarFormScreen extends StatefulWidget {
  final LugarModel? lugarExistente;

  const LugarFormScreen({super.key, this.lugarExistente});

  @override
  State<LugarFormScreen> createState() => _LugarFormScreenState();
}

class _LugarFormScreenState extends State<LugarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _ciudadCtrl;
  late TextEditingController _cantPersonasCtrl;
  late TextEditingController _cantCamasCtrl;
  late TextEditingController _cantBaniosCtrl;
  late TextEditingController _cantHabitacionesCtrl;
  late TextEditingController _cantParqueoCtrl;
  late TextEditingController _precioNocheCtrl;
  late TextEditingController _costoLimpiezaCtrl;

  bool _tieneWifi = false;
  bool _tieneParqueo = false;
  LatLng? _ubicacionSeleccionada;

  List<FotoModel> _fotosRemotas = [];
  final List<XFile> _fotosNuevas = [];

  bool get _esEdicion => widget.lugarExistente != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lugarExistente;

    _nombreCtrl = TextEditingController(text: l?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: l?.descripcion ?? '');
    _ciudadCtrl = TextEditingController(text: l?.ciudad ?? 'Santa Cruz');
    _cantPersonasCtrl = TextEditingController(
      text: l != null ? l.cantPersonas.toString() : '1',
    );
    _cantCamasCtrl = TextEditingController(
      text: l != null ? l.cantCamas.toString() : '1',
    );
    _cantBaniosCtrl = TextEditingController(
      text: l != null ? l.cantBanios.toString() : '1',
    );
    _cantHabitacionesCtrl = TextEditingController(
      text: l != null ? l.cantHabitaciones.toString() : '1',
    );
    _cantParqueoCtrl = TextEditingController(
      text: l != null ? l.cantVehiculosParqueo.toString() : '1',
    );
    _precioNocheCtrl = TextEditingController(
      text: l != null ? l.precioNoche.toStringAsFixed(2) : '',
    );
    _costoLimpiezaCtrl = TextEditingController(
      text: l != null ? l.costoLimpieza.toStringAsFixed(2) : '',
    );

    if (l != null) {
      _tieneWifi = l.tieneWifi;
      _tieneParqueo = l.cantVehiculosParqueo > 0;
      _ubicacionSeleccionada = LatLng(l.latitud, l.longitud);
      _fotosRemotas = List.from(l.fotos);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _ciudadCtrl.dispose();
    _cantPersonasCtrl.dispose();
    _cantCamasCtrl.dispose();
    _cantBaniosCtrl.dispose();
    _cantHabitacionesCtrl.dispose();
    _cantParqueoCtrl.dispose();
    _precioNocheCtrl.dispose();
    _costoLimpiezaCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFotos() async {
    final List<XFile> seleccionadas = await _picker.pickMultiImage(
      imageQuality: 80,
    );
    if (seleccionadas.isNotEmpty) {
      setState(() {
        _fotosNuevas.addAll(seleccionadas);
      });
    }
  }

  Future<void> _abrirMapa() async {
    final LatLng inicial = _ubicacionSeleccionada ??
        const LatLng(-17.7833, -63.1821);

    final LatLng? resultado = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapaSelectorScreen(ubicacionInicial: inicial),
      ),
    );

    if (resultado != null) {
      setState(() {
        _ubicacionSeleccionada = resultado;
      });
    }
  }

  Future<void> _guardarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_esEdicion && _fotosNuevas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar al menos 1 foto para el lugar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_ubicacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar la ubicación en el mapa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) return;

    final int vehiculos = _tieneParqueo
        ? (int.tryParse(_cantParqueoCtrl.text.trim()) ?? 1)
        : 0;

    final nuevoLugar = LugarModel(
      id: widget.lugarExistente?.id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
      cantPersonas: int.tryParse(_cantPersonasCtrl.text.trim()) ?? 1,
      cantCamas: int.tryParse(_cantCamasCtrl.text.trim()) ?? 1,
      cantBanios: int.tryParse(_cantBaniosCtrl.text.trim()) ?? 1,
      cantHabitaciones: int.tryParse(_cantHabitacionesCtrl.text.trim()) ?? 1,
      tieneWifi: _tieneWifi,
      cantVehiculosParqueo: vehiculos,
      precioNoche: double.tryParse(_precioNocheCtrl.text.trim()) ?? 0.0,
      costoLimpieza: double.tryParse(_costoLimpiezaCtrl.text.trim()) ?? 0.0,
      latitud: _ubicacionSeleccionada!.latitude,
      longitud: _ubicacionSeleccionada!.longitude,
      arrendatarioId: usuario.id,
    );

    final lugaresProvider = context.read<LugaresProvider>();
    final exito = await lugaresProvider.guardarLugar(
      lugar: nuevoLugar,
      rutasFotosNuevas: _fotosNuevas.map((x) => x.path).toList(),
      esEdicion: _esEdicion,
    );

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Lugar actualizado correctamente'
                  : 'Lugar creado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lugaresProvider.errorMessage ?? 'Error al guardar el lugar',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LugaresProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Lugar' : 'Nuevo Lugar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Sección de Fotos
              const Text(
                'Fotos del Lugar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildGaleriaFotos(),
              const SizedBox(height: 20),

              // 2. Datos Generales
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del lugar',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ciudadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // 3. Capacidad y Distribución
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _cantPersonasCtrl,
                      label: 'Personas',
                      icon: Icons.people_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _cantHabitacionesCtrl,
                      label: 'Habitaciones',
                      icon: Icons.meeting_room_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _cantCamasCtrl,
                      label: 'Camas',
                      icon: Icons.bed_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _cantBaniosCtrl,
                      label: 'Baños',
                      icon: Icons.bathtub_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Servicios (Wi-Fi y Parqueo)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('¿Tiene Wi-Fi?'),
                secondary: const Icon(Icons.wifi),
                value: _tieneWifi,
                onChanged: (val) => setState(() => _tieneWifi = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('¿Tiene Parqueo?'),
                secondary: const Icon(Icons.directions_car_outlined),
                value: _tieneParqueo,
                onChanged: (val) => setState(() => _tieneParqueo = val),
              ),
              if (_tieneParqueo) ...[
                const SizedBox(height: 8),
                _buildNumberField(
                  controller: _cantParqueoCtrl,
                  label: 'Parqueo para cuántos vehículos',
                  icon: Icons.garage_outlined,
                ),
              ],
              const SizedBox(height: 16),

              // 5. Precios
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _precioNocheCtrl,
                      label: 'Precio noche (\$)',
                      icon: Icons.attach_money,
                      isDecimal: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _costoLimpiezaCtrl,
                      label: 'Costo limpieza (\$)',
                      icon: Icons.cleaning_services_outlined,
                      isDecimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Botón de Ubicación en el Mapa
              OutlinedButton.icon(
                onPressed: _abrirMapa,
                icon: Icon(
                  _ubicacionSeleccionada != null
                      ? Icons.check_circle
                      : Icons.map_outlined,
                  color: _ubicacionSeleccionada != null
                      ? Colors.green
                      : Colors.redAccent,
                ),
                label: Text(
                  _ubicacionSeleccionada != null
                      ? 'Ubicación seleccionada (${_ubicacionSeleccionada!.latitude.toStringAsFixed(4)}, ${_ubicacionSeleccionada!.longitude.toStringAsFixed(4)})'
                      : 'Seleccionar Ubicación en mapa',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              // 7. Botón Guardar
              ElevatedButton(
                onPressed: isLoading ? null : _guardarFormulario,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 16),
                      ),
              ),

             
// 8. Botón Ver Reservas (Solo en modo edición)
              if (_esEdicion) ...[
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReservasLugarScreen(
                                lugar: widget.lugarExistente!,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Ver reservas'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGaleriaFotos() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Fotos que ya existen en el servidor (Modo Edición)
          ..._fotosRemotas.map(
            (foto) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  foto.fullUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ),

          // Fotos nuevas seleccionadas desde el teléfono
          ..._fotosNuevas.asMap().entries.map((entry) {
            final index = entry.key;
            final xfile = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(xfile.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _fotosNuevas.removeAt(index);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Botón [+] para agregar fotos
          InkWell(
            onTap: _seleccionarFotos,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.redAccent),
                  SizedBox(height: 4),
                  Text('Agregar', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Requerido';
        }
        final num? parsed = isDecimal
            ? double.tryParse(value.trim())
            : int.tryParse(value.trim());
        if (parsed == null || parsed < 0) {
          return 'Número inválido';
        }
        return null;
      },
    );
  }
}