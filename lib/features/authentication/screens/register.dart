import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'package:another_flushbar/flushbar.dart';
import 'login_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _passwordVisible = false;
  String _selectedRole = 'Driver';

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10.0),
                  const Text(
                    "Lets Join With Us",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Center( // Center the image
                    child: Image.asset(
                      'assets/images/register.png',
                      height: 250.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Card(
                    color: const Color.fromARGB(0, 255, 255, 255),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Username',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your username',
                              filled: true,
                              fillColor: Color(0xFFF3F4F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          const Text(
                            'NIK',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          TextField(
                            controller: _nikController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your NIK',
                              filled: true,
                              fillColor: Color(0xFFF3F4F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2.0), // Slightly increased space for clarity
                          const Text(
                            '*Nomer Induk Karyawan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.0, // Smaller font size for the note
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                              filled: true,
                              fillColor: Color(0xFFF3F4F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15.0),
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              filled: true,
                              fillColor: const Color(0xFFF3F4F8),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_passwordVisible,
                          ),
                          const SizedBox(height: 15.0),
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your phone number',
                              filled: true,
                              fillColor: Color(0xFFF3F4F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15.0),
                          const Text(
                            'Role',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<String>(
                                    value: 'Driver',
                                    groupValue: _selectedRole,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                  ),
                                  title: const Text('Driver'),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<String>(
                                    value: 'Forman',
                                    groupValue: _selectedRole,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                  ),
                                  title: const Text('Foreman'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 50),
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                                  backgroundColor: const Color(0xFF304FFE),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                ),
                                child: const Text('Sign Up'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String nik = _nikController.text;
    final String password = _passwordController.text;
    final String phoneNumber = _phoneController.text;
    final String role = _selectedRole;

    try {
      final response = await _authService.register(username, email, nik, password, phoneNumber, role);

      if (response['status'] == 'success') {
        Flushbar(
            message: response['message'] ?? 'Register successful',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP
        ).show(context);
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Flushbar(
            message: response['message'] ?? 'Register failed',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP
        ).show(context);
        throw Exception('Failed to register');
      }
    } catch (e) {
      print('Exception: $e');
      Flushbar(
        message: 'Register failed',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }
}
