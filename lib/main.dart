import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/theme.dart';
import 'presentation/auth/controllers/auth_controller.dart';
import 'presentation/auth/views/login_view.dart';
import 'presentation/auth/views/register_view.dart';
import 'presentation/home/views/home_view.dart';

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

  Get.put(AuthController());

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
      initialRoute: '/login',
      getPages: [
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
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
