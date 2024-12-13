import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        return {
          'status': 'error',
          'message': 'Your email is not verified. Please verify your email first.',
        };
      }

      return {
        'status': 'success',
        'message': 'Login successful',
        'uid': user?.uid,
        'email': user?.email,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'No user found for that email or Incorrect password provided.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      return {'status': 'error', 'message': errorMessage};
    } catch (e) {
      return {'status': 'error', 'message': 'An unexpected error occurred.'};
    }
  }
}
