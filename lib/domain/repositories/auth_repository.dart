import '../../data/datasources/roble_datasource.dart';

abstract class AuthRepository {
  Future<void> registerStudent({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthResult> login({required String email, required String password});

  Future<UserData?> getUserByEmail(String email);

  Future<void> logout();

  Future<bool> verifyToken();

  Future<AuthResult?> refreshToken(String refreshToken);

  String? extractUidFromToken(String token);

  void setToken(String? token);
}
