import 'package:flutter/material.dart';
import '../../../history/services/p2h_services.dart';
import '../../services/p2h_services/foreman_services/note_screen_services.dart';
import '../../services/p2h_foreman_services.dart';
import '../../../history/services/p2h_services/history_service.dart';
import 'package:another_flushbar/flushbar.dart';

class NoteScreen extends StatefulWidget {
  final String p2hId;

  NoteScreen({super.key, required this.p2hId});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final P2hHistoryServices _p2hHistoryServices = P2hHistoryServices();
  late Future<Map<String, dynamic>> _p2hData;
  final TextEditingController _aroundUnitController = TextEditingController();
  final TextEditingController _inTheCabinController = TextEditingController();
  final TextEditingController _machineRoomController = TextEditingController();
  final NoteScreenServices _noteScreenServices = NoteScreenServices();

  @override
  void initState() {
    super.initState();
    _fetchP2hData();
  }

  Future<void> _fetchP2hData() async {
    setState(() {
      _p2hData = getP2hById(widget.p2hId);
    });
  }

  @override
  void dispose() {
    _aroundUnitController.dispose();
    _inTheCabinController.dispose();
    _machineRoomController.dispose();
    super.dispose();
  }

  Future<void> submitNotes() async {
    String aroundU = _aroundUnitController.text;
    String inTheCabin = _inTheCabinController.text;
    String machineRoom = _machineRoomController.text;
    String p2hId = widget.p2hId;

    try {
      // Panggil metode submitNotes dari ForemanServices
      await _noteScreenServices.submitNotes(
        aroundU,
        inTheCabin,
        machineRoom,
        p2hId,
      );
      showFlushbar('Success', 'Notes submitted successfully.', isSuccess: true);
    } catch (e) {
      showFlushbar('Error', 'Failed to submit notes: $e');
    }
  }


  void showFlushbar(String title, String message, {bool isSuccess = false}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    if (isSuccess) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Findings Notes'),
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
        future: _p2hData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final data = snapshot.data!;
            // Print the fetched data to the console
            print('Fetched data: $data');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Catatan/Temuan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNoteCard('Keliling Unit', data['ntsAroundU'] ?? ''),
                  _buildNoteCard('Dalam Kabin', data['ntsInTheCabinU'] ?? ''),
                  _buildNoteCard('Ruang Mesin', data['ntsMachineRoom'] ?? ''),
                  const SizedBox(height: 16),
                  const Text(
                    'Comment/Jawaban',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCommentInput('Keliling Unit', _aroundUnitController),
                  _buildCommentInput('Dalam Kabin', _inTheCabinController),
                  _buildCommentInput('Ruang Mesin', _machineRoomController),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: submitNotes,
                    child: const Text('Submit Comments'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNoteCard(String title, String note) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(String title, TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tambahkan jawaban atau komentar...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
