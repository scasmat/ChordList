import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'exito_screen.dart';

class VerificacionScreen extends StatefulWidget {
  const VerificacionScreen({super.key});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  bool _esVerificado = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _verificarEmail());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verificarEmail() async {
    await _auth.currentUser?.reload();
    
    setState(() {
      _esVerificado = _auth.currentUser?.emailVerified ?? false;
    });

    if (_esVerificado) {
      _timer?.cancel();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExitoScreen()),
        );
      }
    }
  }

  Future<void> _reenviarCorreo() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo reenviado exitosamente.")),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyan,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.cyan),
            ),
            const SizedBox(height: 30),
            
            const Text(
              "Verifica tu correo",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            
            Text(
              "Hemos enviado un enlace de confirmación a ${_auth.currentUser?.email ?? 'tu correo'}.\nPor favor entra al enlace y luego presiona el botón de abajo.",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _verificarEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Ya verifiqué mi cuenta", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),
            
            TextButton(
              onPressed: _reenviarCorreo,
              child: const Text("¿No recibiste el correo? Reenviar", style: TextStyle(color: Colors.cyan)),
            ),
          ],
        ),
      ),
    );
  }
}