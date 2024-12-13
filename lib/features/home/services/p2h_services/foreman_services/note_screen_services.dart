import 'package:cloud_firestore/cloud_firestore.dart';

class NoteScreenServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitNotes(
      String aroundU,
      String inTheCabin,
      String machineRoom,
      String p2hId,
      ) async {
    try {
      // Mendapatkan referensi ke dokumen p2h berdasarkan p2hId
      DocumentReference p2hDocRef = _firestore.collection('p2hs').doc(p2hId);

      // Update data di kolom yang sesuai
      await p2hDocRef.update({
        'ntsAroundUf': aroundU,
        'ntsInTheCabinUf': inTheCabin,
        'ntsMachineRoomf': machineRoom,
      });

      print('Notes submitted successfully');
    } catch (e) {
      throw Exception('Failed to submit notes: $e');
    }
  }
}
