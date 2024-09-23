import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import './history_p2h.dart';
import 'history_kkh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/p2h_services.dart';
import '../services/kkh_services.dart';

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

  late P2hHistoryServices _p2hHistoryServices;
  late KkhHistoryServices _kkhHistoryServices;

  @override
  void initState() {
    super.initState();
    _p2hHistoryServices = P2hHistoryServices();
    _kkhHistoryServices = KkhHistoryServices();
    _loadP2hHistoryData();
    _loadKkhHistoryData();
  }

  Future<void> _loadP2hHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'];

        final Map<String, dynamic> response;
        if (role == 'Driver') {
          response = await _p2hHistoryServices.getAllP2h(token);
        } else if (role == 'Forman') {
          response = await _p2hHistoryServices.getAllP2hUser();
        } else {
          print('Unknown role: $role');
          setState(() {
            isLoading = false;
          });
          return;
        }
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
      } catch (e) {
        print('Error occurred while loading P2h history data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('No token found, unable to load P2h history data.');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _loadKkhHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'];

        final Map<String, dynamic> response;
        if (role == 'Driver') {
          response = await _kkhHistoryServices.getAllKkh(token);
        } else if (role == 'Forman') {
          response = await _kkhHistoryServices.getAllKkhUser();
        } else {
          print('Unknown role: $role');
          setState(() {
            isLoading = false;
          });
          return;
        }

        if (response['status'] == 'success' && response['kkh'] != null) {
          setState(() {
            kkhHistoryData = List<Map<String, dynamic>>.from(response['kkh']);
            isLoading = false;
          });
        } else {
          print('Failed to load P2h data or no data available.');
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
    } else {
      print('No token found, unable to load Kkh history data.');
      setState(() {
        isLoading = false;
      });
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
              ? const Center(child: CircularProgressIndicator())
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
    List<Map<String, dynamic>> filteredData = p2hHistoryData.where((item) =>
    item['P2h']['date'] != null &&
        item['P2h']['Vehicle']['type'] != null &&
        item['P2h']['date']!.toLowerCase().contains(filterText.toLowerCase()) ||
        item['P2h']['Vehicle']['type']!.toLowerCase().contains(filterText.toLowerCase())
    ).toList();

    // Sorting the filtered data
    filteredData.sort((a, b) {
      DateTime? dateA = DateTime.tryParse(a['P2h']['createdAt']);
      DateTime? dateB = DateTime.tryParse(b['P2h']['createdAt']);

      // Compare dates first (newest first)
      int dateComparison = (dateB ?? DateTime.now()).compareTo(dateA ?? DateTime.now());
      if (dateComparison != 0) {
        return dateComparison;
      }

      // If dates are the same, compare isValidated (false first)
      bool isValidatedA = a['dValidation'] == true;
      bool isValidatedB = b['dValidation'] == true;
      return isValidatedA ? 1 : -1; // false (not validated) should come first
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
              ? const Center(child: Text('No results found'))
              : ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            children: filteredData.map((item) => GestureDetector(
              onTap: () {
                navigateToHistoryP2h(
                    context,
                    item['id'],
                    item['P2h']['id'],
                    item['P2h']['Vehicle']['type'],
                    item['P2h']['date'],
                    'driver', // Assume role is 'driver' for now
                    item['fValidation'].toString()
                );
              },
              child: Card(
                elevation: 3,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['P2h']['date']}'),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item['fValidation'] == true ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item['fValidation'] == true
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
                  subtitle: Text('${item['P2h']['Vehicle']['type']}'),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }


  Widget _buildKKHTab(List<Map<String, dynamic>> kkhData) {
    List<Map<String, dynamic>> filteredData = kkhData.where((item) {
      String createdAt = item['createdAt'] ?? '';
      String complaint = item['complaint'] ?? '';
      return createdAt.toLowerCase().contains(filterText) ||
          complaint.toLowerCase().contains(filterText);
    }).toList();

    filteredData.sort((a, b) {
      DateTime? dateA;
      DateTime? dateB;

      try {
        dateA = DateTime.tryParse(a['createdAt']);
        dateB = DateTime.tryParse(b['createdAt']);
      } catch (e) {
        print('Error parsing date: $e');
      }

      return (dateB ?? DateTime.now()).compareTo(dateA ?? DateTime.now());
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
              ? const Center(child: Text('No results found'))
              : ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            children: filteredData.map((historyItem) {
              String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id').format(DateTime.parse(historyItem['createdAt']));
              Color statusColor;
              switch (historyItem['complaint']) {
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
                  statusColor = Colors.black; // Default color
              }
              return GestureDetector(
                onTap: () {
                  navigateToHistoryKkh(
                    context,
                    formattedDate,
                    historyItem['id'] as int,
                    historyItem['date'] as String,
                    historyItem['complaint'] as String,
                    historyItem['totaltime'] as String,
                    historyItem['imageUrl'] as String,
                    historyItem['fValidation'] == true,
                  );
                },
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(historyItem['imageUrl']),
                    ),
                    title: Text(
                      historyItem['date'],
                      style: const TextStyle(
                          fontSize: 14
                      ),
                    ),
                    subtitle: Text(
                      historyItem['complaint'] ?? '',
                      style: TextStyle(color: statusColor),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: historyItem['fValidation'] ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: historyItem['fValidation']
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
                        Text(historyItem['totaltime']),
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


  void navigateToHistoryP2h(BuildContext context,int p2hUserId, int p2hId, String idVehicle, String date, String role, String isValidated) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryP2hScreen(
          p2hUserId: p2hUserId,
          p2hId: p2hId,
          idVehicle: idVehicle,
          date: date,
          role: role,
          isValidated: isValidated == 'true',
        ),
      ),
    );
  }

  void navigateToHistoryKkh(
      BuildContext context,
      String formattedDate,
      int kkhId,
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