import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:coeval/presentation/auth/controllers/auth_controller.dart';
import 'package:coeval/data/datasources/roble_datasource.dart';
import 'package:coeval/data/datasources/auth_remote_datasource.dart';
import 'package:coeval/data/repositories/auth_repository_impl.dart';
import 'package:coeval/domain/usecases/login_use_case.dart';

void main() {
  group('Nivel 3 - Prueba de Integración: Flujo Completo de Login', () {
    late AuthController authController;
    late RobleDatasource robleDatasource;

    setUp(() {
      robleDatasource = RobleDatasource();

      robleDatasource.client = MockClient((request) async {
        if (request.url.path.contains('/login')) {
          return http.Response(
            jsonEncode({
              'accessToken': 'fake_access_token',
              'refreshToken': 'fake_refresh_token',
              'user': {
                'id': 'user_123',
                'email': 'integracion@uninorte.edu.co',
                'name': 'Juan Integración',
                'rol': 'student'
              }
            }),
            200,
          );
        }
        
        if (request.url.path.contains('/read')) {
          return http.Response(
            jsonEncode([{
              'id': 'user_123',
              'uid': 'user_123',
              'email': 'integracion@uninorte.edu.co',
              'name': 'Juan Integración',
              'rol': 'student'
            }]),
            200,
          );
        }

        if (request.url.path.contains('/verify-token')) {
          return http.Response('OK', 200);
        }

        return http.Response(jsonEncode({'message': 'Not Found'}), 404);
      });

      final authRemote = AuthRemoteDatasource(robleDatasource);
      final authRepo = AuthRepositoryImpl(authRemote);

      authController = Get.put(AuthController(
        registerStudentUseCase: RegisterStudentUseCase(authRepo),
        loginUseCase: LoginUseCase(authRepo),
        getUserByEmailUseCase: GetUserByEmailUseCase(authRepo),
        logoutUseCase: LogoutUseCase(authRepo),
        verifyTokenUseCase: VerifyTokenUseCase(authRepo),
        setTokenUseCase: SetTokenUseCase(authRepo),
        forgotPasswordUseCase: ForgotPasswordUseCase(authRepo),
        resetPasswordUseCase: ResetPasswordUseCase(authRepo),
      ));
    });

    tearDown(() async {
      await Get.delete<AuthController>();
      Get.reset();
    });

    test('Debe completar el login y actualizar el estado global del usuario', () async {
      authController.email.value = 'integracion@uninorte.edu.co';
      authController.password.value = '123456';

      await authController.login();

      expect(robleDatasource.currentToken, 'fake_access_token');
      expect(authController.isLoggedIn.value, isTrue);
      expect(authController.currentUser.value, isNotNull);
      expect(authController.currentUser.value!.name, 'Juan Integración');
    });
  });
}
