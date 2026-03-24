import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../domain/usecases/academic_use_cases.dart';

class TeacherHomeController extends GetxController {
  final AuthController _authController;
  final CreateCourseUseCase _createCourseUseCase;
  final GetTeacherCourseOverviewsUseCase _getTeacherCourseOverviewsUseCase;
  final SyncCategoryFromCsvUseCase _syncCategoryFromCsvUseCase;
  final CreateEvaluationCycleUseCase _createEvaluationCycleUseCase;

  TeacherHomeController({
    required AuthController authController,
    required CreateCourseUseCase createCourseUseCase,
    required GetTeacherCourseOverviewsUseCase getTeacherCourseOverviewsUseCase,
    required SyncCategoryFromCsvUseCase syncCategoryFromCsvUseCase,
    required CreateEvaluationCycleUseCase createEvaluationCycleUseCase,
  }) : _authController = authController,
       _createCourseUseCase = createCourseUseCase,
       _getTeacherCourseOverviewsUseCase = getTeacherCourseOverviewsUseCase,
       _syncCategoryFromCsvUseCase = syncCategoryFromCsvUseCase,
       _createEvaluationCycleUseCase = createEvaluationCycleUseCase;

  final isLoading = false.obs;
  final courses = <TeacherCourseOverview>[].obs;
  Worker? _authWorker;

  List<String> get _teacherOwnerCandidates {
    final user = _authController.currentUser.value;

    final raw = <String?>[
      user?.email,
      user?.uid,
      user?.id,
    ];

    final normalized = raw
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .map((value) => value.contains('@') ? value.toLowerCase() : value)
        .toSet()
        .toList();

    return normalized;
  }

  String get _primaryTeacherOwner {
    final candidates = _teacherOwnerCandidates;
    return candidates.isEmpty ? '' : candidates.first;
  }

  @override
  void onInit() {
    super.onInit();

    _authWorker = everAll([
      _authController.isLoggedIn,
      _authController.currentUser,
    ], (_) async {
      if (_authController.isLoggedIn.value &&
          _authController.currentUser.value != null) {
        await loadCourses();
      } else {
        courses.clear();
      }
    });

    loadCourses();
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  Future<void> loadCourses() async {
    final owner = _primaryTeacherOwner;
    if (owner.isEmpty) {
      return;
    }

    isLoading.value = true;
    try {
      final result = await _getTeacherCourseOverviewsUseCase(owner);
      courses.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCourse({
    required String name,
    required String nrc,
    required String term,
  }) async {
    final teacherOwner = _primaryTeacherOwner;
    if (teacherOwner.isEmpty) {
      _showError('No se pudo identificar el profesor actual');
      return;
    }

    isLoading.value = true;
    try {
      final created = await _createCourseUseCase(
        name: name,
        nrc: nrc,
        term: term,
        teacherUid: teacherOwner,
      );

      if (created == null) {
        _showError('No se pudo crear el curso');
        return;
      }

      await loadCourses();
      _showSuccess('Curso creado correctamente');
    } catch (e) {
      _showError('Error al crear curso: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickCsvAndSync({
    required String courseId,
    required String categoryName,
  }) async {
    final teacherOwner = _primaryTeacherOwner;
    if (teacherOwner.isEmpty) {
      _showError('No se pudo identificar el profesor actual');
      return;
    }

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
      final bytes = file.bytes;
      if (bytes == null) {
        _showError('No se pudo leer el archivo seleccionado');
        return;
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      await syncCsvContent(
        courseId: courseId,
        categoryName: categoryName,
        csvContent: content,
        uploadedBy: teacherOwner,
      );
    } catch (e) {
      _showError('Error al abrir el archivo CSV: $e');
    }
  }

  Future<void> syncCsvContent({
    required String courseId,
    required String categoryName,
    required String csvContent,
    required String uploadedBy,
  }) async {
    isLoading.value = true;

    try {
      final result = await _syncCategoryFromCsvUseCase(
        courseId: courseId,
        categoryName: categoryName,
        csvContent: csvContent,
        uploadedBy: uploadedBy,
      );

      await loadCourses();
      if (result.createdGroups == 0 &&
          result.activatedEnrollments == 0 &&
          result.closedEnrollments == 0) {
        _showSuccess(
          'CSV sin cambios: ya había sido procesado para esta categoría.',
        );
      } else {
        _showSuccess(
          'CSV procesado: ${result.totalRows} filas, ${result.createdGroups} grupos nuevos, ${result.activatedEnrollments} estudiantes activados, ${result.closedEnrollments} cerrados.',
        );
      }
    } catch (e) {
      _showError('No se pudo procesar el CSV: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvaluationCycle({
    required String courseId,
    required String categoryId,
    required String title,
    DateTime? closesAt,
  }) async {
    final teacherOwner = _primaryTeacherOwner;
    if (teacherOwner.isEmpty) {
      _showError('No se pudo identificar el profesor actual');
      return;
    }

    isLoading.value = true;
    try {
      final cycle = await _createEvaluationCycleUseCase(
        courseId: courseId,
        categoryId: categoryId,
        title: title,
        openedBy: teacherOwner,
        closesAt: closesAt,
      );

      if (cycle == null) {
        _showError('No se pudo abrir la coevaluación');
        return;
      }

      _showSuccess('Coevaluación "${cycle.title}" abierta.');
    } catch (e) {
      _showError('No se pudo abrir la coevaluación: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.check_circle_outline, color: Colors.green.shade900),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.error_outline, color: Colors.red.shade900),
    );
  }
}
