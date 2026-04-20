import 'package:get/get.dart';

import 'app_routes.dart';

/// ================= SPLASH =================
import '../../modules/splash/views/splash_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';

/// ================= AUTH =================
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/views/setup_profile_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';

/// ================= NAVIGATION =================
import '../../modules/navigation/views/main_navigation_view.dart';

/// ================= PROFILE =================
import '../../modules/profile/views/settings_view.dart';
import '../../modules/profile/views/account_settings_view.dart';
import '../../modules/profile/views/academic_profile_view.dart';
import '../../modules/profile/views/appearance_view.dart';

import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/bindings/account_settings_binding.dart';
import '../../modules/profile/bindings/academic_profile_binding.dart';
import '../../modules/profile/bindings/appearance_binding.dart';

/// ================= FEATURES =================
import '../../modules/quiz/views/quiz_view.dart';
import '../../modules/quiz/bindings/quiz_binding.dart';

import '../../modules/assignment/views/assignment_view.dart';
import '../../modules/assignment/bindings/assignment_binding.dart';

import '../../modules/publication/views/upload_material_view.dart';
import '../../modules/publication/bindings/publication_binding.dart';

import '../../modules/offline/views/offline_view.dart';
import '../../modules/offline/bindings/offline_binding.dart';

import '../../modules/progress/views/progress_view.dart';
import '../../modules/progress/bindings/progress_binding.dart';

import '../../modules/collaborative/views/study_groups_view.dart';
import '../../modules/collaborative/bindings/collaborative_binding.dart';

/// ================= DASHBOARD =================
import '../../modules/dashboard/bindings/dashboard_binding.dart';

class AppPages {
  AppPages._();

  /// 🔥 Initial Route
  static const initial = Routes.splash;

  /// 🔥 All App Routes
  static final routes = [

    /// ================= SPLASH =================
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    /// ================= AUTH =================
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.setupProfile,
      page: () => const SetupProfileView(),
      binding: AuthBinding(),
    ),

    /// ================= MAIN DASHBOARD =================
    /// ⚠️ Central entry point after login
    GetPage(
      name: Routes.dashboard,
      page: () => const MainNavigationView(),
      bindings: [
        DashboardBinding(),
        ProfileBinding(),
        PublicationBinding(),
        ProgressBinding(), // Progress is part of dashboard tabs
      ],
    ),

    /// ================= SETTINGS =================
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: ProfileBinding(),
    ),

    /// ================= FEATURES =================

    /// QUIZ
    GetPage(
      name: Routes.quiz,
      page: () => const QuizView(),
      binding: QuizBinding(),
    ),

    /// ASSIGNMENT
    GetPage(
      name: Routes.assignment,
      page: () => const AssignmentView(),
      binding: AssignmentBinding(),
    ),

    /// PUBLICATION / UPLOAD
    GetPage(
      name: Routes.publication,
      page: () => const UploadMaterialView(),
      binding: PublicationBinding(),
    ),

    /// OFFLINE MODE
    GetPage(
      name: Routes.offline,
      page: () => const OfflineView(),
      binding: OfflineBinding(),
    ),

    /// PROGRESS (can be opened directly or via dashboard tab)
    GetPage(
      name: Routes.progress,
      page: () => const ProgressView(),
      binding: ProgressBinding(),
    ),

    /// COLLABORATIVE / STUDY GROUPS
    GetPage(
      name: Routes.collaborative,
      page: () => const StudyGroupsView(),
      binding: CollaborativeBinding(),
    ),

    /// ================= PROFILE SETTINGS =================

    GetPage(
      name: Routes.accountSettings,
      page: () => const AccountSettingsView(),
      binding: AccountSettingsBinding(),
    ),

    GetPage(
      name: Routes.academicProfile,
      page: () => const AcademicProfileView(),
      binding: AcademicProfileBinding(),
    ),

    GetPage(
      name: Routes.appearance,
      page: () => const AppearanceView(),
      binding: AppearanceBinding(),
    ),
  ];
}