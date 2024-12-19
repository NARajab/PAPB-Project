import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/p2h_services/foreman_services/p2h_foreman_services.dart';
import './foreman_validation_p2h.dart';

class ForemanP2h extends StatefulWidget {
  const ForemanP2h({super.key});

  @override
  _ForemanP2hState createState() => _ForemanP2hState();
}

class _ForemanP2hState extends State<ForemanP2h> {
  String filterText = '';
  bool isSearching = false;
  bool isLoading = true;
  String role = '';

  List<Map<String, dynamic>> data = [];


  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRole();
  }

  final P2hForemanServices _p2hForemanServices = P2hForemanServices();


  Future<void> _loadData() async {
    try {
      final data = await _p2hForemanServices.fetchP2hUsersWithDetails();
      print(data);
      setState(() {
        this.data = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _loadRole() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            final userData = userDoc.data() as Map<String, dynamic>?;

            role = userData?['role'] ?? '';
          });


          print('User Role: $role');
        } else {
          print('Dokumen pengguna tidak ditemukan');
          setState(() {
            role = '';
          });
        }
      } else {
        print('Tidak ada pengguna yang login');
        setState(() {
          role = '';
        });
      }
    } catch (e) {
      print('Error getting role: $e');
      setState(() {
        role = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter and map data
    List<Widget> filteredAndMappedData = data
        .where((item) {
      // Filtering criteria
      final p2h = item['p2h'] ?? {};
      final date = p2h['date']?.toLowerCase() ?? '';
      final vehicleType = item['vehicle']?['type']?.toLowerCase() ?? '';
      final jobsite = p2h['jobsite']?.toLowerCase() ?? '';
      return date.contains(filterText) ||
          vehicleType.contains(filterText) ||
          jobsite.contains(filterText);
    })
        .map((item) {
      final p2h = item['p2h'] ?? {};
      final p2hUser = item['p2hUser'] ?? {};
      final title = (p2h['date'] ?? 'Unknown Date').toString();
      final subtitle = (p2hUser['name'] ?? 'Unknown User').toString();
      final vehicle = (item['vehicle']?['type'] ?? 'Unknown Vehicle').toString();
      final date = (p2h['date'] ?? '').toString();
      final isValidated = (p2hUser['fValidation'] as bool?) ?? false;

      return _buildCard(
        context,
        p2hUser['id']?.toString() ?? '',
        p2hUser['p2hId']?.toString() ?? '',
        title,
        subtitle,
        vehicle,
        date,
        role,
        isValidated,
        vehicle,
      );
    })

        .toList();

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              filterText = value.toLowerCase();
            });
          },
        )
            : const Text('Validation form P2H'),
        backgroundColor: const Color(0xFF304FFE),
        elevation: 5,
        shadowColor: Colors.black,
        titleTextStyle: const TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
        toolbarHeight: 55,
        leading: IconButton(
          icon: Icon(isSearching ? Icons.clear : Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: () {
            if (isSearching) {
              setState(() {
                isSearching = false;
                filterText = '';
              });
            } else {
              Navigator.pushNamed(context, '/home');
            }
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
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  filterText = '';
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF304FFE)),
      )
          : filteredAndMappedData.isEmpty
          ? const Center(
        child: Text(
          'Tidak ada P2H',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: filteredAndMappedData,
      ),
    );
  }


  Widget _buildCard(BuildContext context, String p2hUserId, String p2hId, String title, String subtitle, String idVehicle, String date, String role, bool isValidated, String vehicle) {
    return GestureDetector(
      onTap: () {
        navigateToForemanValidationP2h(context, p2hUserId, p2hId, idVehicle, date, role);
      },
      child: Card(
        elevation: 3,
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isValidated ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isValidated ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text('$vehicle - $subtitle'),
        ),
      ),
    );
  }
}

void navigateToForemanValidationP2h(BuildContext context, String p2hUserId, String p2hId, String idVehicle, String date, String role) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Foremanvalidationp2hScreen(p2hId: p2hId, p2hUserId: p2hUserId, idVehicle: idVehicle, date: date, role: role),
    ),
  );
}
