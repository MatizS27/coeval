import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'central.dart';
import 'core/theme.dart';
import 'data/datasources/academic_remote_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/roble_datasource.dart';
import 'data/repositories/academic_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/academic_use_cases.dart';
import 'domain/usecases/login_use_case.dart';
import 'presentation/auth/controllers/auth_controller.dart';
import 'presentation/auth/views/login_view.dart';
import 'presentation/auth/views/register_view.dart';
import 'presentation/student_view/controllers/student_home_controller.dart';
import 'presentation/teacher_view/controllers/teacher_home_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final robleDatasource = RobleDatasource();
  final authRemoteDatasource = AuthRemoteDatasource(robleDatasource);
  final academicRemoteDatasource = AcademicRemoteDatasource(robleDatasource);
  final authRepository = AuthRepositoryImpl(authRemoteDatasource);
  final academicRepository = AcademicRepositoryImpl(academicRemoteDatasource);

  final authController = Get.put(
    AuthController(
      registerStudentUseCase: RegisterStudentUseCase(authRepository),
      loginUseCase: LoginUseCase(authRepository),
      getUserByEmailUseCase: GetUserByEmailUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      verifyTokenUseCase: VerifyTokenUseCase(authRepository),
      setTokenUseCase: SetTokenUseCase(authRepository),
    ),
    permanent: true,
  );

  Get.put(
    TeacherHomeController(
      authController: authController,
      createCourseUseCase: CreateCourseUseCase(academicRepository),
      getTeacherCourseOverviewsUseCase: GetTeacherCourseOverviewsUseCase(
        academicRepository,
      ),
      syncCategoryFromCsvUseCase: SyncCategoryFromCsvUseCase(
        academicRepository,
      ),
      createEvaluationCycleUseCase: CreateEvaluationCycleUseCase(
        academicRepository,
      ),
    ),
    permanent: true,
  );

  Get.put(
    StudentHomeController(
      authController: authController,
      getStudentCourseOverviewsUseCase: GetStudentCourseOverviewsUseCase(
        academicRepository,
      ),
    ),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CoEval',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Central(),
      getPages: [
        GetPage(
          name: '/',
          page: () => const Central(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
