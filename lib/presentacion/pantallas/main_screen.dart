import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chordlist/servicios/auth_service.dart';
import 'package:chordlist/presentacion/pantallas/artista_screen.dart';
import 'package:chordlist/presentacion/pantallas/acordes_screen.dart';
import 'package:chordlist/componentes/searchbar_obj.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _confirmarCierreSesion(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Cerrar sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "¿Estas seguro de cerrar sesión?",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.cerrarSesion();
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.usuarioActual;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121111),
        body: Center(child: Text("Inicia sesión para ver tu historial", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      'https://res.cloudinary.com/ddllxwpf4/image/upload/v1768588247/logo1_wpe7jq.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, StackTrace) {
                        return const Text("ChordList", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                      onPressed: () => _confirmarCierreSesion(context, authService),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: BarraBusquedaSimple(),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text("Canciones recientes", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 220,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('historial_canciones')
                      .orderBy('fecha', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF06A0B5)));
                    
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text("No has tocado canciones aún", style: TextStyle(color: Colors.grey)),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final String savedId = data['id'] ?? docs[index].id;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcordesScreen(
                                  id: savedId,
                                  titulo: data['titulo'] ?? '',
                                  artista: data['artista'] ?? '',
                                  fotoUrl: data['fotoUrl'] ?? '',
                                  contenido: data['contenido'] ?? '', 
                                  audioUrl: data['audioUrl'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data['fotoUrl'] ?? '',
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 140, height: 140, color: Colors.grey[800],
                                      child: const Icon(Icons.music_note, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['titulo'] ?? 'Sin título',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  data['artista'] ?? 'Desconocido',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text("Artistas recientes", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 140,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('historial_artistas')
                      .orderBy('fecha', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF06A0B5)));
                    
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text("No has visitado artistas aún", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistaScreen(
                                  artistaId: data['id'],
                                  nombre: data['nombre'],
                                  fotoUrl: data['fotoUrl'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(data['fotoUrl'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['nombre'] ?? 'Artista',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
    );
  }
}