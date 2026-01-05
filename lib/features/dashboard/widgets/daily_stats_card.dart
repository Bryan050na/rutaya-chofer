import 'package:flutter/material.dart';
import '../../../app_constants.dart'; // Para colores

// Tarjeta que muestra las estadísticas del día
class DailyStatsCard extends StatelessWidget {
  const DailyStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Estadísticas del Día",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Podrías pasar estos valores como parámetros si cambian
                _buildStatisticItem("5", "Recorridos"),
                _buildStatisticItem("4.5", "Calificación"),
                _buildStatisticItem("127", "Pasajeros"),
                _buildStatisticItem("95%", "Puntualidad"),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper para construir cada item de estadística
  Widget _buildStatisticItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.colorTextoValor, // Usa constante
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}