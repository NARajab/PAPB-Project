import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/kkh_services/kkh_service.dart';
import 'package:another_flushbar/flushbar.dart';

class KkhScreen extends StatefulWidget {
  const KkhScreen({super.key});

  @override
  _KkhScreenState createState() => _KkhScreenState();
}

class _KkhScreenState extends State<KkhScreen> {
  final TextEditingController jamController = TextEditingController();
  final TextEditingController menitController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final KkhServices _kkhServices = KkhServices();

  void clearFields() {
    jamController.clear();
    menitController.clear();
    setState(() {
      _image = null;
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  String? getCurrentUserUid() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }


  Future<void> submitData(String? uid) async {
    _showLoadingDialog();
    String? imageUrl;

    try {
      if (uid == null) {
        _showSnackBar('User is not logged in.');
        return;
      }

      String totalJamTidur = '${jamController.text} Jam ${menitController.text} Menit';
      if (_image != null) {
        imageUrl = await _kkhServices.uploadKkhImage(_image!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload profile image')),
          );
          return;
        }
        print("Uploaded image URL: $imageUrl");
      }

      await _kkhServices.submitKkhData(
        totalJamTidur,
        uid,
        imageUrl: imageUrl,
      );

      clearFields();
      _closeDialog();

      _showFlushbar('Success', 'Data submitted successfully!', Colors.green);
    } catch (e) {
      _closeDialog();
      _showSnackBar('Error: $e');
    }
  }



  Future<void> onSubmit() async {
    String? uid = getCurrentUserUid();  // Ambil UID dari Firebase
    if (uid != null) {
      await submitData(uid); // Kirim UID ke fungsi submitData
    } else {
      _showSnackBar('User is not logged in.');
    }
  }



  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF304FFE)),
        );
      },
    );
  }

  void _closeDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showFlushbar(String title, String message, Color backgroundColor) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
    ).show(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form KKH'),
        backgroundColor: const Color(0xFF304FFE),
        elevation: 5,
        shadowColor: Colors.black,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
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
              'Masukkan jumlah jam tidur anda',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jamController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jam',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: menitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Menit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 10),
            _image == null
                ? const Text('Tidak ada gambar yang dipilih.')
                : SizedBox(
              width: 200,
              height: 200,
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onSubmit,
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
}
