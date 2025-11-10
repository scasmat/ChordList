import 'package:flutter/material.dart';

class FavsScreen extends StatefulWidget {
  const FavsScreen({super.key});

  @override
  State<FavsScreen> createState() => _FavsScreenState();
}

class _FavsScreenState extends State<FavsScreen> {
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
        child: Text("Favoritos", style: TextStyle(fontSize: 50, fontFamily: 'Montserrat', color: Color(0xFFFFFFFF)),),
      ),
    );
  }
}