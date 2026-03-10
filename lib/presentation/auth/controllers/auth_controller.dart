import 'package:get/get.dart';
// 1. Asegúrate de que esta ruta sea exacta a donde creaste el servicio
import '../../../data/datasources/roble_datasource.dart';

class AuthController extends GetxController {
  // Instanciamos el servicio que acabamos de crear con tu dbName
  final RobleDatasource _robleService = RobleDatasource();

  // Observables para los formularios
  var email = ''.obs;
  var password = ''.obs;
  var name = ''.obs;
  var verificationCode = ''.obs; // Para el paso de verificación
  var isLoading = false.obs;
  var selectedRole = 'estudiante'.obs;

  // Lógica de Registro Real
  void register() async {
    if (email.value.isEmpty || name.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Por favor completa todos los campos");
      return;
    }

    isLoading.value = true;

    // Llamamos al método que creamos con tu dbName (coeval_b65ae2515f)
    bool success = await _robleService.registerUser(
        email.value,
        password.value,
        name.value
    );

    isLoading.value = false;

    if (success) {
      Get.snackbar(
          "¡Excelente!",
          "Código enviado a tu correo Uninorte",
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM
      );
      // Aquí podrías mandarlos a una vista de verificación o al login
      Get.toNamed('/login');
    } else {
      Get.snackbar("Error", "No se pudo registrar. Verifica si el correo ya existe.");
    }
  }

  // Lógica de Login Real
  void login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Ingresa correo y contraseña");
      return;
    }

    isLoading.value = true;
    String? token = await _robleService.loginUser(email.value, password.value);
    isLoading.value = false;

    if (token != null) {
      // Guardar token si es necesario y entrar
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("Error", "Credenciales incorrectas o cuenta no verificada");
    }
  }
}