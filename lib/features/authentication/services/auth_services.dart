import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AuthService {
  final String baseUrl = dotenv.env['API_URL']!;
  Future<Map<String, dynamic>> login(String username, String password) async {
    const String endpoint = '/auth/login';
    final String apiUrl = '$baseUrl$endpoint';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usernameOrEmail': username,
        'password': password,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      return data;
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String nik, String password, String phoneNumber, String role) async {
    const String endpoint = '/auth/register-member';
    final String apiUrl = '$baseUrl$endpoint';
    final response  = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'nik': nik,
          'password': password,
          'phoneNumber': phoneNumber,
          'role': role
        })
    );

    if(response.statusCode == 201){
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<Map<String, dynamic>> sendmail(String email) async {
    const String endpoint = '/auth/send-email';
    final String apiUrl = '$baseUrl$endpoint';
    final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          'email': email
        })
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      return data;
    }
  }
}

