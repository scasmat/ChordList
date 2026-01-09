import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chordlist/componentes/searchbar_obj.dart';
import 'package:flutter/material.dart';
import 'package:chordlist/presentacion/pantallas/artista_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("ChordList", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: const Icon(Icons.account_circle_outlined, color: Colors.white),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const BarraBusquedaSimple(),
              const SizedBox(height: 30),
              const Text("Abiertas recientemente",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCard("Es Tiempo", "Hillsong en Español"),
                    _buildCard("Tómalo", "Hillsong en Español"),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text("Artistas Recientes",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              SizedBox(
                height: 170,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('artistas').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Text('Error', style: TextStyle(color: Colors.white));
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return _buildArtistaCircle(context, docs[index].id, data['nombre'] ?? '', data['fotoUrl'] ?? '');
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String titulo, String subtitulo) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Icon(Icons.music_note, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
          Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildArtistaCircle(BuildContext context, String id, String nombre, String urlImagen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistaScreen(artistaId: id, nombre: nombre, fotoUrl: urlImagen)));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundColor: Colors.grey[900], backgroundImage: NetworkImage(urlImagen)),
            const SizedBox(height: 8),
            Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}