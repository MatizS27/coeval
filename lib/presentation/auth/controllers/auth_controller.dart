import 'package:get/get.dart';
import '../../../data/datasources/roble_datasource.dart';

class AuthController extends GetxController {

  final RobleDatasource _robleService = RobleDatasource();

  var email = ''.obs;
  var password = ''.obs;
  var name = ''.obs;
  var isLoading = false.obs;

  var selectedRole = 'estudiante'.obs;

  // REGISTRO
  void register() async {

    if (email.value.isEmpty || name.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Completa todos los campos");
      return;
    }

    isLoading.value = true;

    bool success = await _robleService.registerUser(
      email.value,
      password.value,
      name.value,
    );

    if (success) {

      await _robleService.saveUserData(
        email.value,
        name.value,
        selectedRole.value,
      );

      Get.snackbar(
        "Registro exitoso",
        "Tu cuenta fue creada correctamente",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/login');

    } else {

      Get.snackbar(
        "Error",
        "No se pudo registrar el usuario",
      );

    }

    isLoading.value = false;
  }

  // LOGIN
  void login() async {

    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Ingresa correo y contraseña");
      return;
    }

    isLoading.value = true;

    String? token = await _robleService.loginUser(
      email.value,
      password.value,
    );

    isLoading.value = false;

    if (token != null) {

      Get.offAllNamed('/home');

    } else {

      Get.snackbar(
        "Error",
        "Credenciales incorrectas",
      );

    }
  }
}