import 'package:flutter/material.dart';
import 'package:chordlist/servicios/auth_service.dart';
import 'verificacion_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _cargando = false;

  void _registrarYEnviarCorreo() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty || _nombreCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena todos los campos")),
      );
      return;
    }

    setState(() => _cargando = true);

    final authService = AuthService();
    final user = await authService.registrarCorreo(
      _emailCtrl.text.trim(), 
      _passwordCtrl.text.trim(), 
      _nombreCtrl.text.trim(), 
      _apellidoCtrl.text.trim(), 
      _usernameCtrl.text.trim(),
    );

    setState(() => _cargando = false);

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VerificacionScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al registrar. El correo podría estar en uso.")),
        );
      }
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
        title: const Text("Crear cuenta", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.network(
              'https://res.cloudinary.com/ddllxwpf4/image/upload/v1768588172/ChordListLogo_tblekc.png',
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, StackTrace) {
                return const SizedBox(height: 50);
              },
            ),
            const SizedBox(height: 30),

            _InputRegistro(controller: _nombreCtrl, label: "Nombre"),
            const SizedBox(height: 15),
            
            _InputRegistro(controller: _apellidoCtrl, label: "Apellido"),
            const SizedBox(height: 15),
            
            _InputRegistro(controller: _usernameCtrl, label: "Nombre de usuario"),
            const SizedBox(height: 15),

            _InputRegistro(controller: _emailCtrl, label: "Correo electrónico", keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),

            _InputRegistro(controller: _passwordCtrl, label: "Contraseña", isPassword: true),
            
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _cargando ? null : _registrarYEnviarCorreo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _cargando 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                    )
                  : const Text(
                      "Continuar",
                      style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputRegistro extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;

  const _InputRegistro({
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF06A0B5)),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }
}