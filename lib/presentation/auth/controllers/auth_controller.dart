import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasources/roble_datasource.dart';

class AuthController extends GetxController {
  final RobleDatasource _robleService = RobleDatasource();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  var email = ''.obs;
  var password = ''.obs;
  var name = ''.obs;
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  
  var selectedRole = 'estudiante'.obs;

  var currentUser = Rxn<UserData>();
  var isLoggedIn = false.obs;

  var emailError = Rxn<String>();
  var passwordError = Rxn<String>();
  var nameError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('access_token');
    final savedEmail = prefs.getString('user_email');
    final savedName = prefs.getString('user_name');
    final savedRole = prefs.getString('user_role');

    if (savedToken != null && savedEmail != null) {
      _robleService.setToken(savedToken);
      
      final isValid = await _robleService.verifyToken();
      if (isValid) {
        currentUser.value = UserData(
          email: savedEmail,
          name: savedName ?? savedEmail.split('@').first,
          role: savedRole ?? 'estudiante',
        );
        isLoggedIn.value = true;
        Get.offAllNamed('/home');
      } else {
        await _clearSession();
      }
    }
  }

  Future<void> _saveSession(String token, String userEmail, String? refreshToken, UserData? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user_email', userEmail);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    if (user != null) {
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_role', user.role);
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_email');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    _robleService.setToken(null);
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  void prepareForLogin() {
    emailController.clear();
    passwordController.clear();
    email.value = '';
    password.value = '';
    emailError.value = null;
    passwordError.value = null;
    obscurePassword.value = true;
  }

  void prepareForRegister() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    name.value = '';
    email.value = '';
    password.value = '';
    selectedRole.value = 'estudiante';
    nameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    obscurePassword.value = true;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool _validateEmail(String emailValue) {
    if (emailValue.isEmpty) {
      emailError.value = 'El correo es requerido';
      return false;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(emailValue)) {
      emailError.value = 'Ingresa un correo válido';
      return false;
    }

    if (!emailValue.toLowerCase().endsWith('@uninorte.edu.co')) {
      emailError.value = 'Usa tu correo institucional (@uninorte.edu.co)';
      return false;
    }

    emailError.value = null;
    return true;
  }

  bool _validatePassword(String passwordValue) {
    if (passwordValue.isEmpty) {
      passwordError.value = 'La contraseña es requerida';
      return false;
    }

    if (passwordValue.length < 6) {
      passwordError.value = 'Mínimo 6 caracteres';
      return false;
    }

    passwordError.value = null;
    return true;
  }

  bool _validateName(String nameValue) {
    if (nameValue.isEmpty) {
      nameError.value = 'El nombre es requerido';
      return false;
    }

    if (nameValue.trim().split(' ').length < 2) {
      nameError.value = 'Ingresa nombre y apellido';
      return false;
    }

    nameError.value = null;
    return true;
  }

  bool validateLoginForm() {
    final emailValid = _validateEmail(email.value);
    final passwordValid = _validatePassword(password.value);
    return emailValid && passwordValid;
  }

  bool validateRegisterForm() {
    final nameValid = _validateName(name.value);
    final emailValid = _validateEmail(email.value);
    final passwordValid = _validatePassword(password.value);
    return nameValid && emailValid && passwordValid;
  }

  Future<void> register() async {
    if (!validateRegisterForm()) {
      _showError('Corrige los errores en el formulario');
      return;
    }

    isLoading.value = true;

    final roleToSend = selectedRole.value;
    final emailToSend = email.value.trim();
    final passwordToSend = password.value;
    final nameToSend = name.value.trim();

    try {
      final success = await _robleService.registerUser(
        emailToSend,
        passwordToSend,
        nameToSend,
      );

      if (success) {
        final savedData = await _robleService.saveUserData(
          emailToSend,
          nameToSend,
          roleToSend,
        );

        if (savedData) {
          _showSuccess(
            'Registro exitoso',
            'Tu cuenta fue creada como $roleToSend',
          );
        } else {
          _showSuccess(
            'Registro exitoso',
            'Tu cuenta fue creada. Inicia sesión.',
          );
        }

        Get.offAllNamed('/login');
      }
    } on RobleException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error inesperado. Intenta de nuevo.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!validateLoginForm()) {
      _showError('Corrige los errores en el formulario');
      return;
    }

    isLoading.value = true;

    final emailToLogin = email.value.trim();
    final passwordToLogin = password.value;

    try {
      final result = await _robleService.loginUser(
        emailToLogin,
        passwordToLogin,
      );

      // Use user data from login response if available
      UserData userData;
      if (result.user != null) {
        userData = result.user!;
      } else {
        // Fallback: try to get from our database
        final dbUser = await _robleService.getUserData(emailToLogin);
        userData = dbUser ?? UserData(
          email: emailToLogin,
          name: emailToLogin.split('@').first,
          role: 'estudiante',
        );
      }

      await _saveSession(
        result.accessToken,
        emailToLogin,
        result.refreshToken,
        userData,
      );

      currentUser.value = userData;
      isLoggedIn.value = true;
      
      Get.offAllNamed('/home');
    } on RobleException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error de conexión. Verifica tu internet.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    
    try {
      await _robleService.logout();
    } finally {
      await _clearSession();
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.error_outline, color: Colors.red.shade900),
    );
  }

  void _showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.check_circle_outline, color: Colors.green.shade900),
    );
  }
}
