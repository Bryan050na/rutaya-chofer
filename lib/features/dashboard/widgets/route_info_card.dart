import 'package:flutter/material.dart';
import '../../../models/ruta_model.dart';
import '../../../app_constants.dart'; // Para colores

// Tarjeta que muestra la información de la ruta (descripción o mensaje)
class RouteInfoCard extends StatelessWidget {
  final bool isActive; // Para saber si mostrar descripción o mensaje
  final Ruta? selectedRuta; // La ruta seleccionada

  const RouteInfoCard({
    super.key,
    required this.isActive,
    this.selectedRuta, // Es opcional si isActive es false
  });

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
                Icon(Icons.route_outlined, color: AppConstants.colorPrimario),
                const SizedBox(width: 8),
                Text(
                  "Información de Ruta",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Muestra descripción o mensaje según 'isActive'
            if (isActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ruta Actual: ${selectedRuta?.nombre ?? 'N/A'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    selectedRuta?.descripcion ?? 'Cargando descripción...',
                    style: const TextStyle(fontSize: 16)
                  ),
                ],
              )
            else
              // Mensaje cuando el turno no ha iniciado
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Inicia tu turno para ver la información de ruta",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}