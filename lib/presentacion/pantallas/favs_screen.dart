import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'acordes_screen.dart';

class FavScreen extends StatelessWidget {
  final VoidCallback alPresionarAtras;

  const FavScreen({super.key, required this.alPresionarAtras});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            GestureDetector(
              onTap: alPresionarAtras,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F1F1F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Favoritos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (user == null)
              const Expanded(
                child: Center(
                  child: Text(
                    "Inicia sesión para ver tus favoritos",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('favoritos')
                      .orderBy('fecha', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error al cargar", style: TextStyle(color: Colors.white)));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white24));
                    }

                    final favs = snapshot.data!.docs;

                    if (favs.isEmpty) {
                      return const Center(
                        child: Text("No tienes favoritos aún", style: TextStyle(color: Colors.white24)),
                      );
                    }

                    return ListView.builder(
                      itemCount: favs.length,
                      padding: const EdgeInsets.only(bottom: 120),
                      itemBuilder: (context, index) {
                        var data = favs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AcordesScreen(
                                titulo: data['titulo'] ?? 'Sin título',
                                artista: data['artista'] ?? 'Desconocido',
                                contenido: data['contenido'] ?? '',
                                audioUrl: data['audioUrl'] ?? '',
                                fotoUrl: data['fotoUrl'] ?? '',
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data['fotoUrl'] ?? 'https://via.placeholder.com/150',
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.music_note, color: Colors.white),
                            ),
                          ),
                          title: Text(
                            data['titulo'] ?? 'Sin título',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          subtitle: Text(
                            data['artista'] ?? 'Desconocido',
                            style: const TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                          trailing: const Icon(Icons.favorite, color: Colors.cyan),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}