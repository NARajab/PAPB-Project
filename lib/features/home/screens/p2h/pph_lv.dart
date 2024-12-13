import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/features/home/services/p2h_services/light_vehicle_service.dart';
import 'package:another_flushbar/flushbar.dart';

class P2hLvScreen extends StatefulWidget {
  final int id;
  final String title;

  const P2hLvScreen({super.key, required this.id, required this.title});

  @override
  P2hLvScreenState createState() => P2hLvScreenState();
}

class P2hLvScreenState extends State<P2hLvScreen> {
  List<List<Map<String, String>>> cardItems = [
    [
      {'item': 'Ban & Baut roda', 'field': 'bdbr', 'kbj' : 'AA' },
      {'item': 'Kerusakan akibat insiden ***)', 'field': 'kai', 'kbj': 'AA'},
      {'item': 'Kebocoran oli transmisi', 'field': 'kot', 'kbj' : 'AA'},
      {'item': 'Tiang bendera 4M (tambang)', 'field': 'tb4m', 'kbj': 'A'},
      {'item': 'BBC minimum 25% dari Cap. Tangki', 'field': 'bbcmin', 'kbj' : 'AA'},
      {'item': 'Kebersihan alat', 'field': 'kasa', 'kbj': 'A'},
      {'item': 'Safety cone 2', 'field': 'sc', 'kbj': 'AA'},
      {'item': 'Ganjal 2', 'field': 'g2', 'kbj': 'A'},
      {'item': 'Dongkrak', 'field': 'dong', 'kbj': 'A'},
      {'item': 'Kunci roda', 'field': 'kr', 'kbj': 'A'},
      {'item': 'Back alarm / Alarm mundur', 'field': 'ba', 'kbj' : 'AA'},
      {'item': 'Kelainan saat operasi', 'field': 'kso', 'kbj': 'AA'},
      {'item': 'Kebersihan aki / battery', 'field': 'ka', 'kbj' : 'A'}
    ],

    [
      {'item':'Air conditioner (AC)', 'field': 'ac', 'kbj': 'A'},
      {'item':'Fungsi brake / rem', 'field': 'fb', 'kbj': 'AA'},
      {'item':'Fungsi steering / kemudi', 'field': 'fs', 'kbj':'AA'},
      {'item':'Fungsi seat belt / sabuk pengaman', 'field': 'fsb', 'kbj':'AA'},
      {'item':'Fungsi semua lampu', 'field': 'fsl', 'kbj': 'AA'},
      {'item':'Fungsi Rotary lamp', 'field': 'frl', 'kbj':'AA'},
      {'item':'Fungsi mirror / spion', 'field': 'fm', 'kbj': 'AA'},
      {'item':'Fungsi wiper dan air wiper', 'field': 'fwdaw', 'kbj': 'AA'},
      {'item':'Fungsi kontrol panel', 'field': 'fkp', 'kbj': 'AA'},
      {'item':'Fungsi horn / klakson', 'field': 'fh', 'kbj': 'AA'},
      {'item':'Fire Extinguiser / APAR', 'field': 'feapar', 'kbj': 'AA'},
      {'item':'Fungsi radio komunikasi', 'field': 'frk', 'kbj': 'AA'},
      {'item':'Kebersihan ruang kabin', 'field': 'krk', 'kbj': 'A'},
      {'item':'GPS', 'field': 'gps', 'kbj':'AA'},
      {'item':'IN Car Camera', 'field': 'icc', 'kbj': 'AA'}
    ],
    [
      {'item':'Air Radiator', 'field': 'ar', 'kbj': 'AA'},
      {'item':'Oil Engine / Oli Mesin', 'field': 'oe', 'kbj': 'AA'},
      {'item':'Oli Steering', 'field': 'os', 'kbj': 'AA'},
      {'item':'Fan belt / semua tali kipas', 'field': 'fba', 'kbj':'A'}
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
  TextEditingController kmAwalController = TextEditingController();
  TextEditingController kmAkhirController = TextEditingController();
  TextEditingController jobSiteController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
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
    kmAwalController.dispose();
    kmAkhirController.dispose();
    jobSiteController.dispose();
    lokasiController.dispose();
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
    return 'Unknown'; // Default jika terjadi error
  }


  void submitData() async {
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
      'time': timeController.text.trim(),
      'earlykm': kmAwalController.text.trim(),
      'endkm': kmAkhirController.text.trim(),
      'ntsAroundU': aroundUnitNotesController.text.trim(),
      'ntsInTheCabinU': inTheCabinNotesController.text.trim(),
      'ntsMachineRoom': machineRoomNotesController.text.trim(),
      'jobsite': jobSiteController.text.trim(),
      'location': lokasiController.text.trim()
    };

    Map<String, dynamic> requestData = {
      ...checklistData,
      ...inputData,
      'idVehicle': selectedVehicleId,
      'shift': selectedShift,
      'username': username,
    };

    LightVehicleService _lvservice = LightVehicleService();

    try {
      await _lvservice.submitP2hLv(requestData, context);
      if (mounted) {
        _showFlushbar('Success', 'Data submitted successfully!', Colors.green);
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
                      value: itemChecklist[item['field']] ?? false,
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
        title: const Text('Light Vehicle'),
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
            _buildTextField(
              kmAwalController,
              'KM Awal',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              kmAkhirController,
              'KM Akhir',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              jobSiteController,
              'Job Site',
            ),
            _buildTextField(
              lokasiController,
              'Lokasi',
            ),
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
                    onPressed: submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF304FFE),
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: const Text('Submit'),
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
