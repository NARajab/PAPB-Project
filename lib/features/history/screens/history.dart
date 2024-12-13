import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import './history_p2h.dart';
import 'history_kkh.dart';
import '../services/p2h_services.dart';
import '../services/p2h_services/p2h_service.dart';
import '../services/kkh_services/kkh_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filterText = '';
  bool isSearching = false;
  bool isLoading = true;

  List<Map<String, dynamic>> p2hHistoryData = [];
  List<Map<String, dynamic>> kkhHistoryData = [];

  late P2hServices _p2hServices;
  late KkhServices _kkhServices;
  late P2hHistoryServices _p2hHistoryServices;

  @override
  void initState() {
    super.initState();
    _p2hServices = P2hServices();
    _kkhServices = KkhServices();
    _p2hHistoryServices = P2hHistoryServices();
    _loadP2hHistoryData();
    _loadKkhHistoryData();
  }

  Future<void> _loadP2hHistoryData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc.get('role');

          dynamic response;

          if (role == 'Driver') {
            response = await _p2hServices.fetchP2hUsersWithDetails(user.uid);
          } else if (role == 'Forman') {
            response = await _p2hServices.fetchAllP2hUsersWithDetails();
          } else {
            print('Unknown role: $role');
            setState(() {
              isLoading = false;
            });
            return;
          }
          print(response);

          if (response is Map<String, dynamic>) {
            if (response['status'] == 'success' && response['p2h'] != null) {
              setState(() {
                p2hHistoryData = List<Map<String, dynamic>>.from(response['p2h']);
                isLoading = false;
              });
            } else {
              print('Failed to load P2h data or no data available.');
              setState(() {
                isLoading = false;
              });
            }
          }
          else if (response is List<Map<String, dynamic>>) {
            setState(() {
              p2hHistoryData = response;
              isLoading = false;
            });
          } else {
            print('Unexpected response format.');
            setState(() {
              isLoading = false;
            });
          }
        } else {
          print('User document not found in Firestore.');
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error occurred while loading P2h history data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('No user found, unable to load P2h history data.');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _loadKkhHistoryData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String userId = currentUser.uid;

        // Ambil peran pengguna terlebih dahulu
        String role = await _getUserRole(userId);

        dynamic response;

        // Tentukan cara mengambil data berdasarkan peran
        if (role == 'Driver') {
          response = await _kkhServices.getKkhByUserId(userId);
        } else if (role == 'Forman') {
          response = await _kkhServices.getAllKkh();
        } else {
          print('Unknown role: $role');
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Proses respons yang diterima
        if (response['status'] == 'success' && response['kkh'] != null) {
          setState(() {
            kkhHistoryData = List<Map<String, dynamic>>.from(response['kkh']);
            isLoading = false;
          });
        } else {
          print('Failed to load KKH data or no data available.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('No current user found.');
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

  Future<String> _getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.get('role') ?? '';  // Mengambil peran pengguna
      } else {
        return ''; // Jika tidak ada data pengguna
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return ''; // Kembalikan string kosong jika ada error
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isSearching = !isSearching;
            if (!isSearching) {
              filterText = '';
            }
          });
        },
        backgroundColor: const Color(0xFF304FFE),
        child: const Icon(Icons.search, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: const Color(0xFF304FFE),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              dividerHeight: 2,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: 'P2H'),
                Tab(text: 'KKH'),
              ],
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF304FFE)))
              : Container(
            color: Colors.white,
            child: TabBarView(
              children: [
                _buildP2HTab(),
                _buildKKHTab(kkhHistoryData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildP2HTab() {
    List<Map<String, dynamic>> filteredData = p2hHistoryData.where((item) {
      return item['p2h']['date'] != null &&
          item['vehicle']['type'] != null &&
          (item['p2h']['date']!.toLowerCase().contains(filterText.toLowerCase()) ||
              item['vehicle']['type']!.toLowerCase().contains(filterText.toLowerCase()));
    }).toList();

    filteredData.sort((a, b) {
      DateTime? dateA = a['p2h']['createdAt']?.toDate();
      DateTime? dateB = b['p2h']['createdAt']?.toDate();

      int dateComparison = (dateB ?? DateTime.now()).compareTo(dateA ?? DateTime.now());
      if (dateComparison != 0) {
        return dateComparison;
      }

      bool isValidatedA = a['p2hUser']['dValidation'] == true;
      bool isValidatedB = b['p2hUser']['dValidation'] == true;
      return isValidatedA ? 1 : -1;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSearching)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  filterText = value.toLowerCase();
                });
              },
            ),
          ),
        Expanded(
          child: filteredData.isEmpty
              ? const Center(child: Text(' '))
              : ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            children: filteredData.map((item) {
              String p2hDate = item['p2h']['date'] ?? 'Unknown Date';
              String vehicleType = item['vehicle']['type'] ?? 'Unknown Vehicle';
              bool fValidation = item['p2hUser']['fValidation'] ?? false;
              String p2hId = item['p2h']['id'] ?? 'Unknown ID';

              return GestureDetector(
                onTap: () {
                  navigateToHistoryP2h(
                    context,
                    item['p2hUser']['id'] ?? 'Unknown User ID', // Handle null for p2hUser id
                    p2hId,
                    vehicleType,
                    p2hDate,
                    'driver',
                    fValidation,
                  );
                },
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p2hDate),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: fValidation ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: fValidation
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.red.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(vehicleType),
                  ),
                ),
              );
            }).toList(),
          )
        ),
      ],
    );
  }

  Widget _buildKKHTab(List<Map<String, dynamic>> kkhData) {
    List<Map<String, dynamic>> filteredData = kkhData.where((item) {
      String createdAt = item['createdAt']?.toDate()?.toString() ?? '';
      String complaint = item['complaint'] ?? '';
      return createdAt.toLowerCase().contains(filterText) ||
          complaint.toLowerCase().contains(filterText);
    }).toList();

    filteredData.sort((a, b) {
      DateTime dateA = a['createdAt']?.toDate() ?? DateTime.now();
      DateTime dateB = b['createdAt']?.toDate() ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSearching)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  filterText = value.toLowerCase();
                });
              },
            ),
          ),
        Expanded(
          child: filteredData.isEmpty
              ? const Center(child: Text(''))
              : ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            children: filteredData.map((historyItem) {
              DateTime createdAt =
                  historyItem['createdAt']?.toDate() ?? DateTime.now();
              String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id')
                  .format(createdAt);

              String complaint = historyItem['complaint'] ?? 'No complaint';
              String imageUrl = historyItem['imageUrl'] ?? '';
              String totalTime = historyItem['totalJamTidur'] ?? '0 Jam';
              String date = historyItem['date'] ?? 'No date available';
              String id = historyItem['id'] ?? 'Unknown ID';

              bool fValidation = historyItem['fValidation'] == true;

              Color statusColor;
              switch (complaint) {
                case 'Fit to work':
                  statusColor = Colors.green;
                  break;
                case 'On Monitoring':
                  statusColor = Colors.orange;
                  break;
                case 'Kurang Tidur':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.black;
              }

              return GestureDetector(
                onTap: () {
                  navigateToHistoryKkh(
                    context,
                    formattedDate,
                    id,
                    date,
                    complaint,
                    totalTime,
                    imageUrl,
                    fValidation,
                  );
                },
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      date,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      complaint,
                      style: TextStyle(color: statusColor),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: fValidation ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: fValidation
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.red.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(totalTime),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  void navigateToHistoryP2h(BuildContext context,String p2hUserId, String p2hId, String idVehicle, String date, String role, bool isValidated) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryP2hScreen(
          p2hUserId: p2hUserId,
          p2hId: p2hId,
          idVehicle: idVehicle,
          date: date,
          role: role,
          isValidated: isValidated,
        ),
      ),
    );
  }

  void navigateToHistoryKkh(
      BuildContext context,
      String formattedDate,
      String kkhId,
      String date,
      String complaint,
      String totaltime,
      String imageUrl,
      bool isValidated) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryKkhScreen(
          date: date,
          subtitle: complaint,
          totalJamTidur: totaltime,
          imageUrl: imageUrl,
          isValidated: isValidated,
          role: '',
          kkhId: kkhId,
        ),
      ),
    );
  }
}