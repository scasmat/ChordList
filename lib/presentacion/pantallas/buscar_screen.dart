import 'package:flutter/material.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
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
        child: Text("Buscar", style: TextStyle(fontSize: 50, fontFamily: 'Montserrat', color: Color(0xFFFFFFFF)),),
      ),
    );
  }
}