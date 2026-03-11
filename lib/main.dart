import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coeval/presentation/home/bindings/home_binding.dart';
import 'package:coeval/presentation/home/views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CoevaL - University Peer Assessment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
      initialBinding: HomeBinding(),
    );
  }
}
