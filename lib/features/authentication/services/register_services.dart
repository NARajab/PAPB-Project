import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register a new user
  Future<Map<String, dynamic>> register(
      String username, String email, String nik, String password, String phone, String role) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'email': email,
        'nik': nik,
        'phone': phone,
        'role': role,
        'imageUrl': 'https://ik.imagekit.io/AliRajab03/flutter_imagekit/download%20(5).png?updatedAt=1733536242606',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'status': 'success',
        'message':
        'User registered successfully. Please verify your email to activate your account.'
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
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
