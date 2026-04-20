// placeholder
// lib/modules/auth/views/register_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.registerFormKey,
            child: ListView(
              children: [
                const SizedBox(height: 30),

                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Register to start learning",
                  style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: controller.nameController,
                  validator: Validators.name,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    labelStyle: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                  ),
                ),

                const SizedBox(height: 20),

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
                      onPressed: controller.isLoading.value ? null : controller.register,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text("Register"),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
