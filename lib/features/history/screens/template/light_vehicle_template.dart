import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../home/services/p2h_services/foreman_services/validation_foreman_services.dart';
import '../..//services/p2h_services.dart';
import '../../services/p2h_services/history_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:another_flushbar/flushbar.dart';

class LightVehicleTemplate extends StatefulWidget {
  final String p2hUserId;
  final String p2hId;
  final String role;

  const LightVehicleTemplate({
    super.key,
    required this.p2hUserId,
    required this.p2hId,
    required this.role
  });

  @override
  LightVehicleTemplateState createState() => LightVehicleTemplateState();
}

class LightVehicleTemplateState extends State<LightVehicleTemplate> {
  final P2hHistoryServices _p2hHistoryServices = P2hHistoryServices();
  final ValidationForemanServices _validationForemanServices = ValidationForemanServices();
  late Future<Map<String, dynamic>> _p2hData;
  late Future<String> operatorNameFuture;
  String? role;

  @override
  void initState() {
    super.initState();
    operatorNameFuture = _getOperatorData();
  }

  Future<Map<String, dynamic>> _fetchP2hData() async {

    try {
      final data = await fetchP2hUserDetailsById(widget.p2hUserId);
      print(data);
      if (data == null) {
        throw Exception('No data found for P2hUserId: ${widget.p2hUserId}');
      }
      return data;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<String> _getOperatorData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final username = userData?['username'] ?? 'Unknown';
          final userRole = userData?['role'] ?? 'Forman';

          setState(() {
            role = userRole;
          });

          return username;
        } else {
          setState(() {
            role = 'Forman';
          });
          return 'Unknown';
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          role = 'Forman';
        });
        return 'Unknown';
      }
    } else {
      setState(() {
        role = 'Forman';
      });
      return 'Unknown';
    }
  }

  Future<void> _validateForeman() async {
    try {
      await _validationForemanServices.foremanValidation(widget.p2hUserId);
      Flushbar(
        title: 'Success',
        message: 'Validation successful',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ).show(context);
      await Future.delayed(const Duration(seconds: 3));

      Navigator.pushNamed(context, '/foremanp2h');
    } catch (e) {
      print('Failed to validate: $e');
      Flushbar(
        title: 'Error',
        message: 'Failed to validate: $e',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchP2hData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available'));
        } else {
          final data = snapshot.data!;
          final p2hUser = data?['p2hUser'] as Map<String, dynamic>?;
          final pph = data['p2h'] as Map<String, dynamic>?;
          final vehicle = data?['vehicle'] as Map<String, dynamic>?;
          final user = data?['user'] as Map<String, dynamic>?;
          final aroundUnit = data?['aroundUnit'] as Map<String, dynamic>?;
          final inTheCabin = data?['inTheCabin'] as Map<String, dynamic>?;
          final machineRoom = data?['machineRoom'] as Map<String, dynamic>?;

          return FutureBuilder<String>(
            future: operatorNameFuture,
            builder: (context, operatorSnapshot) {
              if (operatorSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (operatorSnapshot.hasError) {
                return Center(child: Text('Error: ${operatorSnapshot.error}'));
              } else if (!operatorSnapshot.hasData) {
                return const Center(child: Text('No operator name available'));
              } else {
                final operatorName = operatorSnapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Light Vehicle',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow('Model Unit', vehicle?['modelu'] ?? 'Unknown'),
                                _buildDetailRow('No Unit', vehicle?['nou'] ?? 'Unknown'),
                                _buildDetailRow('Tanggal', pph?['date'] ?? 'Unknown'),
                                _buildDetailRow('Shift', pph?['shift'] ?? 'Unknown'),
                                _buildDetailRow('Nama Operator', user?['username']),
                                _buildDetailRow('Jam', pph?['time'] ?? 'Unknown'),
                                _buildDetailRow('KM Awal', pph?['earlykm'] ?? 'Unknown'),
                                _buildDetailRow('KM Akhir', pph?['endkm'] ?? 'Unknown')
                              ],
                            ),
                          ),
                          const Divider(height: 0),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 1000,
                              child: SfDataGrid(
                                source: _DataGridSource(_buildTableData(aroundUnit!, inTheCabin!, machineRoom!)),
                                columnWidthMode: ColumnWidthMode.fill,
                                columns: [
                                  GridColumn(
                                    columnName: 'No',
                                    width: 70,
                                    label: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'NO',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'PIC',
                                    width: 50,
                                    label: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        'PIC',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Item',
                                    width: 270,
                                    label: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'ITEM YANG HARUS DIPERIKSA',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Kode',
                                    width: 90,
                                    label: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'KODE BAHAYA',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Kondisi',
                                    width: 90,
                                    label: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'KONDISI',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.role == 'Forman' && !p2hUser?['fValidation']) ...[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _validateForeman();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF304FFE),
                                            textStyle: const TextStyle(fontSize: 18),
                                            foregroundColor: Colors.white,
                                            elevation: 5,
                                          ),
                                          child: const Text('Validation'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<DataGridRow> _buildTableData(Map<String, dynamic> aroundUnit, Map<String, dynamic> inTheCabin, Map<String, dynamic> machineRoom) {

    return [
      const DataGridRow(cells: [
        DataGridCell<String>(columnName: 'No', value: 'A.'),
        DataGridCell<String>(columnName: 'PIC', value: ''),
        DataGridCell<String>(
            columnName: 'Item',
            value: 'Pemeriksaan Keliling Unit / Diluar Kabin'),
        DataGridCell<String>(columnName: 'Kode', value: ''),
        DataGridCell<String>(columnName: 'Kondisi', value: ''),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '1.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kondisi ban & baut roda'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['bdbr'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '2.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kerusakan akibat insiden ***)'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['kai'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '3.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kebocoran oli transmisi'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['kot'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '4.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Tiang bendera 4M (tambang)'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['tb4m'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '5.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'BBC minimum 25% dari Cap. Tangki'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['bbcmin'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '6.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kebersihan alat'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['bbcmin'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '7.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Safety cone 2'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['sc'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '8.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Ganjal 2'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['g2'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '9.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Dongkrak'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['dong'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '10.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kunci roda'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['kr'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '11.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Back alarm / Alarm mundur'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['ba'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '12.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kelainan saat operasi'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['kso'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '13.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kebersihan aki / battery'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: aroundUnit['ka'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      const DataGridRow(cells: [
        DataGridCell<String>(columnName: 'No', value: 'B.'),
        DataGridCell<String>(columnName: 'PIC', value: ''),
        DataGridCell<String>(
            columnName: 'Item', value: 'Pemeriksaan di dalam kabin'),
        DataGridCell<String>(columnName: 'Kode', value: ''),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: ''),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '1.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Air conditioner (AC)'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['ac'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '2.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi brake / rem'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fb'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '3.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi steering / kemudi'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fs'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '4.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi seat belt / sabuk pengaman'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fsb'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '5.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi semua lampu'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fsl'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '6.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi Rotary lamp'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['frl'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '7.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi mirror / spion'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fm'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '8.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi wiper dan air wiper'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fwdaw'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '9.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi kontrol panel'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fkp'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '10.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi horn / klakson'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['fh'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '11.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fire Extinguiser / APAR'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['feapar'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '12.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fungsi radio komunikasi'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['frk'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '13.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Kebersihan ruang kabin'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['krk'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '14.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'GPS'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['gps'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '15.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'IN Car Camera'),
        const DataGridCell<String>(columnName: 'Kode', value: 'A'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: inTheCabin['icc'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      const DataGridRow(cells: [
        DataGridCell<String>(columnName: 'No', value: 'C.'),
        DataGridCell<String>(columnName: 'PIC', value: ''),
        DataGridCell<String>(
            columnName: 'Item', value: 'Pemeriksaan di ruang mesin'),
        DataGridCell<String>(columnName: 'Kode', value: ''),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: ''),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '1.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Air Radiator'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: machineRoom['ar'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '2.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Oil Engine / Oli Mesin'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: machineRoom['oe'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '3.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Oli Steering'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: machineRoom['os'] == 1 ? 'Baik' : 'Rusak'),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'No', value: '4.'),
        const DataGridCell<String>(columnName: 'PIC', value: 'Opr'),
        const DataGridCell<String>(
            columnName: 'Item', value: 'Fan belt / semua tali kipas'),
        const DataGridCell<String>(columnName: 'Kode', value: 'AA'),
        DataGridCell<String>(
            columnName: 'Kondisi',
            value: machineRoom['fba'] == 1 ? 'Baik' : 'Rusak'),
      ]),
    ];
  }
}

class _DataGridSource extends DataGridSource {
  _DataGridSource(this._dataGridRows);

  List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final kondisi = row.getCells()[4].value as String;
    final kondisiColor = (kondisi == null || kondisi.isEmpty)
        ? Colors.transparent
        : (kondisi == 'Baik' ? Colors.green : Colors.red);

    return DataGridRowAdapter(
      cells: [
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(row.getCells()[0].value.toString()),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(row.getCells()[1].value.toString()),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(row.getCells()[2].value.toString()),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(row.getCells()[3].value.toString()),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          color: kondisiColor,
          child: Text(
            row.getCells()[4].value.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
