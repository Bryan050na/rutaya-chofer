import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Para debugPrint
import '../models/ruta_model.dart'; // Importa la clase Ruta

// Lógica para interactuar con Firestore
class FirestoreService {

  // Carga las rutas activas desde la colección 'rutas'
  static Future<List<Ruta>> cargarRutasActivas() async {
    List<Ruta> items = [];
    try {
      // 1. Ejecuta la consulta
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rutas')
          .where('activo', isEqualTo: 1) // Filtra activas
          .orderBy('nombre') // Ordena por nombre
          .get();

      // 2. Procesa los documentos
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // 3. Verifica y lee los campos
        String nombreRuta = data.containsKey('nombre') ? data['nombre'] : 'Ruta Desconocida';
        String descripcionRuta = data.containsKey('descripcion') ? data['descripcion'] : 'Sin descripción';
        String waypointsRuta = data.containsKey('waypoints') ? data['waypoints'] : '';

        // 4. Crea el objeto Ruta y lo añade a la lista
        items.add(
          Ruta(
            nombre: nombreRuta,
            descripcion: descripcionRuta,
            waypoints: waypointsRuta
          ),
        );
      }
      debugPrint("Rutas cargadas desde Firebase: ${items.length}");
    } catch (e) {
      debugPrint("Error al cargar rutas de Firebase: $e");
      // Devuelve una lista vacía si hay error
    }
    return items;
  }
}