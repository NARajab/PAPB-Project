import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForemanServices{
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> getAllP2hUsers() async {
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
      throw Exception('Error: $e');
    }
  }

  Future<void> submitNotes(String aroundU, String inTheCabin, String mechineRoom, int p2hId) async {
    const String endpoint = '/p2h/notes/';
    final String apiUrl = '$baseUrl$endpoint$p2hId';

    final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "ntsAroundUf": aroundU,
          "ntsInTheCabinUf": inTheCabin,
          "ntsMachineRoomf": mechineRoom
        })
    );

    if (response.statusCode == 200) {
      print('Data submitted successfully');
    } else {
      print('Failed to submit data');
    }
  }

  Future<void> foremanValidation(int p2hId) async {
    const String endpoint = '/p2h/foreman/';
    final String apiUrl = '$baseUrl$endpoint$p2hId';

    final response = await http.patch(
        Uri.parse(apiUrl)
    );
    if (response.statusCode == 200) {
      print('Validation successfully');
    } else {
      print('Failed to Validate');
    }
  }

  Future<Map<String, dynamic>> getAllKkh() async {
    const String endpoint = '/kkh';
    final String apiUrl = '$baseUrl$endpoint';

    try{
      final response  = await http.get(
          Uri.parse(apiUrl)
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch(e){
      throw Exception('Error $e');
    }
  }

  Future<void> foremanValidationKkh(int kkhId) async {
    const String endpoint = '/kkh/';
    final String apiUrl = '$baseUrl$endpoint$kkhId';

    final response = await http.patch(
        Uri.parse(apiUrl)
    );
    if (response.statusCode == 200) {
      print('Validation successfully');
    } else {
      print('Failed to Validate');
    }
  }
}