import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme.dart';
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: const [
              Icon(Icons.class_, color: Color(0xFFF76900)),
              SizedBox(width: 8),
              Text('Crear curso', style: TextStyle(color: Color(0xFF2D2D2D))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nrcCtrl,
                decoration: InputDecoration(
                  labelText: 'NRC',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: termCtrl,
                decoration: InputDecoration(
                  labelText: 'Periodo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF76900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
              Obx(() {
                final isProcessing = controller.isCsvProcessing(course.id);
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isProcessing
                            ? null
                            : () => _openCategorySyncDialog(context),
                        icon: isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          isProcessing ? 'Procesando CSV...' : 'Cargar CSV',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isProcessing
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategorySyncDialog(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      final fileName = file.name;
      final bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo leer el archivo seleccionado')),
        );
        return;
      }

      // Extraer el nombre de la categoría del nombre del archivo
      final categoryName = _extractCategoryName(fileName);
      if (categoryName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre del archivo no tiene el formato esperado (debe empezar con "Categoria")')),
        );
        return;
      }

      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar importación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archivo: $fileName'),
              const SizedBox(height: 8),
              Text('Categoría detectada: $categoryName'),
              const SizedBox(height: 16),
              const Text('¿Desea continuar con la importación?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final content = utf8.decode(bytes, allowMalformed: true);
        await controller.syncCsvContent(
          courseId: course.id,
          categoryName: categoryName,
          csvContent: content,
          uploadedBy: controller.primaryTeacherOwner,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el archivo CSV: $e')),
      );
    }
  }

  String? _extractCategoryName(String fileName) {
    // Remover la extensión .csv (case-insensitive)
    var nameWithoutExt = fileName;
    if (nameWithoutExt.toLowerCase().endsWith('.csv')) {
      nameWithoutExt = nameWithoutExt.substring(0, nameWithoutExt.length - 4);
    }

    // Normalizar para verificar si empieza con "categoria" (ignorando tildes y mayúsculas)
    final normalizedName = _normalizeText(nameWithoutExt.toLowerCase());
    if (!normalizedName.startsWith('categoria')) {
      return null;
    }

    // Encontrar la posición de "categoria" en el nombre normalizado
    final categoriaIndex = normalizedName.indexOf('categoria');
    final categoriaLength = 'categoria'.length;

    // Extraer la parte después de "categoria" usando el nombre original
    final categoryPart = nameWithoutExt.substring(categoriaIndex + categoriaLength);
    if (categoryPart.isEmpty) {
      return null;
    }

    // Tomar texto hasta el primer guion bajo (ej: CategoriaPyFlutter_AllGroups -> PyFlutter)
    final pieces = categoryPart.split('_');
    final rawCategory = pieces.first.trim();
    if (rawCategory.isEmpty) {
      return null;
    }

    // Devolver el nombre de categoría original, respetando mayúsculas y tildes
    return rawCategory;
  }

  String _normalizeText(String text) {
    // Reemplazar tildes
    return text
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'N');
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
