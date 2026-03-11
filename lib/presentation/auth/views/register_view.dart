import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {

  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Registro Uninorte"),
      ),

      body: SingleChildScrollView(   // ← evita overflow
        padding: const EdgeInsets.all(25),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Selecciona tu rol",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: Obx(() => ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      controller.selectedRole.value == 'estudiante'
                          ? Colors.red.shade900
                          : Colors.grey,
                    ),

                    onPressed: () {
                      controller.selectedRole.value = 'estudiante';
                    },

                    child: const Text("Estudiante"),
                  )),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Obx(() => ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      controller.selectedRole.value == 'profesor'
                          ? Colors.red.shade900
                          : Colors.grey,
                    ),

                    onPressed: () {
                      controller.selectedRole.value = 'profesor';
                    },

                    child: const Text("Profesor"),
                  )),
                ),

              ],
            ),

            const SizedBox(height: 20),

            TextField(
              onChanged: (v) => controller.name.value = v,
              decoration: const InputDecoration(
                labelText: "Nombre completo",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              onChanged: (v) => controller.email.value = v,
              decoration: const InputDecoration(
                labelText: "Correo @uninorte.edu.co",
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

            Center(
              child: Obx(() =>
              controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => controller.register(),
                child: const Text("Registrarme"),
              )
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text("¿Ya tienes cuenta? Inicia sesión"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}