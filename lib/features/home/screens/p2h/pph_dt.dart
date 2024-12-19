import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:my_project/features/home/screens/p2h/pph.dart';

import '../../services/p2h_services/dump_truck_service.dart';

class P2hDtScreen extends StatefulWidget {
  final int id;
  final String title;

  const P2hDtScreen({super.key, required this.id, required this.title});

  @override
  P2hDtScreenState createState() => P2hDtScreenState();
}

class P2hDtScreenState extends State<P2hDtScreen> {
  bool _isLoading = false;
  List<List<Map<String, String>>> cardItems = [
    [
      {'item': 'Ban & Baut roda', 'field': 'bdbr', 'kbj': 'AA'},
      {'item': 'Kerusakan akibat insiden ***)', 'field': 'kai', 'kbj': 'AA'},
      {'item': 'Kebocoran oli transmisi', 'field': 'kot', 'kbj': 'AA'},
      {'item': 'Semua oli Hydraulic Dump', 'field': 'sohd', 'kbj': 'AA'},
      {'item': 'Fuel drain / Buang air dari tanki BBC', 'field': 'fd', 'kbj': 'A'},
      {'item': 'BBC minimum 25% dari Cap. Tangki', 'field': 'bbcmin', 'kbj': 'A'},
      {'item': 'Buang air dalam tanki udara', 'field': 'badtu', 'kbj': 'A'},
      {'item': 'Kebersihan accessories safety', 'field': 'kas', 'kbj': 'A'},
      {'item': 'Tail Gate', 'field': 'tg', 'kbj': 'AA'},
      {'item': 'Alarm mundur', 'field': 'ba', 'kbj': 'AA'},
      {'item': 'Ganjal 2', 'field': 'g2', 'kbj': 'A'},
      {'item': 'Safety cone (simpan diluar kabin) 2', 'field': 'sc', 'kbj': 'AA'},
      {'item': 'Kebersihan aki / battery', 'field': 'ka', 'kbj': 'A'}
    ],
    [
      {'item': 'Air conditioner (AC)', 'field': 'ac', 'kbj': 'A'},
      {'item': 'Fungsi brake / rem', 'field': 'fb', 'kbj': 'AA'},
      {'item': 'Fungsi steering / kemudi', 'field': 'fs', 'kbj': 'AA'},
      {'item': 'Fungsi seat belt / sabuk pengaman', 'field': 'fsb', 'kbj': 'AA'},
      {'item': 'Fungsi semua lampu', 'field': 'fsl', 'kbj': 'AA'},
      {'item': 'Fungsi Rotary lamp', 'field': 'frl', 'kbj': 'AA'},
      {'item': 'Fungsi mirror / spion', 'field': 'fm', 'kbj': 'AA'},
      {'item': 'Fungsi wiper dan air wiper', 'field': 'fwdaw', 'kbj': 'AA'},
      {'item': 'Fungsi horn / klakson', 'field': 'fh', 'kbj': 'AA'},
      {'item': 'Fire Extinguiser / APAR', 'field': 'feapar', 'kbj': 'AA'},
      {'item': 'Fungsi kontrol panel', 'field': 'fkp', 'kbj': 'AA'},
      {'item': 'Fungsi tuas dump', 'field': 'ftd', 'kbj': 'A'},
      {'item': 'Fungsi radio komunikasi', 'field': 'frk', 'kbj': 'AA'},
      {'item': 'Kebersihan ruang kabin', 'field': 'krk', 'kbj': 'A'},
    ],
    [
      {'item': 'Air Radiator', 'field': 'ar', 'kbj': 'AA'},
      {'item': 'Oil Engine / Oli Mesin', 'field': 'oe', 'kbj': 'AA'},
    ],
  ];

  List<String> cardTitles = [
    'Pemeriksaan Keliling Unit',
    'Pemeriksaan di dalam kabin',
    'Pemeriksaan di ruang mesin',
  ];

  List<String> importantNotes = [
    '1. Kode "AA" = Unit tidak bisa di operasikan sebelum ada persetujuan dari forman / sipervisor',
    '2. Kode "A" = Kerusakan yang harus diperbaiki dalam waktu 1 x 1 SHIFT',
    '3. P2H harus diserahkan ke forman / Spv. Diawali shift dan dilengkapi tanda tangan',
    '4. Mengoprasikan alat dengan kerusakan kode "AA" akan dikenakan sangsi sesuai dengan peraturan',
    '5. Opr = Operator',
    '6. KBJ = Kode bahaya setelah penilaian resiko'
  ];

  Map<String, bool> itemChecklist = {};
  List<dynamic> vehicles = [];

  TextEditingController textEditingController = TextEditingController();

  TextEditingController timeController = TextEditingController();
  TextEditingController hmAwalController = TextEditingController();
  TextEditingController hmAkhirController = TextEditingController();
  TextEditingController kmAwalController = TextEditingController();
  TextEditingController kmAkhirController = TextEditingController();
  TextEditingController aroundUnitNotesController = TextEditingController();
  TextEditingController inTheCabinNotesController = TextEditingController();
  TextEditingController machineRoomNotesController = TextEditingController();

  Map<String, TextEditingController> notesControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchVehicleData();
    _fetchUsername();
    for (var items in cardItems) {
      for (var item in items) {
        itemChecklist[item['field'] ?? ''] = false;
      }
    }
    notesControllers = {
      'Pemeriksaan Keliling Unit': aroundUnitNotesController,
      'Pemeriksaan di dalam kabin': inTheCabinNotesController,
      'Pemeriksaan di ruang mesin': machineRoomNotesController,
    };
  }

  String? selectedVehicleId;
  String? selectedShift;

  @override
  void dispose() {
    textEditingController.dispose();
    hmAwalController.dispose();
    hmAkhirController.dispose();
    kmAwalController.dispose();
    kmAkhirController.dispose();
    aroundUnitNotesController.dispose();
    inTheCabinNotesController.dispose();
    machineRoomNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicleData() async {
    try {
      final vehicleCollection = FirebaseFirestore.instance.collection('vehicles');

      final querySnapshot = await vehicleCollection
          .where('type', isEqualTo: widget.title)
          .get();

      final List<dynamic> fetchedVehicles = querySnapshot.docs.map((doc) {
        final vehicleData = {
          'id': doc.id,
          ...doc.data(),
        };

        print('Fetched Vehicle ID: ${doc.id}');

        return vehicleData;
      }).toList();

      setState(() {
        vehicles = fetchedVehicles;
      });
    } catch (e) {
      print('Failed to fetch vehicles: $e');
    }
  }

  Future<String> _fetchUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        String username = userData.data()?['username'] ?? 'Unknown';
        return username;
      }
    } catch (e) {
      print('Failed to fetch username: $e');
    }
    return 'Unknown';
  }

  void submitData() async {
    setState(() {
      _isLoading = true;
    });
    if (selectedVehicleId == null || selectedVehicleId == -1) {
      if (mounted) {
        _showFlushbar('Error', 'Please select a vehicle before submitting.', Colors.red);
      }
      return;
    }
    if (selectedShift == null) {
      if (mounted) {
        _showFlushbar('Error', 'Please select a shift before submitting.', Colors.red);
      }
      return;
    }

    String username = await _fetchUsername();

    Map<String, int> checklistData = {};
    itemChecklist.forEach((key, value) {
      checklistData[key] = value ? 1 : 0;
    });

    Map<String, String> inputData = {
      'earlyhm': hmAwalController.text.trim(),
      'endhm': hmAkhirController.text.trim(),
      'earlykm': kmAwalController.text.trim(),
      'endkm': kmAkhirController.text.trim(),
      'time': timeController.text.trim(),
      'ntsAroundU': aroundUnitNotesController.text.trim(),
      'ntsInTheCabinU': inTheCabinNotesController.text.trim(),
      'ntsMachineRoom': machineRoomNotesController.text.trim(),
    };

    Map<String, dynamic> requestData = {
      ...checklistData,
      ...inputData,
      'idVehicle': selectedVehicleId,
      'shift': selectedShift,
      'username': username
    };

    DumpTruckService _dtservice = DumpTruckService();

    try {
      await _dtservice.submitP2hDt(requestData, context);
      if (mounted) {
        _showFlushbar('Success', 'Data submitted successfully!', Colors.green);

        await Future.delayed(const Duration(seconds: 3));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => P2hScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error $e');
      if (mounted) {
        _showFlushbar('Error', 'Failed to submit data: $e', Colors.red);
      }
    }
  }

  void _showFlushbar(String title, String message, Color backgroundColor) {
    if (mounted) {
      Flushbar(
        title: title,
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ).show(context);
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

  Widget _buildChecklistCard(String title, List<Map<String, String>> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: items.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item['item'] ?? '')),
                    const SizedBox(width: 10),
                    Text(item['kbj'] ?? ''),
                    const SizedBox(width: 10),
                    Checkbox(
                      value: itemChecklist[item['field']],
                      onChanged: (value) {
                        setState(() {
                          itemChecklist[item['field'] ?? ''] = value ?? false;
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            // Ensure 'title' here matches the key used in 'notesControllers'
            TextField(
              controller: notesControllers[title],
              decoration: const InputDecoration(
                labelText: 'Catatan atau temuan',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedVehicleId ?? '', // Gunakan String kosong sebagai default
      onChanged: vehicles.isNotEmpty
          ? (String? newValue) {
        setState(() {
          selectedVehicleId = newValue;
        });
      }
          : null,
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text("Pilih Unit"),
        ),
        ...vehicles.map((vehicle) {
          return DropdownMenuItem<String>(
            value: vehicle['id'], // Gunakan ID sebagai String
            child: Text(
              '${vehicle['modelu']} ${vehicle['nou']}', // Tampilkan ID
            ),
          );
        }).toList(),
      ],
      hint: selectedVehicleId == ''
          ? const Text("Pilih Unit")
          : null,
    );
  }

  Widget _buildShiftDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedShift,
      onChanged: (String? newValue) {
        setState(() {
          selectedShift = newValue;
        });
      },
      items: const [
        DropdownMenuItem<String>(
          value: 'Siang',
          child: Text('Siang'),
        ),
        DropdownMenuItem<String>(
          value: 'Malam',
          child: Text('Malam'),
        ),
      ],
      hint: const Text("Pilih Shift"),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: importantNotes.map((note) {
            return Text(
              note,
              style: const TextStyle(fontSize: 16),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Dump Truck'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleDropdown(),
            _buildTextField(
              timeController,
              'Jam',
              onTap: () => _selectTime(context, timeController),
            ),
            _buildShiftDropdown(),
            _buildTextField(hmAwalController, 'HM Awal', keyboardType: TextInputType.number),
            _buildTextField(hmAkhirController, 'HM Akhir', keyboardType: TextInputType.number),
            _buildTextField(kmAwalController, 'KM Awal', keyboardType: TextInputType.number),
            _buildTextField(kmAkhirController, 'KM Akhir', keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            Column(
              children: cardItems.asMap().entries.map((entry) {
                int index = entry.key;
                List<Map<String, String>> items = entry.value;
                return _buildChecklistCard(cardTitles[index], items);
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            _buildNotesSection(),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : submitData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                      backgroundColor: const Color(0xFF304FFE),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/p2h');
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }
}
