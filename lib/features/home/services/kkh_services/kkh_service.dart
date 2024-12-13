import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_imagekit/flutter_imagekit.dart';
import 'dart:io';

class KkhServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> uploadKkhImage(File imageFile) async {
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
      print("Error uploading image: $e");
      return null;
    }
  }

  String _calculateComplaint(double totalHours, int dayOfWeek) {
    if (dayOfWeek == 5 && totalHours >= 4.5) {
      return 'Fit to work';
    } else if (dayOfWeek == 5 && totalHours < 4.5) {
      return 'On Monitoring';
    } else if (totalHours >= 6) {
      return 'Fit to work';
    } else if (totalHours < 6 && totalHours >= 4) {
      return 'On Monitoring';
    } else {
      return 'Kurang Tidur';
    }
  }

  String _formatDate() {
    final currentDate = DateTime.now();
    final day = currentDate.day;
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dayNames = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];

    final month = monthNames[currentDate.month - 1];
    final dayName = dayNames[currentDate.weekday - 1];
    final year = currentDate.year;

    return '$dayName, $day $month $year';
  }

  Future<void> submitKkhData(String totalJamTidur, String userId, {String? imageUrl}) async {
    try {
      final timeParts = RegExp(r'(\d+)\s*Jam\s*(\d+)?\s*Menit').firstMatch(totalJamTidur);
      if (timeParts == null) {
        throw Exception('Format totalJamTidur tidak valid');
      }

      final hours = int.parse(timeParts.group(1)!);
      final minutes = int.parse(timeParts.group(2) ?? '0');
      final totalHours = hours + minutes / 60;

      final dayOfWeek = DateTime.now().weekday;
      final complaint = _calculateComplaint(totalHours, dayOfWeek);

      final formattedDate = _formatDate();

      final User? user = _auth.currentUser;
      if (user == null) return;

      final kkhRefs = await _firestore.collection('kkhs').add({
        'userId': userId,
        'totalJamTidur': totalJamTidur,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'date': formattedDate,
        'wValidation': true,
        'fValidation': false,
        'complaint': complaint,
      });

      print('Data KKH berhasil dikirim.');
    } catch (e) {
      throw Exception('Gagal mengirim data KKH: $e');
    }
  }
}
