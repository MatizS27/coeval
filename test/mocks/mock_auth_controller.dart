import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:coeval/presentation/auth/controllers/auth_controller.dart';

// Este es tu "controlador de juguete"
class MockAuthController extends GetxService with Mock implements AuthController {}