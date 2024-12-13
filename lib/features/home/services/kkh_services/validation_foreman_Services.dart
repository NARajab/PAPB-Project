import 'package:cloud_firestore/cloud_firestore.dart';

class ValidationForemanServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method untuk validasi Foreman dan update fValidation
  Future<void> foremanValidation(String kkhId) async {
    try {
      DocumentReference p2hDocRef = _firestore.collection('kkhs').doc(kkhId.toString());

      await p2hDocRef.update({'fValidation': true});

      print('Validation successful');
    } catch (e) {
      throw Exception('Failed to validate: $e');
    }
  }
}
