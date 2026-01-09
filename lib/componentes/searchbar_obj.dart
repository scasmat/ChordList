import 'package:flutter/material.dart';
import 'package:chordlist/presentacion/pantallas/buscar_screen.dart';

class BarraBusquedaSimple extends StatelessWidget {
  const BarraBusquedaSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuscarScreen(
              alPresionarAtras: () => Navigator.pop(context),
            ),
          ),
        );
      },
      child: AbsorbPointer(
        child: SearchBar(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(color: Colors.white),
          ),
          hintText: "Buscar canciones o artistas",
          hintStyle: WidgetStatePropertyAll(
            TextStyle(color: Colors.grey[600]),
          ),
          leading: const Icon(Icons.search, color: Colors.grey),
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF1E1E1E)),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}