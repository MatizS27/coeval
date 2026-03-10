import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleDatasource {
  // Este es el identificador que vi en tu captura de pantalla
  final String dbName = "coeval_b65ae2515f";
  final String baseUrl = "https://roble-api.openlab.uninorte.edu.co/auth";

  // Registro real en Roble
  Future<bool> registerUser(String email, String password, String name) async {
    final url = Uri.parse('$baseUrl/$dbName/signup');

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Registro exitoso en Roble para: $email");
        return true;
      } else {
        // Esto te dirá en la consola si el correo ya existe o si la clave es corta
        print("Error de Roble (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Login real en Roble
  Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/$dbName/login');

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
        return data['accessToken']; // Retornamos el token si el login es correcto
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}