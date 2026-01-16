import 'package:flutter/material.dart';
import 'package:chordlist/servicios/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _cargando = false;
  String? _error;

  void _iniciarSesion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final authService = AuthService();
    final user = await authService.iniciarSesion(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _cargando = false);

    if (user != null) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _error = "Correo o contraseña incorrectos.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
                      'https://res.cloudinary.com/ddllxwpf4/image/upload/v1768587569/Logo_clggzj.png',
                      height: 170,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, StackTrace) {
                        return const Text("ChordList", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
                      },
                    ),
            const SizedBox(height: 50),
            const Text(
              "Iniciar Sesión",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 50),

            _InputGenerico(controller: _emailController, hint: "Ingresa tu correo electrónico"),
            const SizedBox(height: 20),

            _InputGenerico(
              controller: _passwordController, 
              hint: "Contraseña", 
              isPassword: true
            ),
            
            const SizedBox(height: 10),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _cargando ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06A0B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _cargando 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Iniciar Sesión", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
             
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                },
                child: 
                const Text("¿Olvidaste tu contraseña?",
                style: TextStyle(color: Color(0xFFB50016),
                  shadows: [Shadow(color: Color(0xFFB50016), blurRadius: 20)],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InputGenerico extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;

  const _InputGenerico({required this.controller, required this.hint, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}