import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> addLocation(Map<String, dynamic> locationData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Add location data to Firestore
      final locationRef = await _firestore.collection('locations').add({
        'userId': user.uid, // User ID from Firebase Authentication
        'pit': locationData['pit'],
        'disposal': locationData['disposal'],
        'location': locationData['location'],
        'fuel': locationData['fuel'],
        'fuelhm': locationData['fuelhm'],
        'postscript': '',
        'stopOperation': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Return the document data
      final doc = await locationRef.get();
      final data = doc.data();

      if (data != null) {
        // Add the Firestore document ID to the returned data
        data['id'] = locationRef.id;
      }

      return data;
    } catch (e) {
      print("Error adding location: $e");
      return null;
    }
  }

  // Function to retrieve a location based on userId and check if a location is created in the last 13 hours
  Future<Map<String, dynamic>?> getLocationByUserId(String userId) async {
    try {
      final locationsQuery = await _firestore
          .collection('locations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (locationsQuery.docs.isEmpty) {
        return null;
      }

      final locationDoc = locationsQuery.docs.first;
      final locationData = locationDoc.data();
      final timestamp = (locationData['createdAt'] as Timestamp).toDate();
      final timeDifference = DateTime.now().difference(timestamp);

      // Check if location was created within 13 hours
      if (timeDifference.inHours < 13) {
        return locationData;
      }

      return null; // No location created within the last 13 hours
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}
