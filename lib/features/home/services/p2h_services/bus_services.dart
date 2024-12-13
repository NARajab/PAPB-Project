import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class BusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitP2hBus(Map<String, dynamic> requestData, BuildContext context) async {
    try {
      final aroundUnitRef = await _firestore.collection('aroundunits').add({
        'bdbr': requestData['bdbr'],
        'kai': requestData['kai'],
        'kot': requestData['kot'],
        'ops': requestData['ops'],
        'bbcmin': requestData['bbcmin'],
        'kasa': requestData['kasa'],
        'sk': requestData['sk'],
        'g2': requestData['g2'],
        'sc': requestData['sc'],
        'ba': requestData['ba'],
        'kso': requestData['kso'],
        'ka': requestData['ka'],
      });

      // Create `inthecabins` collection document
      final inTheCabinRef = await _firestore.collection('inthecabins').add({
        'ac': requestData['ac'],
        'apk': requestData['apk'],
        'fb': requestData['fb'],
        'fs': requestData['fs'],
        'fsb': requestData['fsb'],
        'fsl': requestData['fsl'],
        'frl': requestData['frl'],
        'fm': requestData['fm'],
        'fwdaw': requestData['fwdaw'],
        'fkp': requestData['fkp'],
        'fh': requestData['fh'],
        'feapar': requestData['feapar'],
        'frk': requestData['frk'],
        'krk': requestData['krk'],
      });

      // Create `machinerooms` collection document
      final machineRoomRef = await _firestore.collection('machinerooms').add({
        'ar': requestData['ar'],
        'oe': requestData['oe'],
        'fba': requestData['fba'],
      });

      // Format current date
      final currentDate = DateTime.now();
      final day = currentDate.day;
      final monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
        'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final month = monthNames[currentDate.month - 1];
      final year = currentDate.year;
      final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final dayName = dayNames[currentDate.weekday - 1];
      final formattedDate = '$dayName, $day $month $year';

      // Create `p2hs` collection document
      final p2hRef = await _firestore.collection('p2hs').add({
        'idAroundUnit': aroundUnitRef.id,
        'idInTheCabin': inTheCabinRef.id,
        'idMachineRoom': machineRoomRef.id,
        'idVehicle': requestData['idVehicle'],
        'date': formattedDate,
        'shift': requestData['shift'],
        'time': requestData['time'],
        'earlykm': requestData['earlykm'],
        'endkm': requestData['endkm'],
        'kbj': requestData['kbj'],
        'jobsite': requestData['jobsite'],
        'location': requestData['location'],
        'ntsAroundU': requestData['ntsAroundU'],
        'ntsInTheCabinU': requestData['ntsInTheCabinU'],
        'ntsMachineRoom': requestData['ntsMachineRoom'],
        'ntsAroundUf': '',
        'ntsInTheCabinUf': '',
        'ntsMachineRoomf': ''
      });

      // Create `p2husers` collection document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final p2hUserRef = await _firestore.collection('p2husers').add({
          'p2hId': p2hRef.id,
          'userId': user.uid,
          'name': requestData['username'],
          'createdAt': DateTime.now(),
          'dValidation': true,
          'mValidation': false,
          'fValidation': false,
          'aValidation': false,
        });
      }
    } catch (e) {
      print('Failed to submit data: $e');
      throw Exception('Failed to submit data: $e');
    }
  }
}
