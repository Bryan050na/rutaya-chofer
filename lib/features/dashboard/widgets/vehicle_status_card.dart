import 'package:flutter/material.dart';
import '../../../app_constants.dart'; // Para colores

// Tarjeta que muestra el estado del vehículo (combustible, GPS, etc.)
class VehicleStatusCard extends StatelessWidget {
  const VehicleStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus_filled, color: AppConstants.colorPrimario),
                const SizedBox(width: 8),
                Text(
                  "Estado del Vehículo",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Filas de estado (podrías hacerlas dinámicas si cambian)
            _buildStatusRow("Combustible", "75%", AppConstants.colorPrimario),
            _buildStatusRow("Capacidad", "Medio", AppConstants.colorSecundario),
            _buildStatusRow("GPS", "Activo", AppConstants.colorPrimario),
            _buildStatusRow("Estado General", "Operativo", AppConstants.colorPrimario),
          ],
        ),
      ),
    );
  }

  // Helper para construir cada fila de estado
  Widget _buildStatusRow(String title, String status, Color pillColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}