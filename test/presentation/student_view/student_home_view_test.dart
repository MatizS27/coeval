import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:coeval/presentation/student_view/views/student_home_view.dart';
import 'package:coeval/presentation/student_view/controllers/student_home_controller.dart';
import 'package:coeval/presentation/auth/controllers/auth_controller.dart';
import 'package:coeval/domain/entities/academic_entities.dart';
import 'package:coeval/data/datasources/roble_datasource.dart';
import '../../mocks/mock_student_controller.dart';
import '../../mocks/mock_auth_controller.dart';

void main() {
  late MockStudentHomeController mockStudentController;
  late MockAuthController mockAuthController;

  setUp(() {
    mockStudentController = MockStudentHomeController();
    mockAuthController = MockAuthController();

    // Mocking AuthController basic states
    when(() => mockAuthController.isLoggedIn).thenReturn(true.obs);
    final userData = UserData(
      id: '1',
      uid: 'uid123',
      email: 'student@uninorte.edu.co',
      name: 'Student Test',
      role: 'student',
    );
    when(() => mockAuthController.currentUser).thenReturn(Rxn<UserData>(userData));

    // Mocking StudentHomeController basic states
    when(() => mockStudentController.isLoading).thenReturn(false.obs);
    when(() => mockStudentController.courses).thenReturn(<TeacherCourseOverview>[].obs);
    when(() => mockStudentController.pendingEvaluations).thenReturn(<PendingEvaluationInfo>[].obs);
    when(() => mockStudentController.totalPendingCount).thenReturn(0);
    
    // Mocking methods
    when(() => mockStudentController.loadCourses()).thenAnswer((_) async => {});
    when(() => mockStudentController.loadPendingEvaluations()).thenAnswer((_) async => {});

    Get.put<AuthController>(mockAuthController);
    Get.put<StudentHomeController>(mockStudentController);
  });

  tearDown(() {
    Get.reset();
  });

  group('StudentHomeView - Pruebas de Nivel 1', () {
    testWidgets('Debe mostrar mensaje cuando no hay cursos', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: StudentHomeView()));

      expect(find.text('Mis Cursos'), findsOneWidget);
      expect(find.text('No estás inscrito en cursos todavía'), findsOneWidget);
    });

    testWidgets('Debe mostrar CircularProgressIndicator al cargar cursos', (WidgetTester tester) async {
      when(() => mockStudentController.isLoading).thenReturn(true.obs);
      when(() => mockStudentController.courses).thenReturn(<TeacherCourseOverview>[].obs);

      await tester.pumpWidget(const GetMaterialApp(home: StudentHomeView()));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de cursos correctamente', (WidgetTester tester) async {
      final course = TeacherCourseOverview(
        id: 'c1',
        name: 'Curso de Prueba',
        nrc: '1234',
        term: '202410',
        categoriesCount: 1,
        groupsCount: 1,
        activeStudentsCount: 30,
        categories: [],
      );
      
      when(() => mockStudentController.courses).thenReturn(<TeacherCourseOverview>[course].obs);

      await tester.pumpWidget(const GetMaterialApp(home: StudentHomeView()));
      await tester.pump();

      expect(find.text('Curso de Prueba'), findsOneWidget);
      expect(find.text('NRC 1234 · 202410'), findsOneWidget);
    });

    testWidgets('Debe mostrar el badge de evaluaciones pendientes si existen', (WidgetTester tester) async {
      when(() => mockStudentController.totalPendingCount).thenReturn(5);

      await tester.pumpWidget(const GetMaterialApp(home: StudentHomeView()));
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('Debe llamar al logout del AuthController al pulsar el botón de salida', (WidgetTester tester) async {
      when(() => mockAuthController.logout()).thenAnswer((_) async => {});

      await tester.pumpWidget(const GetMaterialApp(home: StudentHomeView()));
      
      await tester.tap(find.byIcon(Icons.logout));
      
      verify(() => mockAuthController.logout()).called(1);
    });
  });
}
