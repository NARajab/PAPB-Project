import 'package:flutter/material.dart';
import './template/bulldozer_template.dart';
import './template/bus_template.dart';
import './template/dump_truck_template.dart';
import './template/excavator_template.dart';
import './template/light_vehicle_template.dart';
import './notes_screen.dart';

class HistoryP2hScreen extends StatelessWidget {
  final String p2hUserId;
  final String p2hId;
  final String idVehicle;
  final String date;
  final String role;
  final bool isValidated;

  const HistoryP2hScreen({
    super.key,
    required this.p2hUserId,
    required this.p2hId,
    required this.idVehicle,
    required this.date,
    required this.role,
    required this.isValidated
  });

  Widget _buildTemplate(String p2hId, String idVehicle, String date, String entry) {
    switch (idVehicle) {
      case 'Bulldozer':
        return BulldozerTemplate(p2hId: p2hId, p2hUserId: p2hUserId, role: role,);
      case 'Dump Truck':
        return DumpTruckTemplate(p2hUserId: p2hUserId, p2hId: p2hId, role: role);
      case 'Excavator':
        return ExcavatorTemplate(p2hId: p2hId, p2hUserId: p2hUserId, role: role);
      case 'Light Vehicle':
        return LightVehicleTemplate(p2hId: p2hId, p2hUserId: p2hUserId, role: role);
      case 'Sarana Bus':
        return BusTemplate(p2hId: p2hId, p2hUserId: p2hUserId, role: role);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History P2H'),
        backgroundColor: const Color(0xFF304FFE),
        elevation: 5,
        shadowColor: Colors.black,
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400
        ),
        toolbarHeight: 45,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 69,
              height: 3,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notes),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteScreen(p2hId: p2hId),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: 1, // Just one entry based on your example
        itemBuilder: (context, index) {
          final entry = {
            'idVehicle': idVehicle,
            'date': date,
            'entry': 'Example entry description',
            'role': role
          };

          return _buildTemplate(p2hId, idVehicle, date, entry['entry']!);
        },
      ),
    );
  }
}
