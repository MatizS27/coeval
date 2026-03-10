import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    bool isTeacher = authController.selectedRole.value == 'profesor';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: const Text("CoEval Uninorte", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isTeacher ? Icons.assignment_ind : Icons.school, size: 80, color: Colors.red.shade900),
            const SizedBox(height: 20),
            Text("Bienvenido, ${authController.name.value}"),
            Text("Panel de ${isTeacher ? 'Docente' : 'Estudiante'}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 40),
            // Ejemplo de funcionalidad según el rol
            isTeacher
                ? ElevatedButton(onPressed: (){}, child: const Text("Crear Nueva Evaluación"))
                : ElevatedButton(onPressed: (){}, child: const Text("Ver mis Co-evaluaciones")),
          ],
        ),
      ),
    );
  }
}