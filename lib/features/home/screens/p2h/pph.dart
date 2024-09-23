import 'package:flutter/material.dart';
import './timesheet/location.dart';
import './timesheet/timesheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class P2hScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      'id': 1,
      'title': 'Bulldozer',
      'imagePath': 'assets/images/bl.png',
      'route': '/blForm'
    },
    {
      'id': 2,
      'title': 'Dump Truck',
      'imagePath': 'assets/images/dt.png',
      'route': '/dtForm'
    },
    {
      'id': 3,
      'title': 'Excavator',
      'imagePath': 'assets/images/ex.png',
      'route': '/exForm'
    },
    {
      'id': 4,
      'title': 'Light Vehicle',
      'imagePath': 'assets/images/lv.png',
      'route': '/lvForm'
    },
    {
      'id': 5,
      'title': 'Sarana Bus',
      'imagePath': 'assets/images/bus.png',
      'route': '/bsForm'
    },
    {
      'title': 'Timesheet',
      'imagePath': 'assets/images/timesheet.png',
      'route': '/location'
    },
  ];

  P2hScreen({super.key});

  Future<bool> _isLocationDataValid() async {
    final prefs = await SharedPreferences.getInstance();
    final int? timestamp = prefs.getInt('locationFilledTimestamp');
    if (timestamp == null) {
      return false;
    }

    final DateTime savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime currentTime = DateTime.now();
    final Duration difference = currentTime.difference(savedTime);

    if (difference.inHours > 15) {
      await prefs.remove('isLocationFilled');
      await prefs.remove('locationFilledTimestamp');
      return false;
    }

    return prefs.getBool('isLocationFilled') ?? false;
  }


  Future<int?> _getLocationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('locationId');
  }

  void _navigateToTimesheetOrLocation(BuildContext context) async {
    bool isLocationFilled = await _isLocationDataValid();

    if (isLocationFilled == true) {
      print('isLocationFilled is true');
      int? locationId = await _getLocationId();

      if (locationId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TimesheetScreen(locationId: locationId),
          ),
        );
      } else {
        print('isLocationFilled is false');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LocationScreen(),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LocationScreen(),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form P2H'),
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
            _navigateBack(context);
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
      body: GridView.builder(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (items[index]['title'] == 'Timesheet') {
                _navigateToTimesheetOrLocation(context);
              } else if (items[index].containsKey('id')) {
                Navigator.pushNamed(
                  context,
                  items[index]['route']!,
                  arguments: {
                    'id': items[index]['id'],
                    'title': items[index]['title'],
                  },
                );
              } else {
                Navigator.pushNamed(
                  context,
                  items[index]['route']!,
                );
              }
            },
            child: _buildItemCard(items[index]['title']!, items[index]['imagePath']!, 150, 150),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(String title, String imagePath, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: width * 0.6,
              height: height * 0.6,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}