import 'package:get/get.dart';
import 'package:coeval/data/models/user_model.dart';
import 'package:coeval/domain/entities/user.dart';

class HomeController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  /// Load the current user from auth controller or API
  Future<void> loadCurrentUser() async {
    try {
      isLoading(true);
      error('');

      // TODO: Get current user from AuthController or API
      // For now, using mock data
      currentUser.value = UserModel(
        id: '1',
        email: 'usuario@ejemplo.com',
        name: 'Juan Pérez',
        role: UserRole.student, // Change to UserRole.teacher to see teacher dashboard
        profileImage: null,
        department: 'Ingeniería en Sistemas',
      );
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Check if current user is a teacher
  bool get isTeacher => currentUser.value?.role == UserRole.teacher;

  /// Check if current user is a student
  bool get isStudent => currentUser.value?.role == UserRole.student;

  /// Get user's initials for avatar
  String get userInitials {
    if (currentUser.value == null) return '';
    final names = currentUser.value!.name.split(' ');
    return (names.first[0] + (names.length > 1 ? names.last[0] : '')).toUpperCase();
  }

  /// Logout user
  void logout() {
    // TODO: Implement logout logic
    currentUser.value = null;
    Get.offAllNamed('/login');
  }
}
