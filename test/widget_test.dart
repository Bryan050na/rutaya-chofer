// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ----- ARREGLO AQUÍ -----
// Importamos el main.dart de nuestro proyecto
import 'package:driver_panel/main.dart'; // Asegúrate que 'driver_panel' sea el nombre de tu proyecto
// ------------------------


void main() {
  testWidgets('Dashboard loads and shows pre-shift state', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // ----- ARREGLO AQUÍ -----
    await tester.pumpWidget(const DriverApp()); // Cambiamos MyApp por DriverApp
    // ------------------------

    // Verifica que el título de la AppBar esté presente.
    expect(find.text('Panel del Chofer | Unidad #1234'), findsOneWidget);

    // Verifica que estemos en el estado "Antes de Iniciar"
    expect(find.text('Control de Turno'), findsOneWidget);
    expect(find.text('Iniciar Turno'), findsOneWidget);

    // Verifica que el mapa placeholder esté inactivo
    expect(find.text('El mapa se activará al iniciar el turno'), findsOneWidget);

    // Verifica que el estado del vehículo esté visible
    expect(find.text('Estado del Vehículo'), findsOneWidget);
    expect(find.text('Combustible'), findsOneWidget);
  });
}