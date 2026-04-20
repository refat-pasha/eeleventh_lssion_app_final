import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/course_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/providers/firebase_provider.dart';
import '../../../core/services/export_service.dart';

class ProgressController extends GetxController {
  final AuthRepository authRepository = Get.find();
  final CourseRepository courseRepository = Get.find();
  final FirebaseProvider firebaseProvider = Get.find();

  /// ================= STATE =================
  var isLoading = true.obs;

  final user = Rxn<UserModel>();
  final courses = <CourseModel>[].obs;
  final progressMap = <String, double>{}.obs;

  final RxList<Map<String, dynamic>> quizResults =
      <Map<String, dynamic>>[].obs;

  final RxList<int> weeklyActivity =
      <int>[0, 0, 0, 0, 0, 0, 0].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllProgress();
  }

  /// ================= LOAD ALL =================
  Future<void> loadAllProgress() async {
    try {
      isLoading.value = true;

      final firebaseUser = authRepository.currentUser;
      if (firebaseUser == null) return;

      /// USER
      final profile =
          await authRepository.getUserProfile(firebaseUser.uid);
      user.value = profile;

      /// COURSES
      final fetchedCourses = await courseRepository.getCourses();
      courses.assignAll(fetchedCourses);

      /// COURSE PROGRESS
      for (var course in fetchedCourses) {
        final progress = await calculateCourseProgress(course.id);
        progressMap[course.id] = progress;
      }

      /// EXTRA DATA
      await _loadQuizResults(firebaseUser.uid);
      await _loadWeeklyActivity(firebaseUser.uid);

    } catch (e) {
      Get.snackbar("Progress Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= COURSE PROGRESS =================
  Future<double> calculateCourseProgress(String courseId) async {
    final firebaseUser = authRepository.currentUser;
    if (firebaseUser == null) return 0;

    final materials = await firebaseProvider
        .materials()
        .where("courseId", isEqualTo: courseId)
        .get();

    final total = materials.docs.length;
    if (total == 0) return 0;

    final completed = await firebaseProvider
        .materialViews()
        .where("courseId", isEqualTo: courseId)
        .where("userId", isEqualTo: firebaseUser.uid)
        .get();

    return completed.docs.length / total;
  }

  /// ================= MARK MATERIAL VIEW =================
  Future<void> markMaterialViewed(
      String courseId, String materialId) async {
    final firebaseUser = authRepository.currentUser;
    if (firebaseUser == null) return;

    final existing = await firebaseProvider
        .materialViews()
        .where("userId", isEqualTo: firebaseUser.uid)
        .where("materialId", isEqualTo: materialId)
        .get();

    if (existing.docs.isNotEmpty) return;

    await firebaseProvider.materialViews().add({
      'userId': firebaseUser.uid,
      'courseId': courseId,
      'materialId': materialId,
      'viewedAt': FieldValue.serverTimestamp(),
    });

    /// 🔥 UPDATE ACTIVITY + STREAK
    await updateWeeklyActivity();

    final progress = await calculateCourseProgress(courseId);
    progressMap[courseId] = progress;
    progressMap.refresh();
  }

  /// ================= QUIZ RESULTS (FIXED) =================
  Future<void> _loadQuizResults(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        /// 🔥 FETCH QUIZ TITLE INSTEAD OF ID
        final quizDoc = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(data['quizId'])
            .get();

        final quizTitle =
            quizDoc.exists ? quizDoc['title'] ?? "Quiz" : "Quiz";

        results.add({
          'quizName': quizTitle,
          'score': data['score'] ?? 0,
          'total': data['totalQuestions'] ?? 0,
          'date': data['submittedAt'],
        });
      }

      quizResults.assignAll(results);

    } catch (e) {
      print("Quiz Load Error: $e");
    }
  }

  /// ================= WEEKLY ACTIVITY =================
  Future<void> _loadWeeklyActivity(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('activity')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null && data['weekly'] != null) {
          weeklyActivity.value = [
            data['weekly']['Mon'] ?? 0,
            data['weekly']['Tue'] ?? 0,
            data['weekly']['Wed'] ?? 0,
            data['weekly']['Thu'] ?? 0,
            data['weekly']['Fri'] ?? 0,
            data['weekly']['Sat'] ?? 0,
            data['weekly']['Sun'] ?? 0,
          ];
        }
      }
    } catch (e) {
      print("Weekly Load Error: $e");
    }
  }

  /// ================= ACTIVITY + STREAK =================
  Future<void> updateWeeklyActivity() async {
    try {
      final firebaseUser = authRepository.currentUser;
      if (firebaseUser == null) return;

      final userId = firebaseUser.uid;

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      final weekday = now.weekday;
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final today = days[weekday - 1];

      final docRef =
          FirebaseFirestore.instance.collection('activity').doc(userId);

      final doc = await docRef.get();

      Map<String, dynamic> weekly = {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };

      DateTime? lastActive;

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          if (data['weekly'] != null) {
            weekly = Map<String, dynamic>.from(data['weekly']);
          }

          if (data['lastActive'] != null) {
            lastActive = (data['lastActive'] as Timestamp).toDate();
          }
        }
      }

      /// 🔥 INCREMENT ACTIVITY
      weekly[today] = (weekly[today] ?? 0) + 1;

      /// 🔥 STREAK LOGIC
      int newStreak = user.value?.streak ?? 0;

      if (lastActive != null) {
        final lastDate =
            DateTime(lastActive.year, lastActive.month, lastActive.day);

        final difference = todayDate.difference(lastDate).inDays;

        if (difference == 1) {
          newStreak += 1;
        } else if (difference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      /// SAVE ACTIVITY
      await docRef.set({
        'weekly': weekly,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      /// UPDATE USER
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'streak': newStreak});

      /// LOCAL UPDATE
      if (user.value != null) {
        user.value = user.value!.copyWith(streak: newStreak);
      }

      /// 🔥 REFRESH UI DATA
      await _loadWeeklyActivity(userId);

    } catch (e) {
      print("Activity Error: $e");
    }
  }

  /// ================= HELPERS =================
  double getProgress(String courseId) =>
      progressMap[courseId] ?? 0;

  double get xpProgress {
    final currentXP = user.value?.xp ?? 0;
    return (currentXP / 3500).clamp(0.0, 1.0);
  }

  /// ================= REFRESH =================
  Future<void> refreshProgress() async {
    await loadAllProgress();
  }

  /// ================= EXPORT (FR-3 REQ-4) =================
  final ExportService _exportService = ExportService();
  final RxBool isExporting = false.obs;

  /// Exports the current student's own progress summary (courses + quizzes).
  Future<String?> exportMyProgressCsv() async {
    try {
      isExporting.value = true;
      final u = user.value;
      final headers = ['Type', 'Name', 'Detail', 'Value', 'Date'];
      final rows = <List<String>>[];

      if (u != null) {
        rows.add(['Summary', u.name, 'XP', u.xp.toString(), '']);
        rows.add(['Summary', u.name, 'Level', u.level.toString(), '']);
        rows.add(['Summary', u.name, 'Streak (days)', u.streak.toString(), '']);
      }

      for (final c in courses) {
        final pct = ((progressMap[c.id] ?? 0) * 100).toStringAsFixed(1);
        rows.add(['Course', '${c.code} ${c.title}', 'Completion %', pct, '']);
      }

      for (final q in quizResults) {
        final ts = q['date'];
        final dateStr = ts is Timestamp
            ? ts.toDate().toIso8601String()
            : (ts?.toString() ?? '');
        rows.add([
          'Quiz',
          q['quizName']?.toString() ?? 'Quiz',
          'Score',
          '${q['score']}/${q['total']}',
          dateStr,
        ]);
      }

      final path = await _exportService.exportCsv(
        fileName:
            'progress_${DateTime.now().millisecondsSinceEpoch}',
        headers: headers,
        rows: rows,
      );
      return path;
    } finally {
      isExporting.value = false;
    }
  }

  /// Teachers only: exports per-student performance across all students
  /// who submitted quiz attempts. Columns: student, quiz, score, %, date.
  Future<String?> exportTeacherAnalyticsCsv() async {
    try {
      isExporting.value = true;

      final attemptsSnap = await firebaseProvider.quizAttempts().get();
      final quizCache = <String, String>{};
      final userCache = <String, String>{};

      final rows = <List<String>>[];
      for (final doc in attemptsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final quizId = data['quizId']?.toString() ?? '';
        final userId = data['userId']?.toString() ?? '';

        var quizTitle = quizCache[quizId];
        if (quizTitle == null && quizId.isNotEmpty) {
          final q = await firebaseProvider.quizzes().doc(quizId).get();
          quizTitle = q.exists ? (q['title']?.toString() ?? 'Quiz') : 'Quiz';
          quizCache[quizId] = quizTitle;
        }

        var userName = userCache[userId];
        if (userName == null && userId.isNotEmpty) {
          final u = await firebaseProvider.users().doc(userId).get();
          userName = u.exists ? (u['name']?.toString() ?? userId) : userId;
          userCache[userId] = userName;
        }

        final score = data['score']?.toString() ?? '0';
        final total = data['totalQuestions']?.toString() ?? '0';
        final pct = data['percentage']?.toString() ?? '';
        final ts = data['submittedAt'];
        final date = ts is Timestamp
            ? ts.toDate().toIso8601String()
            : (ts?.toString() ?? '');

        rows.add([
          userName ?? userId,
          quizTitle ?? 'Quiz',
          '$score/$total',
          pct,
          date,
        ]);
      }

      final path = await _exportService.exportCsv(
        fileName:
            'teacher_analytics_${DateTime.now().millisecondsSinceEpoch}',
        headers: ['Student', 'Quiz', 'Score', 'Percentage', 'Submitted'],
        rows: rows,
      );
      return path;
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> openExportedFile(String path) =>
      _exportService.openFile(path);
}