import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import '../services/settings_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String username = 'Loading...';
  String email = 'Loading...';
  String profileImageUrl = 'Loading...';
  File? profileImageFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        ProfileServices profileServices = ProfileServices();
        Map<String, dynamic> userData = await profileServices.getUserById(token);

        setState(() {
          username = userData['user']['Auth']['username'] ?? 'No Name';
          email = userData['user']['Auth']['email'] ?? 'No Email';
          profileImageUrl = userData['user']['imageUrl'] ?? 'No Image';
          isLoading = false;
        });
      } catch (e) {
        print('Error loading profile: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading // Check if loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF304FFE)))
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildOptionCard(context, 'Profile', 'assets/images/profile.png', () => _onProfileTap(context)),
          _buildOptionCard(context, 'Change Password', 'assets/images/cp.png', () => _onChangePasswordTap(context)),
          _buildOptionCard(context, 'Logout', 'assets/images/logout.png', () => _onLogoutTap(context)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profileImageFile != null
                ? FileImage(profileImageFile!)
                : NetworkImage(profileImageUrl) as ImageProvider,
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Image.asset(imagePath, width: 30, height: 30),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  void _onProfileTap(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _onChangePasswordTap(BuildContext context) {
    Navigator.pushNamed(context, '/change-password');
  }

  void _onLogoutTap(BuildContext context) {
    Flushbar flushbar = Flushbar(
      title: "Logout",
      message: "Are you sure you want to logout?",
      duration: null,
      mainButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(context);
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "No",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      isDismissible: true,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.black54,
      icon: const Icon(
        Icons.logout,
        size: 28.0,
        color: Colors.red,
      ),
      leftBarIndicatorColor: Colors.red,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: flushbar,
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (Route<dynamic> route) => false,
    );
  }
}
