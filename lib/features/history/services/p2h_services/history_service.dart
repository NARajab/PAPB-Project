import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> fetchP2hUserDetailsById(String p2hUserId) async {
  try {
    final firestore = FirebaseFirestore.instance;

    final p2hUserDoc = await firestore.collection('p2husers').doc(p2hUserId).get();

    if (!p2hUserDoc.exists) {
      print('No P2hUser found with ID: $p2hUserId');
      return {};  // Return an empty map instead of null
    }

    final p2hUserData = p2hUserDoc.data();
    if (p2hUserData == null) {
      print('P2hUser data is null for ID: $p2hUserId');
      return {};  // Return an empty map instead of null
    }

    // Mengambil userId dari p2hUserData untuk query ke koleksi users
    final userId = p2hUserData['userId'];
    final userDoc = await firestore.collection('users').doc(userId).get();

    // Jika data user ditemukan, ambil datanya
    final userData = userDoc.exists ? userDoc.data() : null;

    // Get related P2h document
    final p2hId = p2hUserData['p2hId'];
    final p2hDoc = await firestore.collection('p2hs').doc(p2hId).get();

    if (!p2hDoc.exists) {
      print('No P2h found with ID: $p2hId');
      return {};
    }

    final p2hData = p2hDoc.data();

    // Fetch related documents
    final aroundUnitDoc = await firestore.collection('aroundunits').doc(p2hData?['idAroundUnit']).get();
    final inTheCabinDoc = await firestore.collection('inthecabins').doc(p2hData?['idInTheCabin']).get();
    final machineRoomDoc = await firestore.collection('machinerooms').doc(p2hData?['idMachineRoom']).get();
    final vehicleDoc = await firestore.collection('vehicles').doc(p2hData?['idVehicle']).get();

    // Combine all fetched data
    return {
      'p2hUser': p2hUserData,
      'p2h': p2hData,
      'user': userData,
      'aroundUnit': aroundUnitDoc.data(),
      'inTheCabin': inTheCabinDoc.data(),
      'machineRoom': machineRoomDoc.data(),
      'vehicle': vehicleDoc.data(),
    };
  } catch (e) {
    print('Error fetching data for p2hUserId $p2hUserId: $e');
    return {};  // Return an empty map in case of error
  }
}

Future<Map<String, dynamic>> getP2hById(String p2hId) async {
  try {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Directly fetch the document data
    var document = await _firestore.collection('p2hs').doc(p2hId).get();

    // Check if the document exists and return the data as a Map
    if (document.exists) {
      return document.data() as Map<String, dynamic>;
    } else {
      throw Exception('Data tidak ditemukan');
    }
  } catch (e) {
    throw Exception('Gagal mengambil data P2H: $e');
  }
}
