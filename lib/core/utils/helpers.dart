// placeholder
// lib/core/utils/helpers.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Helpers {
  // Screen width
  static double screenWidth() {
    return Get.width;
  }

  // Screen height
  static double screenHeight() {
    return Get.height;
  }

  // Hide keyboard
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Show Snackbar
  static void showSnackbar({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Navigate to page
  static void navigateTo(String route) {
    Get.toNamed(route);
  }

  // Replace current page
  static void replaceWith(String route) {
    Get.offNamed(route);
  }

  // Clear stack and go to page
  static void clearAndNavigate(String route) {
    Get.offAllNamed(route);
  }

  // Format number with commas
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  // Check if string is empty
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}