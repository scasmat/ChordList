import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chordlist/servicios/auth_service.dart';
import 'login_screen.dart';
import 'registro_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Image.network(
                      'https://res.cloudinary.com/ddllxwpf4/image/upload/v1768587569/Logo_clggzj.png',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, StackTrace) {
                        return const Text("ChordList", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
                      },
                    ),
                  const SizedBox(height: 50),
                  const Text(
                    "Crea tu cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  _SocialButton(
                    icon: FontAwesomeIcons.google,
                    text: "Continuar con Google",
                    colorIcon: Colors.red,
                    onTap: () async {
                      try {
                        await authService.entrarConGoogle();
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error al iniciar con Google")),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  _SocialButton(
                    icon: Icons.email_outlined,
                    text: "Continuar con correo",
                    colorIcon: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistroScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[800], thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.circle, size: 6, color: Colors.grey[600]),
                      ),
                      Expanded(child: Divider(color: Colors.grey[800], thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(text: "¿Ya tienes una cuenta? "),
                          TextSpan(
                            text: "Iniciar Sesion",
                            style: TextStyle(
                              color: Colors.cyan,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.cyan, blurRadius: 10)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                onPressed: () async {
                  try {
                    await authService.entrarComoInvitado();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Debes habilitar 'Anónimo' en Firebase Authentication"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color colorIcon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.text,
    required this.colorIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorIcon, size: 22),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}