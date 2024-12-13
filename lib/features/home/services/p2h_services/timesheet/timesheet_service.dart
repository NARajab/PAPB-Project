import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimesheetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> addTimesheet(Map<String, dynamic> requestData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final timeshetRef = await _firestore.collection('timesheets').add({
        'idLocation': requestData['idLocation'],
        'timeTs': requestData['timeTs'],
        'material': requestData['material'],
        'remark': requestData['remark'],
        'activityCode': requestData['activityCode'],
        'delayCode': requestData['delayCode'],
        'idleCode': requestData['idleCode'],
        'repairCode': requestData['repairCode'],
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Failed to submit data: $e');
      rethrow;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getTimesheetsByIdLocation(String idLocation) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await _firestore
          .collection('timesheets')
          .where('idLocation', isEqualTo: idLocation)
          .get();

      final timesheets = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      return timesheets;
    } catch (e) {
      print('Failed to get timesheets: $e');
      rethrow;
    }
  }

  Future<void> submitPostscript(String locationId, Map<String, dynamic> requestData) async {
    try {
      // Reference to the location document in the Firestore collection
      final DocumentReference locationDoc = _firestore.collection('locations').doc(locationId);

      // Update the document with new data
      await locationDoc.update({
        'postscript': requestData['postscript'],
        'stopOperation': requestData['stopOperation'],
      });

      print('Postscript and StopOperation updated successfully');
    } catch (e) {
      print('Error updating postscript and stopOperation: $e');
      throw 'Unable to update postscript data.';
    }
  }
}
