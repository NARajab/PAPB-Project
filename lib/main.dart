import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/setting/screens/change_password.dart';
import 'features/setting/screens/profile.dart';
import 'features/history/screens/history.dart';
import 'features/home/screens/kkh.dart';
// import 'package:myapp/features/home/screens/p2h/timesheet/postscript.dart';
import 'features/home/screens/p2h/timesheet/timesheet.dart';
import 'features/home/screens/p2h/timesheet/location.dart';
import 'features/home/screens/p2h/pph.dart';
import 'features/home/screens/p2h/pph_bl.dart';
import 'features/home/screens/p2h/pph_bs.dart';
import 'features/home/screens/p2h/pph_dt.dart';
import 'features/home/screens/p2h/pph_lv.dart';
import 'features/home/screens/p2h/pph_ex.dart';
import 'features/authentication/screens/login_page.dart';
import 'features/authentication/screens/send_email_forgot_password.dart';
import 'features/home/screens/homepage.dart';
import 'features/Setting/screens/setting.dart';
import 'dart:async';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bima Nusa App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => const SendEmailForgotPasswordScreen(),
        '/home': (context) => const HomePage(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/p2h': (context) => P2hScreen(),
        '/kkh': (context) => const KkhScreen(),
        '/blForm': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return P2hBlScreen(
            id: args['id'],
            title: args['title'],
          );
        },
        '/dtForm': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return P2hDtScreen(
            id: args['id'],
            title: args['title'],
          );
        },
        '/lvForm': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return P2hLvScreen(
            id: args['id'],
            title: args['title'],
          );
        },
        '/bsForm': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return P2hBsScreen(
            id: args['id'],
            title: args['title'],
          );
        },
        '/exForm': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return P2hExScreen(
            id: args['id'],
            title: args['title'],
          );
        },
        '/location': (context) => const LocationScreen(),
        // '/timesheet': (context) => TimesheetScreen(locationId: locationId),
        // '/postscript': (context) => PostscriptScreen(),
      },
    );
  }
}