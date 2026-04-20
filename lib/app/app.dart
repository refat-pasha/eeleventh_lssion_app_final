// placeholder
// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';

import 'theme/app_theme.dart';

class ElevenLessonApp extends StatelessWidget {
  const ElevenLessonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '11th Lesson',
      debugShowCheckedModeBanner: false,

      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
    );
  }
}