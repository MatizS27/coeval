import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RobleException implements Exception {
  final String message;
  final int? statusCode;

  RobleException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UserData {
  final String email;
  final String name;
  final String role;
  final String? id;
  final String? avatarUrl;

  UserData({
    required this.email,
    required this.name,
    required this.role,
    this.id,
    this.avatarUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    String rawRole = json['role'] ?? 'student';
    String normalizedRole = _normalizeRole(rawRole);
    
    return UserData(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: normalizedRole,
      id: json['_id'] ?? json['id'],
      avatarUrl: json['avatarUrl'],
    );
  }

  static String _normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
      case 'estudiante':
        return 'estudiante';
      case 'teacher':
      case 'profesor':
      case 'professor':
        return 'profesor';
      default:
        return 'estudiante';
    }
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'role': role,
    if (id != null) '_id': id,
  };

  bool get isStudent => role == 'estudiante';
  bool get isTeacher => role == 'profesor';
}

class AuthResult {
  final String accessToken;
  final String? refreshToken;
  final UserData? user;

  AuthResult({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    UserData? userData;
    if (json['user'] != null) {
      userData = UserData.fromJson(json['user']);
    }
    
    return AuthResult(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      user: userData,
    );
  }
}

class RobleDatasource {
  final String dbName = "coeval_b65ae2515f";
  final String authUrl = "https://roble-api.openlab.uninorte.edu.co/auth";
  final String databaseUrl = "https://roble-api.openlab.uninorte.edu.co/database";
  
  final String usersTable = "Registro_db";

  String? _currentToken;

  String? get currentToken => _currentToken;

  void setToken(String? token) {
    _currentToken = token;
  }

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_currentToken != null) 'Authorization': 'Bearer $_currentToken',
  };

  void _log(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  Future<bool> registerUser(String email, String password, String name) async {
    final url = Uri.parse('$authUrl/$dbName/signup-direct');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name,
        }),
      );

      _log('REGISTER', 'Status: ${response.statusCode}');
      _log('REGISTER', 'Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      if (response.statusCode == 409 || response.body.contains('already exists')) {
        throw RobleException(
          'Este correo ya está registrado',
          statusCode: response.statusCode,
        );
      }

      final errorBody = _parseErrorBody(response.body);
      throw RobleException(
        errorBody ?? 'Error al registrar usuario',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is RobleException) rethrow;
      throw RobleException('Error de conexión: $e');
    }
  }

  Future<bool> saveUserData(String email, String name, String role) async {
    final url = Uri.parse('$databaseUrl/$dbName/$usersTable');

    try {
      final body = jsonEncode({
        "email": email,
        "name": name,
        "role": role,
      });

      _log('SAVE_USER', 'URL: $url');
      _log('SAVE_USER', 'Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      _log('SAVE_USER', 'Status: ${response.statusCode}');
      _log('SAVE_USER', 'Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      _log('SAVE_USER', 'Failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      _log('SAVE_USER', 'Error: $e');
      return false;
    }
  }

  Future<AuthResult> loginUser(String email, String password) async {
    final url = Uri.parse('$authUrl/$dbName/login');

    try {
      final body = jsonEncode({
        "email": email,
        "password": password,
      });
      
      _log('LOGIN', 'URL: $url');
      _log('LOGIN', 'Request: $body');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      _log('LOGIN', 'Status: ${response.statusCode}');
      _log('LOGIN', 'Body: ${response.body}');

      // API returns 200 or 201 on success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final result = AuthResult.fromJson(data);
        _currentToken = result.accessToken;
        return result;
      }

      final errorBody = _parseErrorBody(response.body);
      throw RobleException(
        errorBody ?? 'Credenciales incorrectas',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is RobleException) rethrow;
      _log('LOGIN', 'Exception: $e');
      throw RobleException('Error de conexión: $e');
    }
  }

  Future<UserData?> getUserData(String email) async {
    final encodedEmail = Uri.encodeQueryComponent(email);
    final url = Uri.parse('$databaseUrl/$dbName/$usersTable?email=$encodedEmail');

    try {
      _log('GET_USER', 'URL: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      _log('GET_USER', 'Status: ${response.statusCode}');
      _log('GET_USER', 'Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List && data.isNotEmpty) {
          return UserData.fromJson(data[0]);
        } else if (data is Map<String, dynamic> && data.isNotEmpty) {
          if (data.containsKey('data') && data['data'] is List) {
            final list = data['data'] as List;
            if (list.isNotEmpty) {
              return UserData.fromJson(list[0]);
            }
          }
          if (data.containsKey('email')) {
            return UserData.fromJson(data);
          }
        }
        
        return null;
      }

      return null;
    } catch (e) {
      _log('GET_USER', 'Error: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    if (_currentToken == null) return true;

    final url = Uri.parse('$authUrl/$dbName/logout');

    try {
      final response = await http.post(
        url,
        headers: _authHeaders,
      );

      _currentToken = null;
      return response.statusCode == 200;
    } catch (e) {
      _currentToken = null;
      return false;
    }
  }

  Future<bool> verifyToken() async {
    if (_currentToken == null) return false;

    final url = Uri.parse('$authUrl/$dbName/verify-token');

    try {
      final response = await http.get(
        url,
        headers: _authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<AuthResult?> refreshToken(String refreshToken) async {
    final url = Uri.parse('$authUrl/$dbName/refresh-token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = AuthResult.fromJson(data);
        _currentToken = result.accessToken;
        return result;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String? _parseErrorBody(String body) {
    try {
      final data = jsonDecode(body);
      return data['message'] ?? data['error'] ?? data['msg'];
    } catch (e) {
      return null;
    }
  }
}
