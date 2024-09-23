import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KkhHistoryServices{
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> getAllKkh(String token) async {
    const String endpoint = '/kkh/allId';
    final String apiUrl = '$baseUrl$endpoint';

    try{
      final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
          }
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getAllKkhUser() async {
    const String endpoint = '/kkh';
    final String apiUrl = '$baseUrl$endpoint';

    try{
      final response = await http.get(
        Uri.parse(apiUrl),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}