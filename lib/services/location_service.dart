import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart'; // Para debugPrint

// Lógica para interactuar con el GPS usando Geolocator
class LocationService {

  // Ubicación por defecto si falla el GPS (Los Mochis)
  static final geo.Position _defaultPosition = geo.Position(
    longitude: -108.9859,
    latitude: 25.7904,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  // Obtiene la posición GPS actual
  static Future<geo.Position> getCurrentLocation() async {
    try {
      // Intenta obtener la ubicación de alta precisión
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high
      );
      debugPrint("Ubicación GPS real: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      // Si falla, intenta obtener la última conocida o usa la por defecto
      debugPrint("Error al obtener GPS: $e. Usando última conocida o default.");
      geo.Position? lastPosition = await geo.Geolocator.getLastKnownPosition();
      return lastPosition ?? _defaultPosition;
    }
  }

  // Pide permisos y obtiene la ubicación inicial
  static Future<geo.Position> initializeLocation() async {
    geo.LocationPermission permission;

    // 1. Revisa si ya tiene permisos
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      // 2. Si no, pide permiso
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        // 3. Si lo niega, usa la ubicación por defecto
        debugPrint("Permiso de GPS denegado.");
        return _defaultPosition;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      // 4. Si lo niega permanentemente, usa la por defecto
      debugPrint("Permiso de GPS denegado permanentemente.");
      return _defaultPosition;
    }

    // 5. Si tiene permiso, obtiene la ubicación actual
    try {
      return await getCurrentLocation();
    } catch (e) {
      debugPrint("Error al obtener la ubicación inicial: $e");
      return _defaultPosition;
    }
  }
}