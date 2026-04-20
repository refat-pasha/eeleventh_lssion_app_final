// placeholder
// lib/core/constants/api_constants.dart

class ApiConstants {
  // Base API URL (if you use your own backend later)
  static const String baseUrl = "https://api.11thlesson.com";

  // Firebase collections
  static const String usersCollection = "users";
  static const String coursesCollection = "courses";
  static const String assignmentsCollection = "assignments";
  static const String quizzesCollection = "quizzes";
  static const String materialsCollection = "materials";
  static const String groupsCollection = "groups";
  static const String progressCollection = "progress";

  // API Endpoints (optional for REST backend)
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  static const String getCourses = "/courses";
  static const String getAssignments = "/assignments";
  static const String getQuizzes = "/quizzes";
  static const String getMaterials = "/materials";

  static const String uploadMaterial = "/materials/upload";
  static const String submitAssignment = "/assignments/submit";
  static const String submitQuiz = "/quiz/submit";

  // Timeout settings
  static const int connectionTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms
}