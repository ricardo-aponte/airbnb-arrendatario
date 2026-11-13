import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lugares_provider.dart';
import '../../widgets/lugar_card.dart';
import 'lugar_form_screen.dart';

class MisLugaresScreen extends StatefulWidget {
  const MisLugaresScreen({super.key});

  @override
  State<MisLugaresScreen> createState() => _MisLugaresScreenState();
}

class _MisLugaresScreenState extends State<MisLugaresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarLugares();
    });
  }

  Future<void> _cargarLugares() async {
    final usuario = context.read<AuthProvider>().usuario;
    if (usuario != null) {
      await context.read<LugaresProvider>().cargarMisLugares(usuario.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final lugaresProvider = context.watch<LugaresProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Lugares Disponibles'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _cargarLugares,
          ),
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: _buildBody(lugaresProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LugarFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(LugaresProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarLugares,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.misLugares.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarLugares,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Icon(Icons.home_work_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Aún no tienes lugares registrados.\nPresiona el botón (+) para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarLugares,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: provider.misLugares.length,
        itemBuilder: (context, index) {
          final lugar = provider.misLugares[index];
          return LugarCard(
            lugar: lugar,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LugarFormScreen(lugarExistente: lugar),
                ),
              );
            },
          );
        },
      ),
    );
  }
}