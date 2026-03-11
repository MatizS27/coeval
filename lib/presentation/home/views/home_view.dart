import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeView extends StatelessWidget {

  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("CoEval"),
      ),

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(Icons.school, size: 80),

            const SizedBox(height: 20),

            Obx(() => Text(
              "Bienvenido ${controller.name.value}",
              style: const TextStyle(fontSize: 20),
            )),

          ],
        ),
      ),
    );
  }
}