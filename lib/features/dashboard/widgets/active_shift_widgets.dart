import 'package:flutter/material.dart';
import '../../../models/ruta_model.dart';
import 'route_info_card.dart'; // Importa la tarjeta de info de ruta
import 'daily_stats_card.dart'; // Importa la tarjeta de estadísticas

// Agrupa los widgets que se muestran cuando el turno está activo
class ActiveShiftWidgets extends StatelessWidget {
  final Ruta? selectedRuta;
  final VoidCallback onEndShift; // Callback para terminar turno

  const ActiveShiftWidgets({
    super.key,
    required this.selectedRuta,
    required this.onEndShift,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tarjeta con la descripción de la ruta
        RouteInfoCard(isActive: true, selectedRuta: selectedRuta),
        const SizedBox(height: 20),
        // Tarjeta de estadísticas
        const DailyStatsCard(),
        const SizedBox(height: 20),
        // Botón de Terminar Turno
        ElevatedButton(
          onPressed: onEndShift, // Llama al callback del padre
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stop_circle_outlined),
              SizedBox(width: 8),
              Text("Terminar Turno", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}