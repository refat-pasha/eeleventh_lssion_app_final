// lib/app/routes/app_routes.dart

abstract class Routes {
  Routes._();

  /// ================= CORE =================
  static const splash = '/splash';

  /// ================= AUTH =================
  static const login = '/login';
  static const register = '/register';
  static const setupProfile = '/setup-profile';

  /// ================= MAIN =================
  static const dashboard = '/dashboard';

  /// ================= FEATURES =================
  static const assignment = '/assignment';
  static const quiz = '/quiz';
  static const publication = '/publication';
  static const collaborative = '/collaborative';
  static const progress = '/progress';
  static const offline = '/offline';

  /// ================= PROFILE =================
  static const profile = '/profile';
  static const settings = '/settings';
  static const accountSettings = '/account-settings';
  static const academicProfile = '/academic-profile';
  static const appearance = '/appearance';
}