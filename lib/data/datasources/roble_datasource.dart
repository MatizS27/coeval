import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleDatasource {

  final String dbName = "coeval_b65ae2515f";

  final String authUrl = "https://roble-api.openlab.uninorte.edu.co/auth";
  final String databaseUrl = "https://roble-api.openlab.uninorte.edu.co/database";

  // REGISTRO EN AUTH
  Future<bool> registerUser(String email, String password, String name) async {

    final url = Uri.parse('$authUrl/$dbName/signup');

    try {

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      return false;

    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  // GUARDAR EN TABLA Registro_db
  Future<bool> saveUserData(String email, String name, String role) async {

    final url = Uri.parse('$databaseUrl/$dbName/Registro_db');

    try {

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "name": name,
          "role": role
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print("Error guardando usuario: ${response.body}");
      return false;

    } catch (e) {
      print("Error conexión DB: $e");
      return false;
    }
  }

  // LOGIN
  Future<String?> loginUser(String email, String password) async {

    final url = Uri.parse('$authUrl/$dbName/login');

    try {

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        return data['accessToken'];

      }

      return null;

    } catch (e) {
      return null;
    }
  }
}