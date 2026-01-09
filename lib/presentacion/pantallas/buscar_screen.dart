import 'package:chordlist/presentacion/pantallas/artista_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuscarScreen extends StatefulWidget {
  final VoidCallback alPresionarAtras;

  const BuscarScreen({super.key, required this.alPresionarAtras});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            GestureDetector(
              onTap: widget.alPresionarAtras,
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
              "Buscar",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    // Convertimos la búsqueda a minúsculas para que coincida con busquedaNombre
                    _query = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Escribe un artista o canción...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _query.isEmpty 
                ? const Center(child: Text("Busca tus canciones o artistas", style: TextStyle(color: Colors.white24)))
                : _buildResultadosBusqueda(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadosBusqueda() {
    return StreamBuilder<QuerySnapshot>(
      // Importante: Usamos 'busquedaNombre' para que la búsqueda sea case-insensitive
      stream: FirebaseFirestore.instance
          .collection('artistas')
          .orderBy('busquedaNombre')
          .startAt([_query])
          .endAt(['$_query\uf8ff'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyan));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No se encontraron resultados", style: TextStyle(color: Colors.white24)));
        }

        final resultados = snapshot.data!.docs;

        return ListView.builder(
          itemCount: resultados.length,
          padding: const EdgeInsets.only(bottom: 100),
          itemBuilder: (context, index) {
            final data = resultados[index].data() as Map<String, dynamic>;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[900],
                backgroundImage: NetworkImage(data['fotoUrl'] ?? ''),
              ),
              title: Text(
                data['nombre'] ?? 'Sin nombre',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                data['genero'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArtistaScreen(
                      artistaId: resultados[index].id, 
                      nombre: data['nombre'] ?? '', 
                      fotoUrl: data['fotoUrl'] ?? '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}