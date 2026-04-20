import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/academic_profile_controller.dart';
import '../../../app/theme/colors.dart';

class AcademicProfileView extends GetView<AcademicProfileController> {
  const AcademicProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Academic Profile"), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Manage your academic information", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
              const SizedBox(height: 20),
              TextField(
                controller: controller.universityController,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("University", "Enter your university name", cardColor, textColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.departmentController,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("Department", "e.g. CSE", cardColor, textColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.semesterController,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("Semester", "e.g. 5th Semester", cardColor, textColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.subjectsController,
                style: TextStyle(color: textColor),
                maxLines: 3,
                decoration: _inputDecoration("Subjects (comma separated)", "e.g. AI, DBMS, Computer Networks", cardColor, textColor),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.saveAcademicInfo,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Academic Info"),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, Color cardColor, Color? textColor) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: textColor?.withValues(alpha: 0.7)),
      hintStyle: TextStyle(color: textColor?.withValues(alpha: 0.38)),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
