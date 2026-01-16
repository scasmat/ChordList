import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get estadoUsuario => _auth.authStateChanges();

  User? get usuarioActual => _auth.currentUser;

  bool get esInvitado => _auth.currentUser?.isAnonymous ?? false;

  Future<User?> entrarComoInvitado() async {
    try {
      UserCredential cred = await _auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      print("Error invitado: $e");
      return null;
    }
  }

  Future<User?> registrarCorreo(String email, String password, String nombre, String apellido, String username) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (cred.user != null) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'nombre': nombre,
          'apellido': apellido,
          'username': username,
          'email': email,
          'creado_en': FieldValue.serverTimestamp(),
          'rol': 'usuario',
        });
        
        await cred.user!.sendEmailVerification();
      }
      return cred.user;
    } catch (e) {
      print("Error registro: $e");
      return null;
    }
  }

  Future<User?> iniciarSesion(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Error login: $e");
      return null;
    }
  }

  Future<User?> entrarConGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);
      
      final userDoc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!userDoc.exists) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'nombre': googleUser.displayName,
          'email': googleUser.email,
          'fotoUrl': googleUser.photoUrl,
          'creado_en': FieldValue.serverTimestamp(),
          'metodo': 'google',
        });
      }
      
      return cred.user;
    } catch (e) {
      print("Error Google: $e");
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}