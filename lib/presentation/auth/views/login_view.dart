import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {

  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(Icons.school, size: 80),

            const SizedBox(height: 30),

            TextField(
              onChanged: (v) => controller.email.value = v,
              decoration: const InputDecoration(
                labelText: "Correo institucional",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              obscureText: true,
              onChanged: (v) => controller.password.value = v,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            Obx(() =>
            controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => controller.login(),
              child: const Text("Ingresar"),
            )
            ),

            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text("Crear cuenta"),
            )

          ],
        ),
      ),
    );
  }
}