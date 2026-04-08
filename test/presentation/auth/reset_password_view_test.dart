import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:coeval/presentation/auth/views/reset_password_view.dart';
import 'package:coeval/presentation/auth/controllers/reset_password_controller.dart';
import '../../mocks/mock_reset_password_controller.dart';

void main() {
  late MockResetPasswordController mockController;

  setUp(() {
    mockController = MockResetPasswordController();

    // Mocking Rx variables
    when(() => mockController.token).thenReturn(''.obs);
    when(() => mockController.newPassword).thenReturn(''.obs);
    when(() => mockController.confirmPassword).thenReturn(''.obs);
    when(() => mockController.isLoading).thenReturn(false.obs);
    when(() => mockController.obscureNewPassword).thenReturn(true.obs);
    when(() => mockController.obscureConfirmPassword).thenReturn(true.obs);
    
    when(() => mockController.tokenError).thenReturn(Rxn<String>());
    when(() => mockController.newPasswordError).thenReturn(Rxn<String>());
    when(() => mockController.confirmPasswordError).thenReturn(Rxn<String>());

    // Mocking TextControllers
    when(() => mockController.tokenController).thenReturn(TextEditingController());
    when(() => mockController.newPasswordController).thenReturn(TextEditingController());
    when(() => mockController.confirmPasswordController).thenReturn(TextEditingController());

    Get.put<ResetPasswordController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  group('ResetPasswordView - Pruebas de Nivel 1', () {
    testWidgets('Debe mostrar los elementos de restablecimiento correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: ResetPasswordView()));

      expect(find.text('Restablecer Contraseña'), findsNWidgets(2)); // AppBar y Título
      expect(find.text('Ingresa el token de recuperación y tu nueva contraseña'), findsOneWidget);
      
      expect(find.widgetWithText(TextField, 'Token de recuperación'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Nueva contraseña'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Confirmar contraseña'), findsOneWidget);
    });

    testWidgets('Debe mostrar errores de validación si el controlador los emite', (WidgetTester tester) async {
      when(() => mockController.tokenError).thenReturn(Rxn<String>('El token es requerido'));
      when(() => mockController.confirmPasswordError).thenReturn(Rxn<String>('Las contraseñas no coinciden'));

      await tester.pumpWidget(const GetMaterialApp(home: ResetPasswordView()));
      await tester.pump();

      expect(find.text('El token es requerido'), findsOneWidget);
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('Debe mostrar CircularProgressIndicator cuando isLoading es true', (WidgetTester tester) async {
      when(() => mockController.isLoading).thenReturn(true.obs);

      await tester.pumpWidget(const GetMaterialApp(home: ResetPasswordView()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Debe llamar a resetPassword al pulsar el botón', (WidgetTester tester) async {
      when(() => mockController.resetPassword()).thenAnswer((_) async => {});

      await tester.pumpWidget(const GetMaterialApp(home: ResetPasswordView()));
      
      final button = find.widgetWithText(ElevatedButton, 'Restablecer Contraseña');
      await tester.tap(button);
      
      verify(() => mockController.resetPassword()).called(1);
    });
  });
}
