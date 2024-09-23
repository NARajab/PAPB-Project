import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './foreman_validation_p2h.dart';
import '../../services/p2h_foreman_services.dart';

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

  late ForemanServices _data;

  @override
  void initState(){
    super.initState();
    _data = ForemanServices();
    _loadData();
    _loadRole();
  }

  Future<void> _loadData() async {
    try{
      final response = await _data.getAllP2hUsers();
      if (response['status'] == 'success' && response['p2h'] != null) {
        setState(() {
          data = List<Map<String, dynamic>>.from(response['p2h']);
          isLoading = false; // Set isLoading menjadi false setelah data dimuat
        });
      } else {
        print('Failed to load P2h data or no data available.');
        setState(() {
          isLoading = false; // Set isLoading menjadi false jika data tidak tersedia
        });
      }
    } catch (e){
      print('Error occurred while loading P2h history data: $e');
      setState(() {
        isLoading = false; // Set isLoading menjadi false jika terjadi error
      });
    }
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        role = decodedToken['role'] ?? ''; // Extract role from token
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = data
        .where((item) {
      final p2h = item['P2h'] ?? {};

      final date = p2h['date']?.toLowerCase() ?? '';
      final vehicleType = p2h['Vehicle']?['type']?.toLowerCase() ?? '';
      final jobsite = p2h['jobsite']?.toLowerCase() ?? '';

      return date.contains(filterText) ||
          vehicleType.contains(filterText) ||
          jobsite.contains(filterText);
    })
        .toList();

    filteredData.sort((a, b) {
      final p2hA = a['P2h'];
      final p2hB = b['P2h'];

      DateTime? dateA = DateTime.tryParse(a['P2h']['createdAt']);
      DateTime? dateB = DateTime.tryParse(b['P2h']['createdAt']);

      int dateComparison = (dateB ?? DateTime.now()).compareTo(dateA ?? DateTime.now());
      if (dateComparison != 0) {
        return dateComparison;
      }

      bool isValidatedA = a['fValidation'] as bool;
      bool isValidatedB = b['fValidation'] as bool;
      return isValidatedA ? 1 : -1; // false (not validated) should come first
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
              Navigator.pop(context);
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
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: filteredData
            .map((item) {
          final p2h = item['P2h'];
          final int p2hUserId = item['id'] as int? ?? 0;
          final int p2hId = item['p2hId'] as int? ?? 0; // Default to 0 or handle it as needed
          final String title = p2h['date'] ?? 'No Title';
          final String subtitle = item['User']['name'] ?? 'No Subtitle';
          final String idVehicle = p2h['Vehicle']['type'].toString() ?? 'Unknown Vehicle';
          final String vehicle = p2h['Vehicle']['type'] ?? 'Unknown Vehicle';
          final String date = p2h['date'] ?? 'No Date';
          final bool isValidated = item['fValidation'] as bool? ?? false;

          return _buildCard(
              context, p2hUserId, p2hId,
              title,
              subtitle,
              idVehicle,
              date,
              role,
              isValidated,
              vehicle
          );
        }).toList(),
      ),
    );
  }


  Widget _buildCard(BuildContext context, int p2hUserId, int p2hId, String title, String subtitle, String idVehicle, String date, String role, bool isValidated, String vehicle) {
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
              Text(title ?? 'No Title'),
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
          subtitle: Text('$vehicle - $subtitle' ?? 'No Subtitle'),
        ),
      ),
    );
  }
}

void navigateToForemanValidationP2h(BuildContext context, int p2hUserId, int p2hId, String idVehicle, String date, String role) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Foremanvalidationp2hScreen(p2hId: p2hId, p2hUserId: p2hUserId, idVehicle: idVehicle, date: date, role: role),
    ),
  );
}
