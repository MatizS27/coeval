import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'presentation/auth/controllers/auth_controller.dart';
import 'presentation/auth/views/login_view.dart';
import 'presentation/auth/views/register_view.dart';
import 'presentation/home/views/home_view.dart';

void main() {

  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(

      debugShowCheckedModeBanner: false,

      initialRoute: '/login',

      getPages: [

        GetPage(
          name: '/login',
          page: () => LoginView(),
        ),

        GetPage(
          name: '/register',
          page: () => RegisterView(),
        ),

        GetPage(
          name: '/home',
          page: () => HomeView(),
        ),

      ],
    );
  }
}