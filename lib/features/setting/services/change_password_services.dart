import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword(String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      throw Exception("New password and confirm password do not match.");
    }

    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      await user.updatePassword(newPassword);

      print("Password changed successfully");
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }
}
