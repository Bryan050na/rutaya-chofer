import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../app_constants.dart'; // Para el color del spinner

// Widget que construye el panel derecho con el mapa
class MapPanel extends StatelessWidget {
  final bool isLoadingMap;
  final geo.Position? initialPosition;
  final bool isShiftActive;
  final MapCreatedCallback onMapCreated; // Callback cuando el mapa está listo

  const MapPanel({
    super.key,
    required this.isLoadingMap,
    required this.initialPosition,
    required this.isShiftActive,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    // Usa Expanded para llenar el espacio restante
    return Expanded(
      child: Stack(
        children: [
          // Muestra spinner o mapa según el estado
          if (isLoadingMap)
            Center(
              child: CircularProgressIndicator(color: AppConstants.colorPrimario),
            )
          else if (initialPosition == null) // Fallback si initialPosition es nulo
             const Center(child: Text("Error al obtener ubicación inicial"))
          else
            MapWidget(
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(initialPosition!.longitude, initialPosition!.latitude)),
                zoom: 16.0,
              ),
              onMapCreated: onMapCreated, // Llama al callback del padre
            ),

          // Muestra overlay si el turno está inactivo
          if (!isShiftActive)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, color: Colors.white, size: 80),
                    SizedBox(height: 20),
                    Text(
                      "El mapa se activará al iniciar el turno",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}