import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class P2hHistoryServices{
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> getAllP2h(String token) async {
    const String endpoint = '/p2h/allId';
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

  Future <Map<String, dynamic>> getP2hById(int p2hId, String token) async {
    const String endpoint = '/p2h/user/';
    final String apiUrl = '$baseUrl$endpoint$p2hId';

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
    }catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future <Map<String, dynamic>> getP2hByIdWithLocation(int p2hId, String token) async {
    const String endpoint = '/p2h/';
    final String apiUrl = '$baseUrl$endpoint$p2hId';

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
    }catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getTimesheet(int idLocation) async {
    const String endpoint = '/p2h/location/';
    final String apiUrl = '$baseUrl$endpoint$idLocation';

    try{
      final response = await http.get(
          Uri.parse(apiUrl)
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getAllP2hUser() async {
    const String endpoint = '/p2h/all';
    final String apiUrl = '$baseUrl$endpoint';

    try{
      final response = await http.get(
          Uri.parse(apiUrl)
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }catch (e){
      throw Exception('Error $e');
    }
  }
}