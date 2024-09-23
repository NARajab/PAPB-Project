import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ProfileServices{
  final String baseUrl = dotenv.env['API_URL']!;

  Future <Map<String, dynamic>> getUserById(String token) async {
    const String endpoint = '/user/byId';
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
    }catch (e){
      throw Exception('Error: $e');
    }
  }

  Future<void> updateProfile(String token, String username, String email, String phoneNumber, File? profileImage) async {
    const String endpoint = '/user/update';
    final String apiUrl = '$baseUrl$endpoint';

    try{
      final request = http.MultipartRequest('PATCH', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      if (profileImage != null) {
        final imageStream = http.ByteStream(profileImage.openRead());
        final length = await profileImage.length();
        final mimeType = lookupMimeType(profileImage.path) ?? 'image/jpeg';
        final multipartFile = http.MultipartFile(
          'imageUrl',
          imageStream,
          length,
          filename: profileImage.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['phoneNumber'] = phoneNumber;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print('Success: $jsonResponse');
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
      }
    } catch(e){
      throw Exception('Error: $e');
    }
  }

  Future<void> changePassword(String password, String newPassword, String confirmPassword, String token) async {
    const String endpoint = '/auth/change-password';
    final String apiUrl = '$baseUrl$endpoint';

    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'password': password,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Data submitted successfully');
    } else {
      print('Failed to submit data');
    }
  }
}