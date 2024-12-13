import 'package:cloud_firestore/cloud_firestore.dart';

class P2hServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchP2hUsersWithDetails(String userId) async {
    try {
      final p2hUsersSnapshot = await _firestore
          .collection('p2husers')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> detailedP2hUsers = [];

      for (var p2hUserDoc in p2hUsersSnapshot.docs) {
        final p2hUserData = p2hUserDoc.data();
        if (p2hUserData != false) {
          p2hUserData['id'] = p2hUserDoc.id;
        }
        final String? p2hId = p2hUserData['p2hId'];

        if (p2hId == null) continue;

        final p2hDoc = await _firestore.collection('p2hs').doc(p2hId).get();

        if (!p2hDoc.exists) continue;

        final p2hData = p2hDoc.data();
        if (p2hData != null) {
          p2hData['id'] = p2hDoc.id;
        }

        final vehicleData = await _getCollectionData(
          'vehicles',
          p2hData?['idVehicle'],
        );

        detailedP2hUsers.add({
          'p2hUser': p2hUserData,
          'p2h': p2hData,
          'vehicle': vehicleData
        });
      }

      return detailedP2hUsers;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllP2hUsersWithDetails() async {
    try {
      final p2hUsersSnapshot = await _firestore.collection('p2husers').get();

      List<Map<String, dynamic>> detailedP2hUsers = [];

      for (var p2hUserDoc in p2hUsersSnapshot.docs) {
        final p2hUserData = p2hUserDoc.data();
        if (p2hUserData != false) {
          p2hUserData['id'] = p2hUserDoc.id;
        }
        final String? p2hId = p2hUserData['p2hId'];

        if (p2hId == null) continue;

        final p2hDoc = await _firestore.collection('p2hs').doc(p2hId).get();

        if (!p2hDoc.exists) continue;

        final p2hData = p2hDoc.data();
        if (p2hData != null) {
          p2hData['id'] = p2hDoc.id;
        }

        final vehicleData = await _getCollectionData(
          'vehicles',
          p2hData?['idVehicle'],
        );

        detailedP2hUsers.add({
          'p2hUser': p2hUserData,
          'p2h': p2hData,
          'vehicle': vehicleData
        });
      }

      return detailedP2hUsers;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }



  Future<Map<String, dynamic>?> _getCollectionData(
      String collection,
      String? docId,
      ) async {
    if (docId == null) return null;
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching $collection with ID $docId: $e');
      return null;
    }
  }
}
