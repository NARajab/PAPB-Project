import 'dart:async';

import 'package:flutter/material.dart';
import '../services/send_email.dart';
import 'package:another_flushbar/flushbar.dart';

class SendEmailForgotPasswordScreen extends StatefulWidget {
  const SendEmailForgotPasswordScreen({super.key});

  @override
  _SendEmailForgotPasswordScreenState createState() => _SendEmailForgotPasswordScreenState();
}

class _SendEmailForgotPasswordScreenState extends State<SendEmailForgotPasswordScreen> {
  int _countdown = 0;
  bool _isLoading = false;
  bool _isButtonDisabled = false;

  final TextEditingController _emailController = TextEditingController();
  final SendEmailService _sendEmailService = SendEmailService();

  void _sendEmail() async {
    if (_emailController.text.isEmpty) {
      Flushbar(
        title: "Error",
        message: "Email cannot be empty.",
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    setState(() {
      _isLoading = true;
      _isButtonDisabled = true;
      _countdown = 60; // Atur countdown menjadi 60 detik
    });

    try {
      await _sendEmailService.sendPasswordResetEmail(_emailController.text, context);

      Flushbar(
        title: "Success",
        message: "Email sent successfully. Please check your Email.",
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.green,
        titleColor: Colors.white,
        messageColor: Colors.white,
      ).show(context);
    } catch (e) {
      Flushbar(
        title: "Error",
        message: "Failed to send email: $e",
        duration: const Duration(seconds: 3),
      ).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Memulai countdown
      Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (_countdown == 0) {
          timer.cancel();
          setState(() {
            _isButtonDisabled = false;
          });
        } else {
          setState(() {
            _countdown--;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
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
                height: 6,
                color: const Color(0xFF304FFE),
              ),
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // height: MediaQuery.of(context).size.height,
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
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  "Enter your email address to reset your password.",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 55.0),
                Center(
                  child: Image.asset(
                    'assets/images/sefp.png',
                    height: 300.0,
                  ),
                ),
                const SizedBox(height: 60.0),
                Card(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                            hintText: 'guntur.email@mail.com',
                            filled: true,
                            fillColor: Color(0xFFF3F4F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _isButtonDisabled ? null : _sendEmail,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              backgroundColor: _isButtonDisabled ? Colors.grey : const Color(0xFF304FFE),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(_isButtonDisabled ? 'Retry in $_countdown s' : 'Send Email'),
                          ),

                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
