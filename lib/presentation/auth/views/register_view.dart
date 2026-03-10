import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Uninorte")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Selecciona tu rol:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Obx(() => Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.selectedRole.value == 'estudiante' ? Colors.red.shade900 : Colors.grey.shade300,
                    ),
                    onPressed: () => controller.selectedRole.value = 'estudiante',
                    child: Text("Estudiante", style: TextStyle(color: controller.selectedRole.value == 'estudiante' ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.selectedRole.value == 'profesor' ? Colors.red.shade900 : Colors.grey.shade300,
                    ),
                    onPressed: () => controller.selectedRole.value = 'profesor',
                    child: Text("Profesor", style: TextStyle(color: controller.selectedRole.value == 'profesor' ? Colors.white : Colors.black)),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 30),
            TextField(
              onChanged: (v) => controller.name.value = v,
              decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: (v) => controller.email.value = v,
              decoration: const InputDecoration(labelText: "Correo @uninorte.edu.co", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: (v) => controller.password.value = v,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                onPressed: () => controller.register(),
                child: const Text("REGISTRARME", style: TextStyle(color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}