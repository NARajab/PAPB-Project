import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../history/screens/history_kkh.dart';
import '../../services/kkh_services/kkh_foreman_services.dart';

class ForemanKkh extends StatefulWidget {
  const ForemanKkh({super.key});

  @override
  _ForemanKkhState createState() => _ForemanKkhState();
}

class _ForemanKkhState extends State<ForemanKkh> {
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

  final KkhForemanServices _kkhForemanServices = KkhForemanServices();

  Future<void> _loadData() async {
    try {
      final response = await _kkhForemanServices.getAllKkh();
      if (response['status'] == 'success' && response['kkh'] != null) {
        setState(() {
          data = List<Map<String, dynamic>>.from(response['kkh']);
          isLoading = false;
        });
        print(data);
      } else {
        print('Failed to load Kkh data or no data available.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred while loading Kkh history data: $e');
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
    // Sort data so that items with isValidated == false appear first
    data.sort((a, b) {
      final aValidation = a['fValidation'] ?? false;
      final bValidation = b['fValidation'] ?? false;

      // Sorting such that false (not validated) comes first
      if (aValidation == bValidation) {
        return 0;
      } else if (!aValidation && bValidation) {
        return -1;
      } else {
        return 1;
      }
    });

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
            : const Text('Validation form KKH'),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF304FFE)))
          : data.isEmpty // Check if there's no data
          ? const Center(
        child: Text(
          'Tidak ada KKH',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: data
            .where((item) {
          final createdAt = item['createdAt'] != null
              ? (item['createdAt'] as Timestamp).toDate().toString().toLowerCase()
              : '';
          // Check if 'User' exists before trying to access 'username'
          final userName = (item['User'] != null && item['User']['username'] != null)
              ? item['User']['username']?.toLowerCase() ?? ''
              : '';
          final complaint = item['complaint']?.toLowerCase() ?? '';
          return createdAt.contains(filterText) ||
              userName.contains(filterText) || complaint.contains(filterText);
        })
            .map((item) => _buildCard(context, item))
            .toList(),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item) {
    print(item);
    final createdAt = item['createdAt'];
    final date = item['date'];
    // Check if 'User' exists before accessing 'username'
    final userName = (item['user'] != null && item['user']['username'] != null)
        ? item['user']['username']
        : 'Unknown User';
    final complaint = item['complaint'];

    if (createdAt == null || userName == null || complaint == null) {
      return const SizedBox();
    }

    Color complaintColor;
    switch (complaint) {
      case 'Fit to work':
        complaintColor = Colors.green;
        break;
      case 'On Monitoring':
        complaintColor = Colors.orange;
        break;
      case 'Kurang Tidur':
        complaintColor = Colors.red;
        break;
      default:
        complaintColor = Colors.black; // Default color if no match found
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryKkhScreen(
              kkhId: item['kkhId'] ?? '',
              date: item['date'] ?? '',
              totalJamTidur: item['totaltime'] ?? '',
              role: role,
              imageUrl: item['imageUrl'] ?? '',
              isValidated: item['fValidation'] ?? false,
              subtitle: '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$date - $userName'),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: (item['fValidation'] ?? false) ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (item['fValidation'] ?? false)
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text(
            complaint,
            style: TextStyle(
              color: complaintColor,
            ),
          ),
        ),
      ),
    );
  }
}
