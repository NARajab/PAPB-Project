import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../services/p2h_services/timesheet/location_service.dart';
import 'timesheet.dart';

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

  FirebaseLocationService locationService = FirebaseLocationService();

  @override
  void initState() {
    super.initState();
    _checkLocationFilled();
  }

  Future<String?> _getUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      return user.uid;
    } catch (e) {
      print("Error getting user ID: $e");
      return null;
    }
  }

  Future<void> _checkLocationFilled() async {
    final userId = await _getUserId();
    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final locationCreatedTimestamp = prefs.getInt('locationCreatedTimestamp_$userId');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check if the location was created within the last 13 hours
    if (locationCreatedTimestamp != null && (currentTime - locationCreatedTimestamp < 13 * 60 * 60 * 1000)) {
      // Location was created in the last 13 hours, navigate to the TimesheetScreen
      final locationId = prefs.getString('locationId_$userId');
      if (locationId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TimesheetScreen(locationId: locationId),
          ),
        );
      }
    } else {
      // Location doesn't exist or the 13-hour period has passed
      _showErrorFlushbar('You must wait 13 hours before creating a new location.');
    }
  }


  Future<void> submitData() async {
    final userId = await _getUserId();

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
      final response = await locationService.addLocation(requestData);
      print(response);

      if (response != null) {
        final locationId = response['id']; // Assuming 'id' is returned by Firestore and is a String

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocationFilled_$userId', true);
        await prefs.setInt('locationCreatedTimestamp_$userId', DateTime.now().millisecondsSinceEpoch);
        await prefs.setString('locationId_$userId', locationId); // Use setString instead of setInt

        _showSuccessFlushbar();
        _clearFields();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TimesheetScreen(locationId: locationId),
          ),
        );
      } else {
        _showErrorFlushbar('Failed to create location.');
      }
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
                'PENGISIAN FUEL: ',
                style: TextStyle(fontSize: 16),
              ),
              _buildTextField(fuelhmController, 'HM'),
              _buildTextField(fuelController, 'FUEL'),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF304FFE),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
