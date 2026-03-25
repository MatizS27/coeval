import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final ResetPasswordController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                _buildHeader(),
                
                const SizedBox(height: 40),
                
                _buildResetForm(),
                
                const SizedBox(height: 40),
                
                _buildResetButton(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Restablecer Contraseña',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Ingresa el token de recuperación y tu nueva contraseña',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => TextField(
            controller: controller.tokenController,
            onChanged: (v) => controller.token.value = v,
            decoration: InputDecoration(
              labelText: 'Token de recuperación',
              hintText: 'Ingresa el token del email',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              errorText: controller.tokenError.value,
            ),
          )),
          
          const SizedBox(height: 16),
          
          Obx(() => TextField(
            controller: controller.newPasswordController,
            obscureText: controller.obscureNewPassword.value,
            onChanged: (v) => controller.newPassword.value = v,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outlined),
              errorText: controller.newPasswordError.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureNewPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: controller.toggleNewPasswordVisibility,
              ),
            ),
          )),
          
          const SizedBox(height: 16),
          
          Obx(() => TextField(
            controller: controller.confirmPasswordController,
            obscureText: controller.obscureConfirmPassword.value,
            onChanged: (v) => controller.confirmPassword.value = v,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: const Icon(Icons.lock_outlined),
              errorText: controller.confirmPasswordError.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ElevatedButton(
              onPressed: controller.resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Restablecer Contraseña',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle_outline, color: Colors.white),
                ],
              ),
            ),
    ));
  }
}