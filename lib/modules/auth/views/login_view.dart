// placeholder
// lib/modules/auth/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validators.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Login to continue learning",
                  style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: controller.emailController,
                  validator: Validators.email,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: controller.passwordController,
                  validator: Validators.password,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                  ),
                ),

                const SizedBox(height: 30),

                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text("Login"),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.register),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
