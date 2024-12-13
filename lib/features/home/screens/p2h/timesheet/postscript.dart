import 'package:flutter/material.dart';
import '../../../services/p2h_services/timesheet/timesheet_service.dart';
import 'package:another_flushbar/flushbar.dart';

class PostscriptScreen extends StatelessWidget {
  final String locationId;
  final TextEditingController postscriptController = TextEditingController();
  final TextEditingController stopOperasiJamController = TextEditingController();

  PostscriptScreen({super.key, required this.locationId});


  void _submitData(BuildContext context) async {
    final requestData = {
      'postscript': postscriptController.text,
      'stopOperation': stopOperasiJamController.text,
    };

    try {
      // Submit data using the service function
      await TimesheetService().submitPostscript(locationId, requestData);

      // Show success notification
      Flushbar(
        title: 'Success',
        message: 'Data submitted successfully!',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ).show(context).then((_) {
        _navigateBack(context);
      });
    } catch (e) {
      // Show error notification
      Flushbar(
        title: 'Error',
        message: 'Failed to submit data: $e',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postscript Screen'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Catatan Lain (Diisi Keterangan Tambahan Terkait Dengan Aktifitas Unik)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: postscriptController,
              decoration: const InputDecoration(
                labelText: 'Tambahkan keterangan tambahan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stop Operasi Jam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _selectTime(context, stopOperasiJamController);
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: stopOperasiJamController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Stop Operasi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitData(context);
              },
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
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
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
