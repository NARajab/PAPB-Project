import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_services.dart';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final String currentPhoneNumber;
  final String currentProfileImageUrl;
  final File? currentProfileImageFile;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    required this.currentEmail,
    required this.currentPhoneNumber,
    required this.currentProfileImageUrl,
    required this.currentProfileImageFile,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String? newProfileImageUrl;
  File? newProfileImage;
  bool isLoading = false; // Add a boolean to track the loading state

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.currentUsername;
    emailController.text = widget.currentEmail;
    phoneNumberController.text = widget.currentPhoneNumber;
    newProfileImageUrl = widget.currentProfileImageUrl;
    newProfileImage = widget.currentProfileImageFile;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newProfileImage = File(pickedFile.path);
      });
    }
  }


  Future<void> saveChanges() async {
    String? imageUrl;
    setState(() {
      isLoading = true;
    });

    ProfileServices profileServices = ProfileServices();
    try {
      String? uploadedImageUrl;

      if (newProfileImage != null) {
        uploadedImageUrl = await profileServices.uploadProfileImage(newProfileImage!);
        print(uploadedImageUrl);
        if (uploadedImageUrl == null) {
          throw Exception("Failed to upload profile image.");
        }
      }

      await profileServices.updateProfile(
        usernameController.text,
        phoneNumberController.text,
        imageUrl: uploadedImageUrl,
      );

      _showFlushbar('Success', 'Profile updated successfully.', isSuccess: true);

      // Kirim data baru ke layar sebelumnya
      await Future.delayed(const Duration(milliseconds: 2000));
      Map<String, dynamic> editedData = {
        'username': usernameController.text,
        'phoneNumber': phoneNumberController.text,
        'profileImageUrl': uploadedImageUrl ?? newProfileImageUrl,
        'profileImageFile': newProfileImage,
      };
      Navigator.pop(context, editedData);
    } catch (e) {
      _showFlushbar('Error', 'Failed to update profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void _showFlushbar(String title, String message, {bool isSuccess = false}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
        backgroundColor: const Color(0xFF304FFE),
        title: const Text('Edit Profile'),
        elevation: 5,
        shadowColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        toolbarHeight: 60,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: newProfileImage != null
                            ? FileImage(newProfileImage!)
                            : NetworkImage(newProfileImageUrl!) as ImageProvider,
                        backgroundColor: Colors.grey[200],
                        child: newProfileImage == null && newProfileImageUrl!.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Color(0xFF304FFE)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(controller: usernameController, label: 'Username'),
                const SizedBox(height: 10),
                _buildTextField(controller: emailController, label: 'Email', enabled: false),
                const SizedBox(height: 10),
                _buildTextField(controller: phoneNumberController, label: 'Phone Number'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF304FFE),
                    textStyle: const TextStyle(
                      fontSize: 18,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF304FFE),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true, // Default: enabled
  }) {
    return TextField(
      controller: controller,
      enabled: enabled, // Disable/Enable field based on this value
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey, // Adjust text color
      ),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF304FFE)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}