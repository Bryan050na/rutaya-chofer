import 'dart:convert';
import 'package:flutter/material.dart'; // Para debugPrint y Color
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../app_constants.dart'; // Para el color

// Lógica para interactuar con Mapbox (Map Matching, añadir/quitar capas)
class MapService {

  // Dibuja la ruta en el mapa usando la API de Map Matching
  static Future<void> dibujarRutaEnMapa({
    required MapboxMap? mapboxMap,
    required String waypointsString,
  }) async {
    // 1. Limpia cualquier ruta anterior
    await limpiarRutaDelMapa(mapboxMap: mapboxMap);

    // 2. Limpia y valida el string de waypoints
    String coordinatesApiString = waypointsString.replaceAll('"', '');
    if (coordinatesApiString.isEmpty) {
      debugPrint("No hay waypoints para dibujar la ruta.");
      return;
    }

    // 3. Prepara la URL para la API
    String? accessToken = dotenv.env["MAPBOX_ACCESS_TOKEN"];
    if (accessToken == null || accessToken.isEmpty) {
       debugPrint("Error: MAPBOX_ACCESS_TOKEN no encontrado en .env");
       return;
    }
    String encodedWaypoints = Uri.encodeComponent(coordinatesApiString);
    String url = "https://api.mapbox.com/matching/v5/mapbox/driving/$encodedWaypoints?geometries=geojson&overview=full&access_token=$accessToken";

    debugPrint("Llamando a Map Matching API...");

    try {
      // 4. Llama a la API
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['matchings'] == null || data['matchings'].isEmpty) {
          debugPrint("Map Matching no encontró coincidencias.");
          return;
        }

        // 5. Obtiene la geometría
        var geometry = data['matchings'][0]['geometry'];

        // 6. Prepara la fuente GeoJSON
        Map<String, dynamic> geoJsonSourceData = {
          "type": "Feature",
          "geometry": geometry
        };

        // 7. Añade fuente y capa al mapa
        await mapboxMap?.style.addSource(
          GeoJsonSource(id: "route-source", data: jsonEncode(geoJsonSourceData))
        );

        await mapboxMap?.style.addLayer(
          LineLayer(
            id: "route-layer",
            sourceId: "route-source",
            lineColor: AppConstants.colorPrimario.value, // Usa el color de constantes
            lineWidth: 6.0,
            lineOpacity: 0.8
          )
        );
        debugPrint("Ruta dibujada en el mapa.");

      } else {
        debugPrint("Error de Map Matching API: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al dibujar ruta: $e");
    }
  }

  // Limpia la capa y la fuente de la ruta del mapa
  static Future<void> limpiarRutaDelMapa({required MapboxMap? mapboxMap}) async {
    try {
      // Intenta remover la capa y la fuente, ignorando si no existen
      await mapboxMap?.style.removeStyleLayer("route-layer");
      await mapboxMap?.style.removeStyleSource("route-source");
      debugPrint("Ruta limpiada del mapa.");
    } catch (e) {
      // Es normal que falle si la capa/fuente no existían
      debugPrint("Info al limpiar ruta (puede ser normal): $e");
    }
  }
}