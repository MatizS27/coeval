import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coeval/presentation/home/controllers/home_controller.dart';
import 'package:coeval/presentation/home/views/teacher_home_view.dart';
import 'package:coeval/presentation/home/views/student_home_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Obx(() {
          // Show loading state
          if (controller.isLoading.value) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show error state
          if (controller.error.isNotEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${controller.error.value}'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: controller.loadCurrentUser,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show appropriate dashboard based on user role
          if (controller.isTeacher) {
            return const TeacherHomeView();
          } else if (controller.isStudent) {
            return const StudentHomeView();
          }

          // Fallback
          return const Scaffold(
            body: Center(
              child: Text('No se pudo determinar el rol del usuario'),
            ),
          );
        });
      },
    );
  }
}
