import 'package:flutter/material.dart';
import '../../../models/ruta_model.dart';
import 'shift_control_card.dart'; // Importa la tarjeta de control
import 'active_shift_widgets.dart'; // Importa los widgets de turno activo
import 'vehicle_status_card.dart'; // Importa la tarjeta de estado

// Widget que construye todo el panel izquierdo
class LeftPanel extends StatelessWidget {
  final bool isShiftActive;
  final bool isLoadingRutas;
  final List<Ruta> listaDeRutas;
  final Ruta? selectedRuta;
  final ValueChanged<Ruta?> onRouteSelected; // Callback para selección
  final VoidCallback onStartShift;        // Callback para iniciar turno
  final VoidCallback onEndShift;          // Callback para terminar turno

  const LeftPanel({
    super.key,
    required this.isShiftActive,
    required this.isLoadingRutas,
    required this.listaDeRutas,
    required this.selectedRuta,
    required this.onRouteSelected,
    required this.onStartShift,
    required this.onEndShift,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380, // Ancho fijo del panel
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView( // Permite scroll si hay mucho contenido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Muestra un widget u otro dependiendo si el turno está activo
            if (isShiftActive)
              // Widgets cuando el turno está ACTIVO
              ActiveShiftWidgets(
                selectedRuta: selectedRuta,
                onEndShift: onEndShift, // Pasa el callback
              )
            else
              // Tarjeta para INICIAR turno
              ShiftControlCard(
                isLoadingRutas: isLoadingRutas,
                listaDeRutas: listaDeRutas,
                selectedRuta: selectedRuta,
                onRouteSelected: onRouteSelected, // Pasa el callback
                onStartShift: onStartShift,       // Pasa el callback
              ),
            const SizedBox(height: 20),
            // Tarjeta de estado del vehículo (siempre visible)
            const VehicleStatusCard(),
          ],
        ),
      ),
    );
  }
}