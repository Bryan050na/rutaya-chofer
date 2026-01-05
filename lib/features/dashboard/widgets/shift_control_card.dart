import 'package:flutter/material.dart';
import '../../../models/ruta_model.dart';
import '../../../app_constants.dart'; // Para colores

// Tarjeta que contiene el Dropdown y el botón de "Iniciar Turno"
class ShiftControlCard extends StatelessWidget {
  final bool isLoadingRutas;
  final List<Ruta> listaDeRutas;
  final Ruta? selectedRuta;
  final ValueChanged<Ruta?> onRouteSelected; // Callback selección
  final VoidCallback onStartShift;        // Callback iniciar

  const ShiftControlCard({
    super.key,
    required this.isLoadingRutas,
    required this.listaDeRutas,
    required this.selectedRuta,
    required this.onRouteSelected,
    required this.onStartShift,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Control de Turno",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Selecciona tu Ruta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),

            // Dropdown para seleccionar la ruta
            DropdownButtonFormField<String>(
              value: selectedRuta?.nombre, // Muestra el nombre de la ruta seleccionada
              hint: Text(isLoadingRutas ? "Cargando rutas..." : "Elige una ruta"),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              disabledHint: Text(isLoadingRutas ? "Cargando rutas..." : "No hay rutas activas"),
              // Genera los items desde la lista de Rutas
              items: isLoadingRutas || listaDeRutas.isEmpty
                  ? []
                  : listaDeRutas.map((Ruta ruta) {
                      return DropdownMenuItem<String>(
                        value: ruta.nombre, // El valor es el nombre
                        child: Text(ruta.nombre),
                      );
                    }).toList(),
              onChanged: (String? nombreSeleccionado) {
                 if (nombreSeleccionado == null) {
                   onRouteSelected(null); // Llama al callback con null si deselecciona
                   return;
                 }
                 // Busca el objeto Ruta completo basado en el nombre
                 final rutaCompleta = listaDeRutas.firstWhere(
                   (r) => r.nombre == nombreSeleccionado,
                   orElse: () => listaDeRutas.first, // Fallback por si acaso
                 );
                 onRouteSelected(rutaCompleta); // Llama al callback con la ruta completa
              },
            ),

            const SizedBox(height: 20),
            // Botón de Iniciar Turno
            ElevatedButton(
              // Se deshabilita si no hay ruta seleccionada
              onPressed: selectedRuta == null ? null : onStartShift,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded),
                  SizedBox(width: 8),
                  Text("Iniciar Turno", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}