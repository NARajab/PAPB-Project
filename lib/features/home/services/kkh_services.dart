import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KkhServices {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<int> getAllKkhLength() async {
    const String endpoint = '/kkh/length';
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

  Future<Map<String, dynamic>> getLastKkhByUser(String token) async {
    const String endpoint = '/kkh/last';
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

  Future<void> submitKkhData(String totalJamTidur, File? imageFile, String token) async {
    const String endpoint = '/kkh/';
    final String apiUrl = '$baseUrl$endpoint';
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      if (imageFile != null) {
        final imageStream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg'; // Menentukan MIME type secara manual
        final multipartFile = http.MultipartFile(
          'imageUrl',
          imageStream,
          length,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      request.fields['totaltime'] = totalJamTidur;

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print('Success: $jsonResponse');
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}