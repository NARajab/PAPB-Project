import 'package:flutter/material.dart';
// import 'package:myapp/features/authentication/services/auth_services.dart';
import 'package:another_flushbar/flushbar.dart';

class SendEmailForgotPasswordScreen extends StatefulWidget {
  const SendEmailForgotPasswordScreen({super.key});

  @override
  _SendEmailForgotPasswordScreenState createState() => _SendEmailForgotPasswordScreenState();
}

class _SendEmailForgotPasswordScreenState extends State<SendEmailForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  // final AuthService _authService = AuthService();


  // void _sendmail() async {
  //   final String email = _emailController.text;
  //
  //   try{
  //     final response = await _authService.sendmail(email);
  //
  //     if (response['status'] == 'success') {
  //       Flushbar(
  //         message: response['message'] ?? 'Email successfully sent',
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Colors.green,
  //         flushbarPosition: FlushbarPosition.TOP,
  //         margin: const EdgeInsets.all(8),
  //         borderRadius: BorderRadius.circular(8),
  //       ).show(context);
  //     } else if (response['status'] == 'Error') {
  //       Flushbar(
  //         message: response['message'] ?? 'Error occurred',
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Colors.redAccent,
  //         flushbarPosition: FlushbarPosition.TOP,
  //         margin: const EdgeInsets.all(8),
  //         borderRadius: BorderRadius.circular(8),
  //       ).show(context);
  //     } else {
  //       Flushbar(
  //         message: response['message'] ?? 'Send email failed',
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Colors.redAccent,
  //         flushbarPosition: FlushbarPosition.TOP,
  //         margin: const EdgeInsets.all(8),
  //         borderRadius: BorderRadius.circular(8),
  //       ).show(context);
  //     }
  //
  //   }catch (e) {
  //     print('Exception: $e');
  //     Flushbar(
  //       message: '$e',
  //       duration: const Duration(seconds: 3),
  //       backgroundColor: Colors.redAccent,
  //       flushbarPosition: FlushbarPosition.TOP,
  //       margin: const EdgeInsets.all(8),
  //       borderRadius: BorderRadius.circular(8),
  //     ).show(context);
  //   }
  // }

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
                            onPressed: () {
                              // _sendmail();
                              // Add your send email functionality here
                              print('Send email to reset password for: ${_emailController.text}');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              backgroundColor: const Color(0xFF304FFE),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 5,
                            ),
                            child: const Text('Send Email'),
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
