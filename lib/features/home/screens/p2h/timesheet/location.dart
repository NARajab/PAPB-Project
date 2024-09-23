import 'package:flutter/material.dart';
import './timesheet.dart';
import '../../../services/p2h_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:another_flushbar/flushbar.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController pitController = TextEditingController();
  final TextEditingController disposalController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController fuelController = TextEditingController();
  final TextEditingController fuelhmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLocationFilled();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return null;
    }

    try {
      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['id'];

      return userId is int ? userId.toString() : userId as String?;
    } catch (e) {
      print("Error decoding token: $e");
      return null;
    }
  }

  Future<int?> _getLocationId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('locationId_$userId');
  }

  Future<bool> _isLocationCreatedWithin13Hours(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? timestamp = prefs.getInt('locationCreatedTimestamp_$userId');
    if (timestamp == null) {
      return false;
    }

    final DateTime savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime currentTime = DateTime.now();
    final Duration difference = currentTime.difference(savedTime);

    // Check if 13 hours have passed
    if (difference.inHours >= 13) {
      return false;
    }

    return true;
  }

  Future<void> _checkLocationFilled() async {
    final userId = await _getUserId();

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final bool isLocationCreatedWithin13Hours = await _isLocationCreatedWithin13Hours(userId);

    if (isLocationCreatedWithin13Hours) {
      final int? locationId = await _getLocationId(userId);
      if (locationId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TimesheetScreen(locationId: locationId),
          ),
        );
      } else {
        print("Location ID is null");
      }
    } else {
      // Show message that the user must wait 13 hours before creating a new location
      _showErrorFlushbar('You must wait 13 hours before creating a new location.');
    }
  }


  Widget _buildTextField(
      TextEditingController controller,
      String labelText, {
        TextInputType keyboardType = TextInputType.text,
        GestureTapCallback? onTap
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: false,
    );
  }

  Future<void> _submitData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = await _getUserId(); // Ambil userId dari token

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final requestData = {
      'pit': pitController.text,
      'disposal': disposalController.text,
      'location': locationController.text,
      'fuel': fuelController.text,
      'fuelhm': fuelhmController.text,
    };

    try {
      final response = await TimesheetServices().submitLocation(requestData, token);
      final int locationId = response['lokasi']['id'];

      await prefs.setBool('isLocationFilled_$userId', true);
      await prefs.setInt('locationCreatedTimestamp_$userId', DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('locationId_$userId', locationId);

      _showSuccessFlushbar();
      _clearFields();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimesheetScreen(locationId: locationId),
        ),
      );
    } catch (e) {
      _showErrorFlushbar(e.toString());
    }
  }

  void _clearFields() {
    pitController.clear();
    disposalController.clear();
    locationController.clear();
    fuelController.clear();
    fuelhmController.clear();
  }

  void _showSuccessFlushbar() {
    Flushbar(
      message: 'Data berhasil dikirim',
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
    ).show(context);
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
    ).show(context);
  }

  @override
  void dispose() {
    pitController.dispose();
    disposalController.dispose();
    locationController.dispose();
    fuelController.dispose();
    fuelhmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet Form'),
        backgroundColor: const Color(0xFF304FFE),
        elevation: 5,
        shadowColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w400,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(pitController, 'PIT'),
              _buildTextField(disposalController, 'DISPOSAL'),
              _buildTextField(locationController, 'LOKASI'),
              const SizedBox(height: 25),
              const Text(
                'PENGISIAN FUEL:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              _buildTextField(fuelhmController, 'HM'),
              _buildTextField(fuelController, 'FUEL'),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
