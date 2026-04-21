import 'package:get/get.dart';
import '../../../domain/entities/dashboard_stats.dart';
import '../../../domain/usecases/get_evaluation_results_use_case.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final GetEvaluationResultsUseCase _getResultsUseCase;
  final AuthController _authController = Get.find<AuthController>();

  DashboardController({
    required GetEvaluationResultsUseCase getResultsUseCase,
  }) : _getResultsUseCase = getResultsUseCase;

  final isLoading = false.obs;
  final studentResults = <EvaluationResult>[].obs;
  final teacherConsolidated = Rxn<DashboardConsolidated>();

  bool get isTeacher => _authController.currentUser.value?.role == 'teacher';
  String get userUid => _authController.currentUser.value?.uid ?? 
                        _authController.currentUser.value?.id ?? '';

  Future<void> loadDashboardData({String? cycleId}) async {
    isLoading.value = true;
    try {
      if (isTeacher) {
        if (cycleId != null) {
          final data = await _getResultsUseCase.executeForTeacher(cycleId);
          teacherConsolidated.value = data;
        }
      } else {
        if (userUid.isNotEmpty) {
          final data = await _getResultsUseCase.executeForStudent(userUid);
          studentResults.assignAll(data);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los resultados');
    } finally {
      isLoading.value = false;
    }
  }
}
