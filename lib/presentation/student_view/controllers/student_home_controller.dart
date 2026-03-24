import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../../domain/usecases/academic_use_cases.dart';
import '../../auth/controllers/auth_controller.dart';

class StudentHomeController extends GetxController {
  final AuthController _authController;
  final GetStudentCourseOverviewsUseCase _getStudentCourseOverviewsUseCase;

  StudentHomeController({
    required AuthController authController,
    required GetStudentCourseOverviewsUseCase getStudentCourseOverviewsUseCase,
  }) : _authController = authController,
       _getStudentCourseOverviewsUseCase = getStudentCourseOverviewsUseCase;

  final isLoading = false.obs;
  final courses = <TeacherCourseOverview>[].obs;
  Worker? _authWorker;

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
}
