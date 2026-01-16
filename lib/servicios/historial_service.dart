import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarCancion({
    required String id,
    required String titulo,
    required String artista,
    required String fotoUrl,
    String contenido = '', 
    String audioUrl = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('historial_canciones')
          .doc(id)
          .set({
        'id': id,
        'titulo': titulo,
        'artista': artista,
        'fotoUrl': fotoUrl,
        'contenido': contenido,
        'audioUrl': audioUrl,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al guardar canción en historial: $e");
    }
  }
  Future<void> guardarArtista({
    required String id,
    required String nombre,
    required String fotoUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('historial_artistas')
          .doc(id)
          .set({
        'id': id,
        'nombre': nombre,
        'fotoUrl': fotoUrl,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al guardar artista en historial: $e");
    }
  }
}