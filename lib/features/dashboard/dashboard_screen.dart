import 'package:flutter/material.dart';
import 'dart:async';
// Asegúrate de tener estas importaciones correctas según tu estructura
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../app_constants.dart';
import '../../models/ruta_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/map_service.dart';
import '../../services/firestore_service.dart';
import '../../services/websocket_service.dart'; // <-- Importa el servicio WebSocket

import 'widgets/left_panel.dart';
import 'widgets/map_panel.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  // --- ESTADO PRINCIPAL DE LA PANTALLA ---
  bool _isShiftActive = false;
  Timer? _locationTimer;
  MapboxMap? _mapboxMap; // Controlador del mapa

  // Estado del GPS y Mapa
  bool _isLoadingMap = true;
  geo.Position? _initialPosition; // Posición inicial

  // Estado de las Rutas
  bool _isLoadingRutas = true;
  List<Ruta> _listaDeRutas = [];
  Ruta? _selectedRutaCompleta; // Ruta seleccionada

  // --- NUEVO: Instancia del servicio WebSocket ---
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _initializeAppState();
    // No conectamos el WebSocket aquí, lo haremos al iniciar turno
  }

  // Función para inicializar todo (GPS y Rutas)
  Future<void> _initializeAppState() async {
    // Carga la ubicación inicial (pide permisos si es necesario)
    _initialPosition = await LocationService.initializeLocation();
    // Verifica si el widget todavía está montado antes de llamar a setState
    if (mounted) {
      setState(() => _isLoadingMap = false);
    }

    // Carga las rutas desde Firestore
    _listaDeRutas = await FirestoreService.cargarRutasActivas();
    // Verifica si el widget todavía está montado antes de llamar a setState
    if (mounted) {
      setState(() => _isLoadingRutas = false);
    }
  }


  @override
  void dispose() {
    _locationTimer?.cancel(); // Detiene el timer al salir
    _webSocketService.disconnect(); // Desconecta WebSocket al salir
    super.dispose();
  }

  // --- LÓGICA DE CONTROL DEL TURNO (MODIFICADA) ---

  // --- MODIFICADO: Ahora es async y espera la conexión ---
  void _startShift() async { // <-- Añade async
    if (_selectedRutaCompleta == null) return;

    // TODO: Considera añadir un estado _isConnecting para mostrar un spinner en el botón
    debugPrint("Iniciando conexión WebSocket...");

    // 1. Intenta conectar y espera el resultado
    bool connected = await _webSocketService.connect(); // <-- Añade await

    // Verifica si el widget sigue montado después de la operación asíncrona
    if (!mounted) return;

    if (!connected) {
      debugPrint("FALLÓ la conexión WebSocket.");
      // Muestra un mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al conectar con el servidor en tiempo real."), backgroundColor: Colors.red),
      );
      // TODO: Resetea el estado si es necesario (ej. _isConnecting = false)
      return; // No continúa si falló la conexión
    }

    debugPrint("Conexión WebSocket exitosa.");

    // 2. Llama a la API HTTP para iniciar (si aún la necesitas)
    // Obtiene la ubicación UNA SOLA VEZ para ambos mensajes
    final coords = await LocationService.getCurrentLocation();
    ApiService.iniciarRuta(
      rutaId: _selectedRutaCompleta!.nombre,
      lat: coords.latitude,
      lng: coords.longitude,
    );

    // --- MODIFICADO: Envía mensaje de INICIO con ubicación y status ---
    _webSocketService.sendStartShiftMessage(
      unidadId: AppConstants.unidadId,
      lat: coords.latitude,
      lng: coords.longitude,
      timestamp: DateTime.now(), // Usa el tiempo actual para el status
    );
    // --- FIN MODIFICADO ---


    // 3. Actualiza UI y empieza el loop de ubicación (SOLO si conectó bien)
    if(mounted){
      setState(() => _isShiftActive = true);
    }
    _iniciarLoopDeUbicacion();
  }
  // --- FIN MODIFICADO ---


  // --- MODIFICADO: Obtiene ubicación antes de enviar mensaje de fin ---
  void _endShift() async { // <-- Añade async
    _detenerLoopDeUbicacion(); // Para el timer

    // --- Obtiene la última ubicación ANTES de desconectar ---
    final coords = await LocationService.getCurrentLocation();

    // --- Envía mensaje de FIN con ubicación y status ---
    _webSocketService.sendEndShiftMessage(
      unidadId: AppConstants.unidadId,
      lat: coords.latitude,
      lng: coords.longitude,
      timestamp: DateTime.now(), // Usa el tiempo actual para el status
    );
    // --- FIN MODIFICADO ---

    _webSocketService.disconnect(); // Desconecta el socket

    ApiService.terminarRuta(); // Llama a la API HTTP (si aún la necesitas)
    MapService.limpiarRutaDelMapa(mapboxMap: _mapboxMap);

    if(mounted){
      setState(() {
        _isShiftActive = false;
        _selectedRutaCompleta = null;
      });
    }
  }
  // --- FIN MODIFICADO ---


  // Inicia el Timer para enviar ubicación periódicamente
  void _iniciarLoopDeUbicacion() {
    debugPrint("Iniciando loop de actualización cada 15 segundos...");
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // Verifica si el widget sigue montado y el turno activo
      if (mounted && _isShiftActive) {
        _actualizarUbicacionYEnviar(); // Llama a la función que actualiza todo
      } else {
        timer.cancel(); // Detiene el timer si el turno ya no está activo o el widget se desmontó
      }
    });
  }

  // Detiene el Timer
  void _detenerLoopDeUbicacion() {
    debugPrint("Deteniendo loop de actualización...");
    _locationTimer?.cancel();
  }

  // --- Envía SOLO ubicación cada 15 seg ---
  Future<void> _actualizarUbicacionYEnviar() async {
    // Verifica si el widget sigue montado
    if(!mounted) return;

    geo.Position coords = await LocationService.getCurrentLocation(); // Obtiene GPS

    // Mueve la cámara del mapa (solo si _mapboxMap no es nulo)
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(coords.longitude, coords.latitude)),
        zoom: 16, // Puedes ajustar el zoom si quieres
      ),
      MapAnimationOptions(duration: 1500), // Animación suave
    );

    // Llama a la función que SÓLO envía ubicación
    _webSocketService.sendLocationUpdate(
        unidadId: AppConstants.unidadId,
        lat: coords.latitude,
        lng: coords.longitude,
        timestamp: coords.timestamp); // Usa el timestamp del GPS para la coordenada
  }


  // --- MANEJO DE EVENTOS DE WIDGETS HIJOS ---

  // Se llama cuando el mapa está listo
  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    // Configura el 'Puck' (punto azul de ubicación)
    // Verifica si el widget sigue montado
    if(mounted){
      _mapboxMap?.location.updateSettings(LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.COURSE,
      ));
    }

    // Si ya había una ruta seleccionada (raro pero posible), la dibuja
    if (_selectedRutaCompleta != null) {
      MapService.dibujarRutaEnMapa(
          mapboxMap: _mapboxMap,
          waypointsString: _selectedRutaCompleta!.waypoints
      );
    }
  }

  // Se llama cuando se selecciona una ruta en el Dropdown
  void _onRouteSelected(Ruta? ruta) {
    // Verifica si el widget sigue montado
    if(!mounted) return;

    if (ruta == null) {
      // Si deseleccionan, limpia la ruta del mapa
      MapService.limpiarRutaDelMapa(mapboxMap: _mapboxMap);
      setState(() => _selectedRutaCompleta = null);
      return;
    };
    setState(() => _selectedRutaCompleta = ruta);

    // Dibuja la ruta seleccionada en el mapa
    MapService.dibujarRutaEnMapa(
        mapboxMap: _mapboxMap,
        waypointsString: ruta.waypoints
    );
  }


  // --- CONSTRUCCIÓN DE LA INTERFAZ ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.colorPrimario,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.directions_bus),
            const SizedBox(width: 10),
            Text("Panel del Chofer | Unidad #${AppConstants.unidadId}"),
          ],
        ),
        actions: [
          // Botón "Fuera de Servicio" (llama a _endShift)
          TextButton(
            onPressed: _isShiftActive ? _endShift : null, // Llama a _endShift
            style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withOpacity(0.5)),
            child: const Text("Fuera de Servicio"),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Salir",
            onPressed: () {
              // TODO: Añadir lógica de logout o cierre si es necesario
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Row(
        children: [
          // Panel Izquierdo (ahora es un widget separado)
          LeftPanel(
            isShiftActive: _isShiftActive,
            isLoadingRutas: _isLoadingRutas,
            listaDeRutas: _listaDeRutas,
            selectedRuta: _selectedRutaCompleta,
            onRouteSelected: _onRouteSelected, // Pasa la función callback
            onStartShift: _startShift,       // Pasa la función callback
            onEndShift: _endShift,         // Pasa la función callback
          ),

          // Panel del Mapa (ahora es un widget separado)
          MapPanel(
            isLoadingMap: _isLoadingMap,
            initialPosition: _initialPosition,
            isShiftActive: _isShiftActive,
            onMapCreated: _onMapCreated, // Pasa la función callback
          ),
        ],
      ),
    );
  }
}