import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KkhForemanServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getAllKkh() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('kkhs').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> kkhList = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> kkhData = doc.data() as Map<String, dynamic>;

          // Menambahkan ID KKH ke dalam data
          kkhData['kkhId'] = doc.id;

          String userId = kkhData['userId'];

          DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            kkhData['user'] = userData;
          } else {
            kkhData['user'] = {'status': 'failed', 'message': 'User not found'};
          }

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
