import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chordlist/componentes/reproductor_obj.dart';

class AcordesScreen extends StatefulWidget {
  final String titulo;
  final String artista;
  final String contenido;
  final String audioUrl;
  final String fotoUrl;

  const AcordesScreen({
    super.key,
    required this.titulo,
    required this.artista,
    required this.contenido,
    required this.audioUrl,
    required this.fotoUrl,
  });

  @override
  State<AcordesScreen> createState() => _AcordesScreenState();
}

class _AcordesScreenState extends State<AcordesScreen> {
  bool mostrarBarras = true;
  bool mostrarReproductor = false;
  bool mostrarSidebar = false;
  bool esFavorito = false;
  int semitonosActuales = 0;
  
  late AudioPlayer _globalAudioPlayer;
  final List<String> _notas = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  @override
  void initState() {
    super.initState();
    _globalAudioPlayer = AudioPlayer();
    _verificarFavorito();
  }

  @override
  void dispose() {
    _globalAudioPlayer.stop();
    _globalAudioPlayer.dispose();
    super.dispose();
  }

  void _verificarFavorito() async {
    final String docId = "${widget.artista}_${widget.titulo}".replaceAll(' ', '_');
    final doc = await FirebaseFirestore.instance.collection('favoritos').doc(docId).get();
    if (mounted) {
      setState(() => esFavorito = doc.exists);
    }
  }

  void _toggleFavorito() async {
    final String docId = "${widget.artista}_${widget.titulo}".replaceAll(' ', '_');
    final ref = FirebaseFirestore.instance.collection('favoritos').doc(docId);

    if (esFavorito) {
      await ref.delete();
    } else {
      await ref.set({
        'titulo': widget.titulo,
        'artista': widget.artista,
        'fotoUrl': widget.fotoUrl,
        'audioUrl': widget.audioUrl,
        'contenido': widget.contenido,
        'fecha': FieldValue.serverTimestamp(),
      });
    }
    
    if (mounted) {
      setState(() => esFavorito = !esFavorito);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esFavorito ? "Agregado a favoritos" : "Eliminado de favoritos"),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF1F3445),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => mostrarBarras = !mostrarBarras),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
                child: RichText(
                  text: TextSpan(
                    children: _parsearContenido(widget.contenido, semitonosActuales),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 3.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (mostrarBarras) _buildAppBar(),
          if (mostrarBarras) _buildBottomBar(),
          if (mostrarSidebar) _buildSideBar(),

          if (mostrarReproductor)
            Positioned.fill(
              child: ReproductorObj(
                audioPlayer: _globalAudioPlayer,
                titulo: widget.titulo,
                artista: widget.artista,
                fotoUrl: widget.fotoUrl,
                audioUrl: widget.audioUrl,
                alCerrar: () => setState(() => mostrarReproductor = false),
              ),
            ),
        ],
      ),
    );
  }

  List<InlineSpan> _parsearContenido(String texto, int transporte) {
    List<InlineSpan> spans = [];
    final regExp = RegExp(r'\[(.*?)\]');
    int lastMatchEnd = 0;

    for (var match in regExp.allMatches(texto)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: texto.substring(lastMatchEnd, match.start),
        ));
      }

      String acordeOriginal = match.group(1)!;
      String acordeTranspuesto = _transponerAcorde(acordeOriginal, transporte);

      spans.add(WidgetSpan(
        child: Transform.translate(
          offset: const Offset(0, -14),
          child: Text(
            acordeTranspuesto,
            style: const TextStyle(
              color: Color(0xFFE57E31),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < texto.length) {
      spans.add(TextSpan(text: texto.substring(lastMatchEnd)));
    }
    return spans;
  }

  String _transponerAcorde(String acorde, int semitonos) {
    if (semitonos == 0) return acorde;
    return acorde.replaceAllMapped(RegExp(r'[A-G]#?'), (match) {
      String notaActual = match.group(0)!;
      int index = _notas.indexOf(notaActual);
      if (index == -1) return notaActual;
      int nuevoIndex = (index + semitonos) % 12;
      if (nuevoIndex < 0) nuevoIndex += 12;
      return _notas[nuevoIndex];
    });
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 50, bottom: 15, left: 10, right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F3445).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(widget.artista, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: _toggleFavorito,
              icon: Icon(
                esFavorito ? Icons.star : Icons.star_border,
                color: esFavorito ? Colors.yellow : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 25, left: 25, right: 25,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1F3445),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.music_note, color: Colors.white),
              onPressed: () => setState(() => mostrarReproductor = true),
            ),
            const Icon(Icons.auto_awesome_motion, color: Colors.transparent),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () => setState(() => mostrarSidebar = !mostrarSidebar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBar() {
    return Positioned(
      right: 15, top: 200,
      child: Container(
        width: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1F3445).withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            _btnSidebar("-1", () => setState(() => semitonosActuales--)),
            _btnSidebar("+1", () => setState(() => semitonosActuales++)),
            _btnSidebar("0", () => setState(() => semitonosActuales = 0)),
          ],
        ),
      ),
    );
  }

  Widget _btnSidebar(String label, VoidCallback tap) {
    return TextButton(
      onPressed: tap,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}