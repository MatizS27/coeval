import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Importa tus vistas y controladores
import 'presentation/auth/views/login_view.dart';
import 'presentation/auth/views/register_view.dart';
import 'presentation/home/views/home_view.dart';
import 'presentation/auth/controllers/auth_controller.dart';

void main() {
  // 1. Inyectamos el controlador de autenticación al iniciar la app
  // Esto permite que el Login y el Registro compartan la misma lógica de Roble
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Usamos GetMaterialApp en lugar de MaterialApp para habilitar GetX
    return GetMaterialApp(
      title: 'CoEval - Peer Assessment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 3. Definimos la ruta inicial (Login) según el flujo del proyecto
      initialRoute: '/login',
      // 4. Definimos el mapa de rutas para navegar fácilmente
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/register', page: () => RegisterView()),
        GetPage(name: '/home', page: () => HomeView()),
      ],
    );
  }
}