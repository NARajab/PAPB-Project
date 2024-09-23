import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class P2hServices {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<int> getAllP2hLength() async {
    const String endpoint = '/p2h/length';
    final String apiUrl = '$baseUrl$endpoint';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['length'];
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getLastP2hByUser(String token) async {
    const String endpoint = '/p2h/last';
    final String apiUrl = '$baseUrl$endpoint';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
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

class FormServices{
  final String baseUrl = dotenv.env['API_URL']!;

  Future<void> submitP2hDt(Map<String, dynamic> requestData, String token) async {
    const String endpoint = '/p2h/dt';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 201) {
      print('Data submitted successfully');
    } else {
      print('Failed to submit data');
    }
  }

  Future<void> submitP2hBl(Map<String, dynamic> requestData, String token) async {
    const String endpoint = '/p2h/bul';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 201) {
      print('Data submitted successfully');
    } else {
      print('Failed to submit data');
    }
  }

  Future<void> submitP2hLv(Map<String, dynamic> requestData, String token) async {
    const String endpoint = '/p2h/lv';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(requestData)
    );

    if (response.statusCode == 201) {
      print('Data submitted successfully');
    } else {
      print('Failed to submit data');
    }
  }

  Future<void> submitP2hBs(Map<String, dynamic> requestData, String token) async {
    const String endpoint = '/p2h/bus';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(requestData)
    );

    if (response.statusCode == 201) {
      print('Data submitted successfully');
    } else {
      print('Failed to submit data');
    }
  }

  Future<Map<String, dynamic>> submitP2hEx(Map<String, dynamic> requestData, String token) async {
    const String endpoint = '/p2h/ex';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(requestData)
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> getVehicleByType(String title) async {
    const String endpoint = '/vehicle/type?type=';
    final String apiUrl = '$baseUrl$endpoint$title';

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
}

class TimesheetServices {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> submitLocation(Map<String, dynamic> requestData, String token) async {
    const String endpoint = '/p2h/location';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(requestData)
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> submitTimesheet(int locationId, Map<String, dynamic> requestData) async {
    const String endpoint = '/timesheet/';
    final String apiUrl = '$baseUrl$endpoint$locationId';

    final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData)
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> submitPostscript(int locationId, Map<String, dynamic> requestData) async {
    const String endpoint = '/p2h/location/';
    final String apiUrl = '$baseUrl$endpoint$locationId';

    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 201) {
      print('Data submitted successfully');
      return jsonDecode(response.body);
    } else {
      print('Failed to submit data');
      return {
        'error': 'Failed to submit data',
        'statusCode': response.statusCode,
      };
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
}
