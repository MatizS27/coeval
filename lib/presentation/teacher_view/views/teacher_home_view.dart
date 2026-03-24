import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/teacher_home_controller.dart';
import 'teacher_course_detail_view.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacherHomeController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: const Text('My Courses', style: TextStyle(color: Colors.white)),
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
              'No hay cursos todavía',
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
              return _CourseCard(course: course, controller: controller);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCourseDialog(context, controller),
        backgroundColor: const Color(0xFFF76900),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateCourseDialog(
    BuildContext context,
    TeacherHomeController controller,
  ) {
    final nameCtrl = TextEditingController();
    final nrcCtrl = TextEditingController();
    final termCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Crear curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nrcCtrl,
                decoration: const InputDecoration(labelText: 'NRC'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: termCtrl,
                decoration: const InputDecoration(labelText: 'Periodo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final nrc = nrcCtrl.text.trim();
                final term = termCtrl.text.trim();

                if (name.isEmpty || nrc.isEmpty || term.isEmpty) {
                  return;
                }

                Get.back();
                await controller.createCourse(name: name, nrc: nrc, term: term);
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final TeacherCourseOverview course;
  final TeacherHomeController controller;

  const _CourseCard({required this.course, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => TeacherCourseDetailView(course: course));
        },
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
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.category,
                    text: '${course.categoriesCount} categorías',
                  ),
                  _InfoChip(
                    icon: Icons.group_work,
                    text: '${course.groupsCount} grupos',
                  ),
                  _InfoChip(
                    icon: Icons.people_alt,
                    text: '${course.activeStudentsCount} estudiantes',
                  ),
                ],
              ),
              if (course.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                const Text(
                  'Categorías y grupos',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 8),
                ...course.categories.map((category) {
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
                            '${category.name} · ${category.groups.length} grupos · ${category.activeStudentsCount} estudiantes',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openCategorySyncDialog(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Cargar CSV'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategorySyncDialog(BuildContext context) {
    final categoryCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sincronizar categoría desde CSV'),
          content: TextField(
            controller: categoryCtrl,
            decoration: const InputDecoration(
              labelText: 'Categoría (ej: CategoriaPyFlutter)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final category = categoryCtrl.text.trim();
                if (category.isEmpty) {
                  return;
                }

                Get.back();
                await controller.pickCsvAndSync(
                  courseId: course.id,
                  categoryName: category,
                );
              },
              child: const Text('Seleccionar CSV'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF777777)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}
