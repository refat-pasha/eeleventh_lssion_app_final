// placeholder
// lib/core/constants/storage_keys.dart

class StorageKeys {
  // Auth
  static const String userToken = "user_token";
  static const String userId = "user_id";
  static const String userEmail = "user_email";
  static const String userRole = "user_role";

  // User Preferences
  static const String isLoggedIn = "is_logged_in";
  static const String themeMode = "theme_mode";
  static const String language = "language";

  // Cached Data
  static const String cachedCourses = "cached_courses";
  static const String cachedAssignments = "cached_assignments";
  static const String cachedQuizzes = "cached_quizzes";

  // Offline Materials
  static const String offlineMaterials = "offline_materials";

  // Pending sync queue (offline actions waiting for connection)
  static const String pendingSyncQueue = "pending_sync_queue";
  static const String lastSyncAt = "last_sync_at";

  // Progress
  static const String userProgress = "user_progress";

  // Notifications
  static const String notifications = "notifications";
}