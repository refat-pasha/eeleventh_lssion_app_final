import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/theme/colors.dart';
import 'modules/profile/controllers/appearance_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Firebase
  await Firebase.initializeApp();

  /// Local storage
  await GetStorage.init();

  ///  INIT CONTROLLER
  Get.put(AppearanceController());

  runApp(const EleventhLessonApp());
}

class EleventhLessonApp extends StatelessWidget {
  const EleventhLessonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
          title: "11th Lesson",
          debugShowCheckedModeBanner: false,

          /// ROUTES
          initialBinding: InitialBinding(),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,

          ///  LIGHT THEME 
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F7FB),
            cardColor: Colors.white,
            primaryColor: Colors.blue,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),

            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
            ),
          ),

          ///  DARK THEME 
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            cardColor: AppColors.cardDark,
            primaryColor: Colors.blue,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
          ),

        );
  }
}