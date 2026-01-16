import 'package:flutter/material.dart';

class PitchObj extends StatelessWidget {
  final double pitchActual;
  final Function(double) alCambiarPitch;
  final VoidCallback alCerrar;

  const PitchObj({
    super.key,
    required this.pitchActual,
    required this.alCerrar,
    required this.alCambiarPitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3445),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transpose", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              IconButton(onPressed: alCerrar, icon: const Icon(Icons.close, color: Colors.white, size: 20)),
            ],
          ),
          Text(
            "${pitchActual > 0 ? '+' : ''}${pitchActual.toInt()}",
            style: const TextStyle(color: Colors.cyan, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const Text("semitonos", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: () => pitchActual > -5 ? alCambiarPitch(pitchActual - 1) : null,
              ),
              Expanded(
                child: Slider(
                  value: pitchActual,
                  min: -5.0,
                  max: 5.0,
                  divisions: 10,
                  activeColor: Colors.cyan,
                  inactiveColor: Colors.white24,
                  onChanged: alCambiarPitch,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => pitchActual < 5 ? alCambiarPitch(pitchActual + 1) : null,
              ),
            ],
          ),
          TextButton(
            onPressed: () => alCambiarPitch(0),
            child: const Text("Resetear", style: TextStyle(color: Colors.white38)),
          )
        ],
      ),
    );
  }
}