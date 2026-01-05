import 'package:flutter/material.dart'; // Para debugPrint
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert'; // Para jsonEncode
import 'dart:async'; // Para Completer

// Servicio para manejar la conexión WebSocket
class WebSocketService {
  WebSocketChannel? _channel;
  // --- URL DE PRUEBA (ECO) ---
  final String _websocketUrl = "ws://10.0.2.2:4211";
  // --- TU URL REAL (COMENTADA) ---
  // final String _websocketUrl = "ws://tu-servidor-websocket.com/ruta";

  // --- Variables para el estado de la conexión ---
  Completer<void>? _connectionCompleter;
  bool _isConnected = false;

  Future<bool> connect() async {
    // Si ya está conectado o conectando, no hagas nada
    if (_isConnected || (_connectionCompleter != null && !_connectionCompleter!.isCompleted)) {
      debugPrint("WebSocket ya está conectado o conectándose.");
      return _isConnected;
    }

    _connectionCompleter = Completer<void>(); // Inicia el completer
    _isConnected = false; // Resetea el estado

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(_websocketUrl));
      debugPrint("WebSocket Conectando a $_websocketUrl...");

      _channel?.stream.listen(
            (message) {
          debugPrint("WebSocket Recibido: $message");
          if (!_isConnected) {
            _isConnected = true;
            _connectionCompleter?.complete();
            debugPrint("WebSocket Conexión confirmada.");
          }
        },
        onDone: () {
          debugPrint("WebSocket Desconectado (onDone).");
          _isConnected = false;
          _channel = null;
          if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
            _connectionCompleter?.completeError("Desconectado antes de confirmar (onDone).");
            debugPrint("WebSocket Completer finalizado con error (onDone).");
          }
        },
        onError: (error) {
          debugPrint("WebSocket Error: $error");
          _isConnected = false;
          _channel = null;
          if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
            _connectionCompleter?.completeError(error);
            debugPrint("WebSocket Completer finalizado con error (onError).");
          }
        },
      );

      await _connectionCompleter?.future.timeout(const Duration(seconds: 10), onTimeout: (){
        debugPrint("WebSocket Timeout al conectar.");
        _isConnected = false;
        _channel?.sink.close();
        _channel = null;
        if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
          _connectionCompleter?.completeError("Timeout al conectar.");
        }
        throw TimeoutException('WebSocket connection timed out');
      });
      return _isConnected;

    } catch (e) {
      debugPrint("Excepción al conectar WebSocket: $e");
      _isConnected = false;
      _channel = null;
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter?.completeError(e);
      }
      return false;
    }
  }

  // --- MODIFICADO: Envía ubicación y status al INICIAR ---
  void sendStartShiftMessage({
    required String unidadId,
    required double lat,
    required double lng,
    required DateTime timestamp,
  }) {
    if (_isConnected && _channel != null) {
      final data = {
        "unidadId": unidadId,
        "coordenada": {"lat": lat, "lng": lng},
        "status": "activo", // <-- Status activo
        "timestamp": timestamp.toIso8601String(),
      };
      final message = jsonEncode(data);
      _channel!.sink.add(message);
      debugPrint("WebSocket Enviado (Inicio): $message");
    } else {
      debugPrint("WebSocket no conectado. No se pudo enviar mensaje de inicio.");
    }
  }

  // --- MODIFICADO: Envía SOLO ubicación durante el turno ---
  void sendLocationUpdate({
    required String unidadId,
    required double lat,
    required double lng,
    required DateTime timestamp,
  }) {
    if (_isConnected && _channel != null) {
      final data = {
        // "type": "locationUpdate", // <-- Quitado
        "unidadId": unidadId,
        "coordenada": {"lat": lat, "lng": lng},
        "timestamp": timestamp.toIso8601String(),
      };
      final message = jsonEncode(data);
      _channel!.sink.add(message);
      // debugPrint("WebSocket Enviado (Update): $message"); // Puedes quitar esto
    } else {
      debugPrint("WebSocket no conectado. No se pudo enviar ubicación.");
    }
  }

  // --- MODIFICADO: Envía ubicación y status al FINALIZAR ---
  void sendEndShiftMessage({
    required String unidadId,
    required double lat, // <-- Añadido
    required double lng, // <-- Añadido
    required DateTime timestamp,
  }) {
    if (_isConnected && _channel != null) {
      final data = {
        "unidadId": unidadId,
        "coordenada": {"lat": lat, "lng": lng}, // <-- Añadido
        "status": "inactivo", // <-- Status inactivo
        "timestamp": timestamp.toIso8601String(),
      };
      final message = jsonEncode(data);
      _channel!.sink.add(message);
      debugPrint("WebSocket Enviado (Fin): $message");
    } else {
      debugPrint("WebSocket no conectado. No se pudo enviar mensaje de fin.");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
      _isConnected = false;
      _connectionCompleter = null;
      debugPrint("WebSocket Desconectado intencionalmente.");
    } else {
      debugPrint("WebSocket ya estaba desconectado o nunca se conectó.");
      _isConnected = false;
      _connectionCompleter = null;
    }
  }
}