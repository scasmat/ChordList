import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReproductorObj extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String titulo;
  final String artista;
  final String fotoUrl;
  final String audioUrl;
  final VoidCallback alCerrar;

  const ReproductorObj({
    super.key,
    required this.audioPlayer,
    required this.titulo,
    required this.artista,
    required this.fotoUrl,
    required this.audioUrl,
    required this.alCerrar,
  });

  @override
  State<ReproductorObj> createState() => _ReproductorObjState();
}

class _ReproductorObjState extends State<ReproductorObj> {
  bool estaReproduciendo = false;
  bool estaDescargado = false; 
  Duration posicion = Duration.zero;
  Duration duracionTotal = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    estaReproduciendo = widget.audioPlayer.state == PlayerState.playing;

    widget.audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => duracionTotal = d);
    });

    widget.audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => posicion = p);
    });

    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => estaReproduciendo = state == PlayerState.playing);
      }
    });
  }

  void _togglePlay() async {
    if (estaReproduciendo) {
      await widget.audioPlayer.pause();
    } else {
      if (widget.audioPlayer.source == null) {
        await widget.audioPlayer.play(UrlSource(widget.audioUrl));
      } else {
        await widget.audioPlayer.resume();
      }
    }
  }

  String _formatearTiempo(Duration duration) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    final minutos = dosDigitos(duration.inMinutes.remainder(60));
    final segundos = dosDigitos(duration.inSeconds.remainder(60));
    return "$minutos:$segundos";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F3445).withOpacity(0.98),
      child: Column(
        children: [
          const SizedBox(height: 50),
          IconButton(
            onPressed: widget.alCerrar,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 40),
          ),
          const Spacer(),
          CachedNetworkImage(
            imageUrl: widget.fotoUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
          ),
          const SizedBox(height: 30),
          Text(widget.titulo, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(widget.artista, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Slider(
                  value: posicion.inSeconds.toDouble().clamp(0, duracionTotal.inSeconds.toDouble() > 0 ? duracionTotal.inSeconds.toDouble() : 1),
                  max: duracionTotal.inSeconds.toDouble() > 0 ? duracionTotal.inSeconds.toDouble() : 1.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  onChanged: (val) async {
                    await widget.audioPlayer.seek(Duration(seconds: val.toInt()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatearTiempo(posicion), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      Text(_formatearTiempo(duracionTotal), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!estaDescargado)
            IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white, size: 50),
              onPressed: () => setState(() => estaDescargado = true),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.equalizer, color: Colors.white, size: 30),
                IconButton(
                  icon: Icon(estaReproduciendo ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white, size: 70),
                  onPressed: _togglePlay,
                ),
                const Icon(Icons.repeat, color: Colors.white, size: 30),
              ],
            ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}