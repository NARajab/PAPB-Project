import 'package:flutter/material.dart';
import '../../services/p2h_services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TimesheetTemplate extends StatefulWidget {
  final int idLocation;

  TimesheetTemplate({super.key, required this.idLocation});

  @override
  _TimesheetTemplateState createState() => _TimesheetTemplateState();
}

class _TimesheetTemplateState extends State<TimesheetTemplate> {
  late Future<Map<String, dynamic>> _timesheetData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('idLocation: ${widget.idLocation}');
    _timesheetData = fetchTimesheetData();
  }

  Future<Map<String, dynamic>> fetchTimesheetData() async {
    try {
      P2hHistoryServices service = P2hHistoryServices();
      final response = await service.getTimesheet(widget.idLocation);

      if (response['status'] == 'success') {
        setState(() {
          isLoading = false;
        });
        return response['lokasi'];
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet Details'),
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
            Navigator.pop(context);
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _timesheetData,
        builder: (context, snapshot) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                errorMessage ?? 'An unknown error occurred',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!['Timesheets'] == null) {
            return const Center(child: Text('No data available'));
          } else {
            final lokasi = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('PIT', lokasi['pit'] ?? 'Unknown'),
                        _buildDetailRow('DISPOSAL', lokasi['disposal'] ?? 'Unknown'),
                        _buildDetailRow('LOKASI', lokasi['location'] ?? 'Unknown'),
                        _buildDetailRow('Date', lokasi['date'] ?? 'Unknown'),
                        const SizedBox(height: 8),
                        const Text(
                          'Pengisial Fuel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('HM', lokasi['fuelhm'] ?? 'Unknown'),
                        _buildDetailRow('FUEL', lokasi['fuel'] ?? 'Unknown'),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 482, // Adjust height as needed
                          child: SfDataGrid(
                            source: _TimesheetDataSource(_buildTableData(lokasi)),
                            columnWidthMode: ColumnWidthMode.fill,
                            columns: [
                              GridColumn(
                                columnName: 'Time',
                                width: 80,
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Time',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Material',
                                width: 90,
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Material',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              GridColumn(
                                width: 180,
                                columnName: 'Remark',
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Remark',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              GridColumn(
                                width: 80,
                                columnName: 'Code',
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Code',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              GridColumn(
                                width: 80,
                                columnName: 'Code',
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Code',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              GridColumn(
                                width: 80,
                                columnName: 'Code',
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Code',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              GridColumn(
                                width: 80,
                                columnName: 'Code',
                                label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Code',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  List<DataGridRow> _buildTableData(Map<String, dynamic> lokasi) {
    final timesheets = lokasi['Timesheets'] as List<dynamic>;

    if (timesheets.isEmpty) {
      return [
        const DataGridRow(cells: [
          DataGridCell<String>(columnName: 'Time', value: '-'),
          DataGridCell<String>(columnName: 'Material', value: '-'),
          DataGridCell<String>(columnName: 'Remark', value: '-'),
          DataGridCell<String>(columnName: 'Code', value: '-'),
          DataGridCell<String>(columnName: 'Code', value: '-'),
          DataGridCell<String>(columnName: 'Code', value: '-'),
          DataGridCell<String>(columnName: 'Code', value: '-'),
        ])
      ];
    }

    return timesheets.map((timesheet) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Time', value: timesheet['timeTs'] ?? ''),
        DataGridCell<String>(columnName: 'Material', value: timesheet['material'] ?? ''),
        DataGridCell<String>(columnName: 'Remark', value: timesheet['remark'] ?? ''),
        DataGridCell<String>(columnName: 'Code', value: timesheet['activityCode'] ?? ''),
        DataGridCell<String>(columnName: 'Code', value: timesheet['delayCode'] ?? ''),
        DataGridCell<String>(columnName: 'Code', value: timesheet['idleCode'] ?? ''),
        DataGridCell<String>(columnName: 'Code', value: timesheet['repairCode'] ?? ''),
      ]);
    }).toList();
  }
}

class _TimesheetDataSource extends DataGridSource {
  _TimesheetDataSource(this.data);

  final List<DataGridRow> data;

  @override
  List<DataGridRow> get rows => data;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: dataCell.columnName == 'Remark'
              ? Alignment.centerLeft // Align to the left for the Remark column
              : Alignment.center,    // Default alignment for other columns
          child: Text(
            dataCell.value.toString(),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.left, // Ensures text is left-aligned within the cell
          ),
        );
      }).toList(),
    );
  }
}

