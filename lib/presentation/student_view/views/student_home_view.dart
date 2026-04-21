import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../controllers/student_home_controller.dart';
import 'student_course_detail_view.dart';

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
            tooltip: 'Ver mis resultados',
            onPressed: () => Get.to(() => const DashboardView()),
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
          ),
          Obx(() {
            final pendingCount = controller.totalPendingCount;
            return Stack(
              children: [
                IconButton(
                  tooltip: pendingCount > 0 
                      ? '$pendingCount evaluaciones pendientes' 
                      : 'Sin evaluaciones pendientes',
                  onPressed: () async {
                    await controller.loadPendingEvaluations();
                    if (pendingCount > 0) {
                      Get.snackbar(
                        'Evaluaciones pendientes',
                        'Tienes $pendingCount evaluacion${pendingCount > 1 ? 'es' : ''} pendiente${pendingCount > 1 ? 's' : ''}. Entra a cada curso para completarlas.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFF76900).withAlpha(30),
                        colorText: const Color(0xFFF76900),
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        duration: const Duration(seconds: 3),
                      );
                    } else {
                      Get.snackbar(
                        'Todo al día',
                        'No tienes evaluaciones pendientes',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade100,
                        colorText: Colors.green.shade900,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  icon: const Icon(Icons.assignment_outlined, color: Colors.white),
                ),
                if (pendingCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF76900),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
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
          onRefresh: () async {
            await controller.loadCourses();
            await controller.loadPendingEvaluations();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: controller.courses.length,
            itemBuilder: (context, index) {
              final course = controller.courses[index];
              return _StudentCourseCard(
                course: course, 
                controller: controller,
              );
            },
          ),
        );
      }),
    );
  }
}

class _StudentCourseCard extends StatelessWidget {
  final TeacherCourseOverview course;
  final StudentHomeController controller;

  const _StudentCourseCard({
    required this.course, 
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.to(() => StudentCourseDetailView(course: course));
          },
          child: Container(
            decoration: BoxDecoration(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    Obx(() {
                      final pendingForCourse = controller.pendingEvaluations
                          .where((p) => p.cycle.courseId == course.id)
                          .fold<int>(0, (sum, p) => sum + p.pendingCount);
                      
                      if (pendingForCourse > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF76900),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.assignment_late_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$pendingForCourse',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
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
                                .trim()
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
                                        '- $studentName${isLogged ? ' (Tú)' : ''}',
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
