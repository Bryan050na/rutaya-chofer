import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Para debugPrint
import '../app_constants.dart'; // Importa constantes

// Lógica para interactuar con tus endpoints de API REST
class ApiService {

  // --- 1. Endpoint: INICIAR RUTA ---
  static Future<void> iniciarRuta({
    required String? rutaId,
    required double lat,
    required double lng,
  }) async {
    const String url = "${AppConstants.apiBaseUrl}/ruta/iniciar";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "unidadId": AppConstants.unidadId,
          "rutaId": rutaId,
          "status": "activo",
          "coordenadaInicial": {"lat": lat, "lng": lng},
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("API: Ruta iniciada exitosamente.");
      } else {
        debugPrint("Error al iniciar ruta: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al iniciar ruta: $e");
    }
  }

  // --- 2. Endpoint: ACTUALIZAR UBICACIÓN ---
  static Future<void> actualizarUbicacion({
    required double lat,
    required double lng,
    required DateTime timestamp,
  }) async {
    const String url = "${AppConstants.apiBaseUrl}/ruta/actualizar";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "unidadId": AppConstants.unidadId,
          "coordenada": {"lat": lat, "lng": lng},
          "timestamp": timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("API: Ubicación actualizada.");
      } else {
        debugPrint("Error al actualizar ubicación: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al actualizar ubicación: $e");
    }
  }

  // --- 3. Endpoint: TERMINAR RUTA ---
  static Future<void> terminarRuta() async {
    const String url = "${AppConstants.apiBaseUrl}/ruta/terminar";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "unidadId": AppConstants.unidadId,
          "status": "inactivo",
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        debugPrint("API: Ruta terminada exitosamente.");
      } else {
        debugPrint("Error al terminar ruta: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al terminar ruta: $e");
    }
  }
}