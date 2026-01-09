import 'package:flutter/material.dart';
import 'package:chordlist/presentacion/pantallas/main_screen.dart';
import 'package:chordlist/presentacion/pantallas/buscar_screen.dart';
import 'package:chordlist/presentacion/pantallas/favs_screen.dart';

class TabsNavigationBar extends StatefulWidget {
  const TabsNavigationBar({super.key});

  @override
  State<TabsNavigationBar> createState() => _TabsNavigationBarState();
}

class _TabsNavigationBarState extends State<TabsNavigationBar> {
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    // Definimos las pantallas aquí dentro para poder usar setState
    final List<Widget> _pantallas = [
      const MainScreen(),
      BuscarScreen(alPresionarAtras: () {
        setState(() {
          _paginaActual =0;
        });
      }),
      FavScreen(alPresionarAtras: () {
        setState(() {
          _paginaActual = 0; // Regresa a la pestaña de Inicio
        });
      }),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      // Usar IndexedStack evita que las pantallas se reinicien al cambiar de pestaña
      body: IndexedStack(
        index: _paginaActual,
        children: _pantallas,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF121111),
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Color(0xFF06A0B5), spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFFFFFFF),
            unselectedItemColor: Colors.grey,
            currentIndex: _paginaActual,
            onTap: (index) {
              setState(() {
                _paginaActual = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoritos"),
            ],
          ),
        ),
      ),
    );
  }
}