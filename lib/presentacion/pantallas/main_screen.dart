import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  int cantidadclicks = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF121111),
      appBar: AppBar(
        backgroundColor: Color(0xFF121111),
        centerTitle: false,
        title: Image.asset(
          'recursos/imagenes/icon/logo1.png',
          height: 40,
        )
      ),
      body: Center(
        child: Text("Inicio", style: TextStyle(fontSize: 50, fontFamily: 'Montserrat', color: Color(0xFFFFFFFF)),),
      ),
    );
  }
}