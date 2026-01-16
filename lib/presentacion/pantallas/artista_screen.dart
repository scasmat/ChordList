import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chordlist/servicios/historial_service.dart';
import 'acordes_screen.dart';

class ArtistaScreen extends StatefulWidget {
  final String artistaId;
  final String nombre;
  final String fotoUrl;

  const ArtistaScreen({
    super.key,
    required this.artistaId,
    required this.nombre,
    required this.fotoUrl,
  });

  @override
  State<ArtistaScreen> createState() => _ArtistaScreenState();
}

class _ArtistaScreenState extends State<ArtistaScreen> {
  final HistorialService _historialService = HistorialService();

  @override
  void initState() {
    super.initState();
    _registrarVisitaArtista();
  }

  void _registrarVisitaArtista() {
    _historialService.guardarArtista(
      id: widget.artistaId,
      nombre: widget.nombre,
      fotoUrl: widget.fotoUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF1F3445),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.fotoUrl, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF121111)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('artistas')
                .doc(widget.artistaId)
                .collection('canciones')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: Center(child: Text("Error al cargar canciones", style: TextStyle(color: Colors.white))),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF06A0B5))),
                );
              }

              final canciones = snapshot.data!.docs;

              if (canciones.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text("No hay canciones disponibles", style: TextStyle(color: Colors.white))),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final docId = canciones[index].id;
                    var cancion = canciones[index].data() as Map<String, dynamic>;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(cancion['fotoUrl'] ?? widget.fotoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        cancion['titulo'] ?? 'Sin título',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(widget.nombre, style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AcordesScreen(
                              id: docId,
                              titulo: cancion['titulo'] ?? 'Sin título',
                              artista: widget.nombre,
                              contenido: cancion['letra'] ?? '',
                              audioUrl: cancion['audioUrl'] ?? '',
                              fotoUrl: cancion['fotoUrl'] ?? widget.fotoUrl,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: canciones.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}