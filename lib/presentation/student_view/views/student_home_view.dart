import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/student_home_controller.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentHomeController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Mis Cursos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: authController.logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.courses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.courses.isEmpty) {
          return Center(
            child: Text(
              'No estás inscrito en cursos todavía',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCourses,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: controller.courses.length,
            itemBuilder: (context, index) {
              final course = controller.courses[index];
              return _StudentCourseCard(course: course);
            },
          ),
        );
      }),
    );
  }
}

class _StudentCourseCard extends StatelessWidget {
  final TeacherCourseOverview course;

  const _StudentCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NRC ${course.nrc} · ${course.term}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
            const SizedBox(height: 12),
            ...course.categories.map((category) {
              final myGroups = category.groups
                  .where(
                    (group) => group.students.any(
                      (student) =>
                          student.email.trim().toLowerCase() ==
                          (Get.find<AuthController>().currentUser.value?.email
                                  .trim()
                                  .toLowerCase() ??
                              ''),
                    ),
                  )
                  .toList();

              if (myGroups.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...myGroups.map((group) {
                        final classmates = group.students;
                        final currentEmail = Get.find<AuthController>()
                            .currentUser
                            .value
                            ?.email
                            ?.trim()
                            .toLowerCase();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grupo: ${group.name} (${group.code})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...classmates.map((mate) {
                                final mateEmail = mate.email
                                    .trim()
                                    .toLowerCase();
                                final studentName = mate.name.isEmpty
                                    ? mate.email
                                    : mate.name;
                                final isLogged =
                                    currentEmail != null &&
                                    mateEmail == currentEmail;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '- ${studentName}${isLogged ? ' (Tú)' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isLogged
                                          ? const Color(0xFFF76900)
                                          : const Color(0xFF666666),
                                      fontWeight: isLogged
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
