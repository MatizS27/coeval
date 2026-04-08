import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../../domain/usecases/academic_use_cases.dart';
import '../../auth/controllers/auth_controller.dart';

class StudentHomeController extends GetxController {
  final AuthController _authController;
  final GetStudentCourseOverviewsUseCase _getStudentCourseOverviewsUseCase;
  final GetPendingEvaluationsForStudentUseCase _getPendingEvaluationsUseCase;
  final SubmitEvaluationUseCase _submitEvaluationUseCase;

  StudentHomeController({
    required AuthController authController,
    required GetStudentCourseOverviewsUseCase getStudentCourseOverviewsUseCase,
    required GetPendingEvaluationsForStudentUseCase getPendingEvaluationsUseCase,
    required SubmitEvaluationUseCase submitEvaluationUseCase,
  }) : _authController = authController,
       _getStudentCourseOverviewsUseCase = getStudentCourseOverviewsUseCase,
       _getPendingEvaluationsUseCase = getPendingEvaluationsUseCase,
       _submitEvaluationUseCase = submitEvaluationUseCase;

  final isLoading = false.obs;
  final courses = <TeacherCourseOverview>[].obs;
  final pendingEvaluations = <PendingEvaluationInfo>[].obs;
  Worker? _authWorker;

  String get _studentEmail =>
      _authController.currentUser.value?.email.trim().toLowerCase() ?? '';
  
  String get _studentUid =>
      (_authController.currentUser.value?.uid ?? 
       _authController.currentUser.value?.id ?? '').trim();

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
        await loadPendingEvaluations();
      } else {
        courses.clear();
        pendingEvaluations.clear();
      }
    });

    loadCourses();
    loadPendingEvaluations();
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  Future<void> loadCourses() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      courses.clear();
      return;
    }

    final email = user.email.trim().toLowerCase();
    final uid = (user.uid ?? user.id ?? '').trim();

    if (email.isEmpty && uid.isEmpty) {
      courses.clear();
      return;
    }

    isLoading.value = true;
    try {
      final result = await _getStudentCourseOverviewsUseCase(
        studentEmail: email,
        studentUid: uid.isEmpty ? null : uid,
      );
      courses.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingEvaluations() async {
    if (_studentEmail.isEmpty && _studentUid.isEmpty) {
      pendingEvaluations.clear();
      return;
    }

    try {
      final result = await _getPendingEvaluationsUseCase(
        studentEmail: _studentEmail,
        studentUid: _studentUid,
      );
      pendingEvaluations.assignAll(result);
    } catch (e) {
      _showError('Error al cargar evaluaciones pendientes');
    }
  }

  Future<List<PendingEvaluationInfo>> getPendingEvaluations() async {
    if (_studentEmail.isEmpty && _studentUid.isEmpty) {
      return [];
    }

    try {
      return await _getPendingEvaluationsUseCase(
        studentEmail: _studentEmail,
        studentUid: _studentUid,
      );
    } catch (e) {
      _showError('Error al cargar evaluaciones pendientes');
      return [];
    }
  }

  Future<bool> submitEvaluation({
    required String cycleId,
    required String evaluateeUid,
    required List<int> scores,
    String? comments,
  }) async {
    final evaluatorUid = _studentUid.isNotEmpty 
        ? _studentUid 
        : 'email:$_studentEmail';

    try {
      final success = await _submitEvaluationUseCase(
        cycleId: cycleId,
        evaluatorUid: evaluatorUid,
        evaluateeUid: evaluateeUid,
        scores: scores,
        comments: comments,
      );

      if (!success) {
        _showError('No se pudo enviar la evaluación');
      }

      return success;
    } catch (e) {
      _showError('Error al enviar evaluación: $e');
      return false;
    }
  }

  int get totalPendingCount {
    int total = 0;
    for (final pending in pendingEvaluations) {
      total += pending.pendingCount;
    }
    return total;
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
