import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  // Buscamos el controlador ya inyectado
  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue), // Logo temporal
            const SizedBox(height: 20),
            const Text("CoEval - Roble Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              onChanged: (v) => controller.email.value = v,
              decoration: const InputDecoration(labelText: "Correo Institucional", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: (v) => controller.password.value = v,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () => controller.login(),
              child: const Text("INGRESAR"),
            )),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text("¿No tienes cuenta? Regístrate aquí"),
            )
          ],
        ),
      ),
    );
  }
}