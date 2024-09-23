import 'package:flutter/material.dart';
import '../../services/p2h_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

class P2hBlScreen extends StatefulWidget {
  final int id;
  final String title;

  const P2hBlScreen({super.key, required this.id,  required this.title});

  @override
  _P2hScreenState createState() => _P2hScreenState();
}

class _P2hScreenState extends State<P2hBlScreen> {
  List<List<Map<String, String>>> cardItems = [
    [
      {'item': 'Kondisi Underacarriage', 'field': 'ku', 'kbj' : 'A'},
      {'item': 'Kerusakan akibat insiden ***)', 'field': 'kai', 'kbj': 'AA'},
      {'item': 'Level oli transmisi & kebocoran', 'field': 'lotk', 'kbj': 'AA'},
      {'item': 'Level oli damper & kebocoran', 'field': 'lodk', 'kbj' : 'AA'},
      {'item': 'Level oli pivot & kebocoran', 'field': 'lopk', 'kbj': 'AA'},
      {'item': 'Level oli hydraulic & kebocoran', 'field': 'lohk', 'kbj': 'AA'},
      {'item': 'Fuel drain / Buang air dari tanki BBC', 'field': 'fd', 'kbj': 'A'},
      {'item': 'BBC minimum 25% dari Cap. Tangki', 'field': 'bbcmin', 'kbj' : 'A'},
      {'item': 'Kebersihan accessories safety & Alat', 'field': 'kasa', 'kbj': 'A'},
      {'item': 'Kebocoran2 bila ada (oli, solar, grease)', 'field': 'kba', 'kbj': 'A'},
      {'item': 'Back alarm / Alarm mundur', 'field': 'ba', 'kbj' : 'AA'},
      {'item': 'Kebersihan aki / battery', 'field': 'ka', 'kbj' : 'A'}
    ],
    [
      {'item':'Air conditioner (AC)', 'field': 'ac', 'kbj': 'A'},
      {'item':'Fungsi steering / kemudi', 'field': 'fs', 'kbj':'AA'},
      {'item':'Fungsi seat belt / sabuk pengaman', 'field': 'fsb', 'kbj':'AA'},
      {'item':'Fungsi semua lampu', 'field': 'fsl', 'kbj': 'AA'},
      {'item':'Fungsi Rotary lamp', 'field': 'frl', 'kbj':'AA'},
      {'item':'Fungsi mirror / spion', 'field': 'fm', 'kbj': 'A'},
      {'item':'Fungsi wiper dan air wiper', 'field': 'fwdaw', 'kbj': 'A'},
      {'item':'Fungsi kontrol panel', 'field': 'fkp', 'kbj': 'AA'},
      {'item':'Fungsi horn / klakson', 'field': 'fh', 'kbj': 'AA'},
      {'item':'Fire Extinguiser / APAR', 'field': 'feapar', 'kbj': 'AA'},
      {'item':'Fungsi radio komunikasi', 'field': 'frk', 'kbj': 'AA'},
      {'item':'Kebersihan ruang kabin', 'field': 'krk', 'kbj': 'A'},
    ],
    [
      {'item':'Air Radiator', 'field': 'ar', 'kbj': 'AA'},
      {'item':'Oil Engine / Oli Mesin', 'field': 'oe', 'kbj': 'AA'},
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

  TextEditingController hmAwalController = TextEditingController();
  TextEditingController hmAkhirController = TextEditingController();
  TextEditingController timeController = TextEditingController();
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
  int? selectedVehicleId;
  String? selectedShift;

  @override
  void dispose() {
    textEditingController.dispose();
    hmAwalController.dispose();
    hmAkhirController.dispose();
    jobSiteController.dispose();
    lokasiController.dispose();
    aroundUnitNotesController.dispose();
    inTheCabinNotesController.dispose();
    machineRoomNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicleData() async {
    try {
      FormServices formServices = FormServices();
      final data = await formServices.getVehicleByType(widget.title);
      setState(() {
        vehicles = data['vehicles'] ?? [];
      });
    } catch (e) {
      print('Failed to fetch vehicles: $e');
    }
  }

  void submitData() async {
    Map<String, int> checklistData = {};
    itemChecklist.forEach((key, value) {
      checklistData[key] = value ? 1 : 0;
    });

    Map<String, String> inputData = {
      'earlyhm': hmAwalController.text.trim(),
      'endhm': hmAkhirController.text.trim(),
      'time': timeController.text.trim(),
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
      'shift' : selectedShift
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      FormServices formServices = FormServices();
      try {
        await formServices.submitP2hBl(requestData, token);
        Flushbar(
          title: 'Success',
          message: 'Data submitted successfully!',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ).show(context).then((_) {
          _navigateBack(context);
        });


        textEditingController.clear();
        hmAwalController.clear();
        hmAkhirController.clear();
        timeController.clear();

      } catch (error) {
        Flushbar(
          title: 'Error',
          message: 'Failed to submit data: $error',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ).show(context);
      }
    } else {
      Flushbar(
        title: 'Error',
        message: 'Token not found',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
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
    return DropdownButtonFormField<int>(
      value: selectedVehicleId,
      onChanged: vehicles.isNotEmpty
          ? (int? newValue) {
        setState(() {
          selectedVehicleId = newValue;
        });
      }
          : null,
      items: vehicles.isNotEmpty
          ? vehicles.map((vehicle) {
        return DropdownMenuItem<int>(
          value: vehicle['id'] as int,
          child: Text(
            '${vehicle['type']} - ${vehicle['modelu']} (${vehicle['nou']})',
          ),
        );
      }).toList()
          : [],
      hint: const Text("Pilih Unit"),
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
        title: const Text('Bulldozer'),
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
              hmAwalController,
              'HM Awal',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              hmAkhirController,
              'HM Akhir',
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
