import 'dart:io';
import 'package:flutter/material.dart';
import '../services/profile_services.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = 'Loading...';
  String email = 'Loading...';
  String phoneNumber = 'Loading...';
  String profileImageUrl = 'Loading...';
  File? profileImageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      ProfileServices profileServices = ProfileServices();
      Map<String, dynamic> userData = await profileServices.getUserById();
      print(userData);

      setState(() {
        username = userData['username'] ?? 'No Name';
        email = userData['email'] ?? 'No Email';
        phoneNumber = userData['phone'] ?? 'No Phone Number';
        profileImageUrl = userData['imageUrl'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF304FFE),
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
            Navigator.pushNamed(context, '/settings');
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
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    currentUsername: username,
                    currentEmail: email,
                    currentPhoneNumber: phoneNumber,
                    currentProfileImageUrl: profileImageUrl,
                    currentProfileImageFile: profileImageFile,
                  ),
                ),
              ).then((editedData) {
                print(editedData);
                if (editedData != null) {
                  setState(() {
                    username = editedData['username'];
                    email = editedData['email'];
                    phoneNumber = editedData['phoneNumber'];
                    profileImageUrl = editedData['profileImageUrl'];
                    profileImageFile = editedData['profileImageFile'];
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF304FFE)),
              if (!_isLoading) ...[
                CircleAvatar(
                  radius: 100,
                  backgroundImage: profileImageFile != null
                      ? FileImage(profileImageFile!)
                      : NetworkImage(profileImageUrl) as ImageProvider,
                  backgroundColor: Colors.grey[200],
                  child: profileImageFile == null && profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF304FFE),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
