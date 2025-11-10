import 'package:chordlist/presentacion/pantallas/buscar_screen.dart';
import 'package:chordlist/presentacion/pantallas/favs_screen.dart';
import 'package:flutter/material.dart';
import 'package:chordlist/presentacion/pantallas/main_screen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _paginaActual = 0;

  final List<Widget> _pantallas = [
    const MainScreen(),
    const BuscarScreen(),
    const FavsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF121111),
        body: Column(
          children: [
            Expanded(
              child: _pantallas[_paginaActual],
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFF121111),
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Color(0xFF06A0B5), spreadRadius: 0, blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Color(0xFFFFFFFF),
                  unselectedItemColor: Colors.grey,
                  onTap: (index){
                    setState(() {
                      _paginaActual = index;
                    });
                  },
                  currentIndex: _paginaActual,
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
                    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoritos"),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
