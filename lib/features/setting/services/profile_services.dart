import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_imagekit/flutter_imagekit.dart';

class ProfileServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserById() async {
    try {
      // Get current user
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      // Convert document to Map
      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final result = await ImageKit.io(
        imageFile,
        privateKey: "private_8219el7TQeF1NLQKg9qasbf6N8M=",
        onUploadProgress: (progressValue) {
          print('Upload Progress: $progressValue%');
        },
      );

      return result;
    } catch (e) {
      print("Error uploading profile image to ImageKit: $e");
      return null;
    }
  }

  Future<void> updateProfile(
      String username,
      String phoneNumber,
      {String? imageUrl}
      ) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'username': username,
        'phone': phoneNumber,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }
}
