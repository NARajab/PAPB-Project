import 'package:flutter/material.dart';
import 'register.dart';
import 'send_email_forgot_password.dart';
import '../services/auth_services.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/screens/homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rememberedEmail = prefs.getString('rememberedEmail');
    if (rememberedEmail != null) {
      setState(() {
        _emailController.text = rememberedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    try {
      final result = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (result['status'] == 'success') {
        final token = result['token'];
        final role = result['role'];

        if (role == 'SuperAdmin') {
          Flushbar(
            message: 'SuperAdmin access is not allowed.',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
          return;
        }

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          if (_rememberMe) {
            await prefs.setString('rememberedEmail', _emailController.text);
          } else {
            await prefs.remove('rememberedEmail');
          }

          Flushbar(
            message: result['message'] ?? 'Login successful',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);

          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          Flushbar(
            message: 'Token is missing',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
      } else {
        Flushbar(
          message: result['message'] ?? 'Login failed',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      print("Exception occurred: $e");
      Flushbar(
        message: 'No Internet Connection',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30.0),
              const Text(
                "Hi, Welcome Back! 👋",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Hello again, you've been missed!",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20.0),
              const SizedBox(height: 50.0),
              Center( // Center the image
                child: Image.asset(
                  'assets/images/admin.png',
                  height: 250.0,
                ),
              ),
              const SizedBox(height: 30.0),
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
                          hintText: 'example@mail.com',
                          filled: true,
                          fillColor: Color(0xFFF3F4F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10.0),
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
                          hintText: 'Please Enter Your Password',
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
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: Colors.blue,
                                checkColor: Colors.white,
                              ),
                              const Text('Remember Me'),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SendEmailForgotPasswordScreen(),
                                  )
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                            backgroundColor: const Color(0xFF304FFE),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 5,
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don’t have an account ? ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
