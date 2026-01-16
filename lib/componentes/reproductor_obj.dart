import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pitch_obj.dart';
import 'dart:math' as math;

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
  bool esBucle = false;
  bool mostrarPitch = false;
  double semitonos = 0.0;
  
  Duration posicion = Duration.zero;
  Duration duracionTotal = Duration.zero;

  @override
  void initState() {
    super.initState();
    _inicializarAudio();
        
    widget.audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => posicion = p);
    });

    widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          estaReproduciendo = state.playing;
        });
      }
    });
    
    widget.audioPlayer.durationStream.listen((d) {
      if (mounted && d != null) setState(() => duracionTotal = d);
    });
  }

  Future<void> _inicializarAudio() async {
    try {
      if (widget.audioPlayer.audioSource == null) {
        await widget.audioPlayer.setUrl(widget.audioUrl);
        widget.audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error cargando audio: $e");
    }
  }

  void _togglePlay() {
    if (widget.audioPlayer.playing) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
  }

  void _cambiarPitch(double nuevoValor) {
    setState(() {
      semitonos = nuevoValor;
      double pitchFactor = math.pow(2, semitonos / 12).toDouble();
      widget.audioPlayer.setPitch(pitchFactor); 
    });
  }

  void _toggleBucle() {
    setState(() {
      esBucle = !esBucle;
      widget.audioPlayer.setLoopMode(esBucle ? LoopMode.one : LoopMode.off);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F3445),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              IconButton(
                onPressed: widget.alCerrar,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 40),
              ),
              const Spacer(),
              CachedNetworkImage(
                imageUrl: widget.fotoUrl,
                imageBuilder: (context, img) => Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: img, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(height: 30),
              Text(widget.titulo, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(widget.artista, style: const TextStyle(color: Colors.white54, fontSize: 16)),
              
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        activeColor: Colors.cyan,
                        inactiveColor: Colors.white24,
                        min: 0,
                        max: duracionTotal.inSeconds > 0 ? duracionTotal.inSeconds.toDouble() : 1.0,
                        value: math.min(posicion.inSeconds.toDouble(), duracionTotal.inSeconds > 0 ? duracionTotal.inSeconds.toDouble() : 1.0),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await widget.audioPlayer.seek(position);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatoDuracion(posicion), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(_formatoDuracion(duracionTotal), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.waves, color: mostrarPitch ? Colors.cyan : Colors.white, size: 35),
                      onPressed: () => setState(() => mostrarPitch = !mostrarPitch),
                    ),
                    IconButton(
                      icon: Icon(estaReproduciendo ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white, size: 85),
                      onPressed: _togglePlay,
                    ),
                    IconButton(
                      icon: Icon(Icons.repeat, color: esBucle ? Colors.cyan : Colors.white, size: 35),
                      onPressed: _toggleBucle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mostrarPitch)
            Positioned(
              bottom: 160, left: 0, right: 0,
              child: PitchObj(
                pitchActual: semitonos,
                alCambiarPitch: _cambiarPitch,
                alCerrar: () => setState(() => mostrarPitch = false),
              ),
            ),
        ],
      ),
    );
  }

  String _formatoDuracion(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}