import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KkhServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getKkhByUserId(String userId) async {
    try {
      // Query the KKH collection where userId matches the provided userId
      QuerySnapshot querySnapshot = await _firestore
          .collection('kkhs')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> kkhList = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> kkhData = doc.data() as Map<String, dynamic>;

          kkhList.add(kkhData);
        }

        return {
          'status': 'success',
          'kkh': kkhList,
        };
      } else {
        return {
          'status': 'failed',
          'message': 'No data found for the specified userId',
        };
      }
    } catch (e) {
      print('Error fetching KKH data for userId: $e');
      return {
        'status': 'failed',
        'message': 'Error occurred while fetching data',
      };
    }
  }

  Future<Map<String, dynamic>> getAllKkh() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('kkhs').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> kkhList = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> kkhData = doc.data() as Map<String, dynamic>;

          kkhData['id'] = doc.id;
          kkhList.add(kkhData);
        }

        return {
          'status': 'success',
          'kkh': kkhList,
        };
      } else {
        return {
          'status': 'failed',
          'message': 'No data found',
        };
      }
    } catch (e) {
      print('Error fetching KKH data: $e');
      return {
        'status': 'failed',
        'message': 'Error occurred while fetching data',
      };
    }
  }

  Future<Map<String, dynamic>> getKkhById(String kkhId) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('kkhs').doc(kkhId).get();

      if (docSnapshot.exists) {
        return {
          'status': 'success',
          'kkh': docSnapshot.data() as Map<String, dynamic>,
        };
      } else {
        return {
          'status': 'failed',
          'message': 'KKH not found',
        };
      }
    } catch (e) {
      print('Error fetching KKH by ID: $e');
      return {
        'status': 'failed',
        'message': 'Error occurred while fetching data',
      };
    }
  }

  Future<Map<String, dynamic>> getKkhByValidation(bool isValidated) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('kkhs')
          .where('fValidation', isEqualTo: isValidated)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> filteredKkhList = querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();

        return {
          'status': 'success',
          'kkh': filteredKkhList,
        };
      } else {
        return {
          'status': 'failed',
          'message': 'No data found for the specified validation status',
        };
      }
    } catch (e) {
      print('Error fetching KKH by validation: $e');
      return {
        'status': 'failed',
        'message': 'Error occurred while fetching data',
      };
    }
  }
}
