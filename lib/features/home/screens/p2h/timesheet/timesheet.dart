import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import './postscript.dart';
import '../../../services/p2h_services/timesheet/timesheet_service.dart';

class TimesheetScreen extends StatefulWidget {
  final String locationId;

  const TimesheetScreen({super.key, required this.locationId});

  @override
  _TimesheetScreenState createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  List<Map<String, String>> inputData = [];

  String? selectedTime;
  String? selectedKodeAktivitas;
  String? selectedKodeMaterial;
  String? selectedKodeDelay;
  String? selectedKodeIdle;
  String? selectedKodeRepair;

  final List<Map<String, String>> kodeAktivitasOptions = [
    {'code': 'A01', 'description': 'Pengeboran (Drilling)'},
    {'code': 'A02', 'description': 'Peledakan (Blasting)'},
    {'code': 'A03', 'description': 'Pemuatan (Loading)'},
    {'code': 'A04', 'description': 'Pengangkutan (Hauling)'},
    {'code': 'A05', 'description': 'Pembersihan Batu Bara (Cleaning)'},
    {'code': 'A06', 'description': 'Ripping'},
    {'code': 'A07', 'description': 'Dozing'},
    {'code': 'A08', 'description': 'Penebaran (Spreading)'},
    {'code': 'A09', 'description': 'General Pilar, Parit, Tanggul, Batubara'},
    {'code': 'A10', 'description': 'Meratakan Jalan (Grading)'},
    {'code': 'A11', 'description': 'Penyiraman (Spraying)'},
    {'code': 'A12', 'description': 'Pemadatan (Compacting)'},
    {'code': 'A13', 'description': 'Pengisian Fuel (Refueling)'},
    {'code': 'A14', 'description': 'Pengangkatan (Lifting)'},
    {'code': 'A15', 'description': 'Penarikan (Towing)'}
  ];
  final List<Map<String, String>> kodeMaterialOptions = [
    {'code': 'OB', 'description': 'Tanah Buangan'},
    {'code': 'CC', 'description': 'Batubara (Coal)'},
    {'code': 'TS', 'description': 'Humus (Top Soil)'},
    {'code': 'MD', 'description': 'Lumpur'},
    {'code': 'DC', 'description': 'Batubara Kotor'},
    {'code': 'LOG', 'description': 'Kayu'}
  ];
  final List<Map<String, String>> kodeDelayOptions = [
    {'code': 'D01', 'description': 'P2H'},
    {'code': 'D02', 'description': 'P5M'},
    {'code': 'D03', 'description': 'General Safety Talk'},
    {'code': 'D04', 'description': 'Sholat'},
    {'code': 'D05', 'description': 'Pengisian Solar (Refueling)'},
    {'code': 'D06', 'description': 'Pemerniksaan Ban'},
    {'code': 'D07', 'description': 'Pindah Lokasi'},
    {'code': 'D08', 'description': 'Menunggu Alat Lain'},
    {'code': 'D09', 'description': 'Menunggu Proses Survey'},
    {'code': 'D10', 'description': 'Menunggu Blasting'},
    {'code': 'D11', 'description': 'Mencuci Unit'},
    {'code': 'D12', 'description': 'Istirahat Makan'},
    {'code': 'D13', 'description': 'Tidak Ada Job'},
    {'code': 'D14', 'description': 'Tidak Ada Operator'},
    {'code': 'D15', 'description': 'Tukar Shift (Change Shift)'},
    {'code': 'D16', 'description': 'Debu (Pandangan Terbatas)'},
    {'code': 'D17', 'description': 'Perbaikan Fron / Jalan'},
    {'code': 'D18', 'description': 'General Pilar'},
    {'code': 'D19', 'description': 'Tidak Ada Material'},
    {'code': 'D20', 'description': 'Fatique'},
    {'code': 'D21', 'description': 'Menunggu Penerangan (LT)'}
  ];
  final List<Map<String, String>> kodeIdleOptions = [
    {'code': 'I01', 'description': 'Hujan (Rain)'},
    {'code': 'I02', 'description': 'Jalan Licin (Slippery)'},
    {'code': 'I03', 'description': 'Kabut'},
    {'code': 'I04', 'description': 'Demo'},
    {'code': 'I05', 'description': 'Customer Problem'},
    {'code': 'I06', 'description': 'Libur'}
  ];
  final List<Map<String, String>> kodeRepairOptions = [
    {'code': 'SCM', 'description': 'Schedule Service'},
    {'code': 'USM', 'description': 'Unschedule Service'},
    {'code': 'TRM', 'description': 'Perbaikan Tyre'},
    {'code': 'ICM', 'description': 'Accident'}
  ];

  void addData() async {
    setState(() async {
      final requestData = {
        'timeTs': selectedTime,
        'material': selectedKodeMaterial,
        'remark': remarkController.text,
        'activityCode': selectedKodeAktivitas,
        'delayCode': selectedKodeDelay,
        'idleCode': selectedKodeIdle,
        'repairCode': selectedKodeRepair,
        'idLocation': widget.locationId
      };

      TimesheetService _tsservice = TimesheetService();
      final List<Map<String, dynamic>> response;
      try {
        await _tsservice.addTimesheet(requestData);

        response = await _tsservice.getTimesheetsByIdLocation(widget.locationId);
        print(response);
        setState(() {
          inputData = response.map((data) {
            return {
              'Time': data['timeTs']?.toString() ?? '-',
              'Material': data['material']?.toString() ?? '-',
              'Remark': data['remark']?.toString() ?? '-',
              'Kode Aktivitas': data['activityCode']?.toString() ?? '-',
              'Kode Delay': data['delayCode']?.toString() ?? '-',
              'Kode Idle': data['idleCode']?.toString() ?? '-',
              'Kode Repair': data['repairCode']?.toString() ?? '-',
            };
          }).toList();
        });
        if (mounted) {
          _showFlushbar('Success', 'Data submitted successfully!', Colors.green);
        }
      } catch (e) {
        print('Error submitting timesheet: $e');
        if (mounted) {
          _showFlushbar('Error', 'Failed to submit data: $e', Colors.red);
        }
      }

      selectedTime = null;
      timeController.clear();
      remarkController.clear();
      selectedKodeAktivitas = null;
      selectedKodeMaterial = null;
      selectedKodeDelay = null;
      selectedKodeIdle = null;
      selectedKodeRepair = null;
    });
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

  void navigateBack(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/p2h');
  }

  Future<void> showCustomDropdown(
      BuildContext context,
      List<Map<String, String>> options,
      String? selectedValue,
      ValueChanged<String?> onChanged,
      String label,
      ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final option = options[index];
                return ListTile(
                  title: Text(
                    '${option['code']} = ${option['description']}',
                    softWrap: true,
                  ),
                  onTap: () {
                    Navigator.pop(context, option['code']);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet'),
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
            navigateBack(context);
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
            icon: const Icon(Icons.notes),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostscriptScreen(locationId: widget.locationId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time), // Add a time icon
                    ),
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.none,
                    onTap: () => _selectTime(context, timeController),
                    readOnly: true,
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCustomDropdown(
                        context,
                        kodeMaterialOptions,
                        selectedKodeMaterial,
                            (String? newValue) {
                          setState(() {
                            selectedKodeMaterial = newValue;
                          });
                        },
                        'Material',
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Material',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedKodeMaterial != null
                            ? '${kodeMaterialOptions.firstWhere((option) => option['code'] == selectedKodeMaterial)['code']!} = ${kodeMaterialOptions.firstWhere((option) => option['code'] == selectedKodeMaterial)['description']!}'
                            : '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Second row of input fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 12), // Adjust font size
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCustomDropdown(
                        context,
                        kodeDelayOptions,
                        selectedKodeDelay,
                            (String? newValue) {
                          setState(() {
                            selectedKodeDelay = newValue;
                          });
                        },
                        'Kode Delay',
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Kode Delay',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedKodeDelay != null
                            ? '${kodeDelayOptions.firstWhere((option) => option['code'] == selectedKodeDelay)['code']!} = ${kodeDelayOptions.firstWhere((option) => option['code'] == selectedKodeDelay)['description']!}'
                            : '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Third row of input fields
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCustomDropdown(
                        context,
                        kodeIdleOptions,
                        selectedKodeIdle,
                            (String? newValue) {
                          setState(() {
                            selectedKodeIdle = newValue;
                          });
                        },
                        'Kode Idle',
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Kode Idle',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedKodeIdle != null
                            ? '${kodeIdleOptions.firstWhere((option) => option['code'] == selectedKodeIdle)['code']!} = ${kodeIdleOptions.firstWhere((option) => option['code'] == selectedKodeIdle)['description']!}'
                            : '',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCustomDropdown(
                        context,
                        kodeRepairOptions,
                        selectedKodeRepair,
                            (String? newValue) {
                          setState(() {
                            selectedKodeRepair = newValue;
                          });
                        },
                        'Kode Repair',
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Kode Repair',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedKodeRepair != null
                            ? '${kodeRepairOptions.firstWhere((option) => option['code'] == selectedKodeRepair)['code']!} = ${kodeRepairOptions.firstWhere((option) => option['code'] == selectedKodeRepair)['description']!}'
                            : '',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Dropdown for Kode Aktivitas
            GestureDetector(
              onTap: () {
                showCustomDropdown(
                  context,
                  kodeAktivitasOptions,
                  selectedKodeAktivitas,
                      (String? newValue) {
                    setState(() {
                      selectedKodeAktivitas = newValue;
                    });
                  },
                  'Kode Aktivitas',
                );
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Kode Aktivitas',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedKodeAktivitas != null
                      ? '${kodeAktivitasOptions.firstWhere((option) => option['code'] == selectedKodeAktivitas)['code']!} = ${kodeAktivitasOptions.firstWhere((option) => option['code'] == selectedKodeAktivitas)['description']!}'
                      : '',
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF304FFE),
                textStyle: const TextStyle(
                  fontSize: 18,
                ),
                foregroundColor: Colors.white,
                elevation: 5,
              ),
              child: const Text('Add Data'),
            ),
            const SizedBox(height: 10),
            // Data table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Material')),
                      DataColumn(label: Text('Remark')),
                      DataColumn(label: Text('Kode Aktivitas')),
                      DataColumn(label: Text('Kode Delay')),
                      DataColumn(label: Text('Kode Idle')),
                      DataColumn(label: Text('Kode Repair')),
                    ],
                    rows: inputData
                        .map((data) => DataRow(cells: [
                      DataCell(Text(data['Time']!)),
                      DataCell(Text(data['Material']!)),
                      DataCell(Text(data['Remark']!)),
                      DataCell(Text(data['Kode Aktivitas']!)),
                      DataCell(Text(data['Kode Delay']!)),
                      DataCell(Text(data['Kode Idle']!)),
                      DataCell(Text(data['Kode Repair']!)),
                    ]))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked.format(context);
        controller.text = selectedTime!;
      });
    }
  }

}
