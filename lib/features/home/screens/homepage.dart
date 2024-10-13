import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../setting/screens/setting.dart';
import '../../history/screens/history.dart';
import './foreman/foreman_kkh.dart';
import './foreman/foreman_p2h.dart';
import './kkh.dart';
import './p2h/pph.dart';
import '../services/p2h_services.dart';
import '../services/kkh_services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const HistoryScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            title: Image.asset('assets/images/appbar.png', height: 35),
            automaticallyImplyLeading: false,
            toolbarHeight: 35,

          ),
        ),
      ),
      body:_pages[_currentIndex],
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        height: 55,
        backgroundColor: Colors.white,
        onItemSelected: (index) => setState(() {
          _currentIndex = index;

        }),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            activeColor: Colors.blue,
            inactiveColor: Colors.grey,
          ),
          FlashyTabBarItem(
              icon: const Icon(Icons.history),
              title: const Text('History'),
              activeColor: Colors.blue,
              inactiveColor: Colors.grey
          ),
          FlashyTabBarItem(
              icon: const Icon(Icons.settings),
              title: const Text('Settings'),
              activeColor: Colors.blue,
              inactiveColor: Colors.grey
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _currentPage = 0;
  String? _token;
  String? _role;
  Future<int>? _p2hCountFuture;
  Future<int>? _kkhCountFuture;
  Future<Map<String, dynamic>>? _lastP2hFuture;
  Future<Map<String, dynamic>>? _lastKkhFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _loadToken().then((_) {
      setState(() {
        _p2hCountFuture = _fetchP2hData();
        _kkhCountFuture = _fetchKkhData();
        _lastP2hFuture = _fetchLastP2hData();
        _lastKkhFuture = _fetchLastKkhData();
      });
    });
  }


  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      if (_token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
        _role = decodedToken['role'];
      }
    });
  }

  Future<int> _fetchP2hData() async {
    try {
      P2hServices p2hServices = P2hServices();
      return await p2hServices.getAllP2hLength();
    } catch (e) {
      return 0;
    }
  }

  Future<int> _fetchKkhData() async {
    try {
      KkhServices kkhServices = KkhServices();
      return await kkhServices.getAllKkhLength();
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> _fetchLastP2hData() async {
    try {
      if (_token == null) {
        throw Exception('Token is missing');
      }
      P2hServices p2hServices = P2hServices();
      final data = await p2hServices.getLastP2hByUser(_token!);
      return data['lastP2h']['P2h'];
    } catch (e) {
      print('Error fetching last P2H data: $e');
      return {'date': 'N/A'};
    }
  }

  Future<Map<String, dynamic>> _fetchLastKkhData() async {
    try {
      if (_token == null) {
        throw Exception('Token is missing');
      }
      KkhServices kkhServices = KkhServices();
      final data = await kkhServices.getLastKkhByUser(_token!);
      return data['kkh'];
    } catch (e) {
      print('Error fetching last P2H data: $e');
      return {'date': 'N/A'};
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildWidgetOptions(context),
          _buildSubmissionList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    initialPage: _currentPage,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                  items: [
                    'assets/images/header_image1.png',
                    'assets/images/header_image2.jpg',
                    'assets/images/header_image3.png',
                  ].map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<int>(
                  future: _p2hCountFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCounterP2h(
                        'Total Submission P2H Saat Ini',
                        '',
                        isLoading: true, // Pass loading state
                      );
                    } else if (snapshot.hasError) {
                      return _buildCounterP2h('Total Submission P2H Saat Ini', 'Error');
                    } else if (snapshot.hasData) {
                      return _buildCounterP2h('Total Submission P2H Saat Ini', '${snapshot.data} KALI');
                    } else {
                      return _buildCounterP2h('Total Submission P2H Saat Ini', '0 KALI');
                    }
                  },
                ),
                FutureBuilder<int>(
                  future: _kkhCountFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCounterP2h(
                        'Total Submission KKH Saat Ini',
                        '',
                        isLoading: true, // Pass loading state
                      );
                    } else if (snapshot.hasError) {
                      return _buildCounterP2h('Total Submission KKH Saat Ini', 'Error');
                    } else if (snapshot.hasData) {
                      return _buildCounterP2h('Total Submission KKH Saat Ini', '${snapshot.data} KALI');
                    } else {
                      return _buildCounterP2h('Total Submission KKH Saat Ini', '0 KALI');
                    }
                  },
                ),

              ],
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildCounterP2h(String title, String count, {bool isLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
        isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: Color(0xFF304FFE),
          ),
        )
            : Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  Widget _buildWidgetOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOptionCard(context, 'P2H', Icons.settings, '$_role'),
          _buildOptionCard(context, 'KKH', Icons.work, '$_role'),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon, String role) {
    return GestureDetector(
      onTap: () {
        if (title == 'P2H') {
          if (role == 'Driver') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => P2hScreen()),
            );
          } else if (role == 'Forman') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForemanP2h()),
            );
          }
        } else if (title == 'KKH') {
          if (role == 'Driver') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KkhScreen()),
            );
          } else if (role == 'Forman') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForemanKkh()),
            );
          }
        }
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        child: Container(
          width: 170,
          height: 170,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: title == 'P2H' ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submission Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _lastP2hFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSubmissionItemWithLoading('P2H Submission', Icons.settings, Colors.green);
              } else if (snapshot.hasError) {
                return _buildSubmissionItem('P2H Submission', 'Error', Icons.settings, Colors.green);
              } else if (snapshot.hasData) {
                String date = snapshot.data?['date'] ?? 'N/A';
                return _buildSubmissionItem('P2H Submission', date, Icons.settings, Colors.green);
              } else {
                return _buildSubmissionItem('P2H Submission', 'No Data', Icons.settings, Colors.green);
              }
            },
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _lastKkhFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSubmissionItemWithLoading('KKH Submission', Icons.work, Colors.blue);
              } else if (snapshot.hasError) {
                return _buildSubmissionItem('KKH Submission', 'Error', Icons.work, Colors.blue);
              } else if (snapshot.hasData) {
                String date = snapshot.data?['date'] ?? 'N/A';
                return _buildSubmissionItem('KKH Submission', date, Icons.work, Colors.blue);
              } else {
                return _buildSubmissionItem('KKH Submission', 'No Data', Icons.work, Colors.blue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionItem(String title, String subtitle, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.7),
        child: ListTile(
          leading: Icon(icon, size: 35, color: iconColor),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }

  Widget _buildSubmissionItemWithLoading(String title, IconData icon, Color iconColor) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Card(
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.7),
          child: ListTile(
            leading: Icon(icon, size: 35, color: iconColor),
            title: Text(title),
            subtitle: const Row(
              children: [
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    color: Color(0xFF304FFE),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }



}
