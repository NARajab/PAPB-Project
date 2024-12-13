import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DumpTruckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitP2hDt(Map<String, dynamic> requestData, BuildContext context) async {
    try {
      final aroundUnitRef = await _firestore.collection('aroundunits').add({
        'bdbr': requestData['bdbr'],
        'kai': requestData['kai'],
        'kot': requestData['kot'],
        'sohd': requestData['sohd'],
        'fd': requestData['fd'],
        'bbcmin': requestData['bbcmin'],
        'badtu': requestData['badtu'],
        'kas': requestData['kas'],
        'tg': requestData['tg'],
        'ba': requestData['ba'],
        'g2': requestData['g2'],
        'sc': requestData['sc'],
        'ka': requestData['ka'],
      });

      final inTheCabinRef = await _firestore.collection('inthecabins').add({
        'ac': requestData['ac'],
        'fb': requestData['fb'],
        'fs': requestData['fs'],
        'fsb': requestData['fsb'],
        'fsl': requestData['fsl'],
        'frl': requestData['frl'],
        'fm': requestData['fm'],
        'fwdaw': requestData['fwdaw'],
        'fh': requestData['fh'],
        'feapar': requestData['feapar'],
        'fkp': requestData['fkp'],
        'frk': requestData['frk'],
        'krk': requestData['krk'],
      });

      final machineRoomRef = await _firestore.collection('machinerooms').add({
        'ar': requestData['ar'],
        'oe': requestData['oe'],
      });

      // 2. Get the current date formatted as desired
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

      // 3. Create the p2h document
      final p2hRef = await _firestore.collection('p2hs').add({
        'idAroundUnit': aroundUnitRef.id,
        'idInTheCabin': inTheCabinRef.id,
        'idMachineRoom': machineRoomRef.id,
        'idVehicle': requestData['idVehicle'],
        'date': formattedDate,
        'shift': requestData['shift'],
        'time': requestData['time'],
        'earlyhm': requestData['earlyhm'],
        'endhm': requestData['endhm'],
        'earlykm': requestData['earlykm'],
        'endkm': requestData['endkm'],
        'kbj': requestData['kbj'],
        'ntsAroundU': requestData['ntsAroundU'],
        'ntsInTheCabinU': requestData['ntsInTheCabinU'],
        'ntsMachineRoom': requestData['ntsMachineRoom'],
        'ntsAroundUf': '',
        'ntsInTheCabinUf': '',
        'ntsMachineRoomf': ''
      });

      // 4. Add the p2h user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final p2hUserRef = await _firestore.collection('p2husers').add({
          'p2hId': p2hRef.id,
          'userId': user.uid,
          'name': requestData['username'],
          'dValidation': true,
          'mValidation': false,
          'fValidation': false,
          'aValidation': false,
          'createdAt': DateTime.now(),
        });
      }

    } catch (e) {
      print('Failed to submit data: $e');
      rethrow;
    }
  }
}
