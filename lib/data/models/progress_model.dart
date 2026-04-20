// lib/app/data/models/progress_model.dart

class ProgressModel {
  final String userId;

  /// Course progress → {courseId: progress}
  final Map<String, double> courseProgress;

  /// XP & Level
  final int xp;
  final int level;

  /// Weekly Activity (Mon → Sun)
  final List<int> weeklyActivity;

  /// Recent Quiz Results
  final List<QuizResultModel> quizResults;

  ProgressModel({
    required this.userId,
    required this.courseProgress,
    required this.xp,
    required this.level,
    required this.weeklyActivity,
    required this.quizResults,
  });

  /// ================= FROM FIRESTORE =================
  factory ProgressModel.fromMap(Map<String, dynamic> map, String userId) {
    return ProgressModel(
      userId: userId,

      courseProgress: Map<String, double>.from(
        (map['courseProgress'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),

      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,

      weeklyActivity: List<int>.from(
        map['weeklyActivity'] ?? [0, 0, 0, 0, 0, 0, 0],
      ),

      quizResults: (map['quizResults'] as List<dynamic>? ?? [])
          .map((e) => QuizResultModel.fromMap(e))
          .toList(),
    );
  }

  /// ================= TO FIRESTORE =================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseProgress': courseProgress,
      'xp': xp,
      'level': level,
      'weeklyActivity': weeklyActivity,
      'quizResults': quizResults.map((e) => e.toMap()).toList(),
    };
  }

  /// ================= COPY WITH =================
  ProgressModel copyWith({
    Map<String, double>? courseProgress,
    int? xp,
    int? level,
    List<int>? weeklyActivity,
    List<QuizResultModel>? quizResults,
  }) {
    return ProgressModel(
      userId: userId,
      courseProgress: courseProgress ?? this.courseProgress,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      quizResults: quizResults ?? this.quizResults,
    );
  }
}

/// ================= QUIZ RESULT MODEL =================
class QuizResultModel {
  final String quizName;
  final int score;
  final int total;
  final DateTime? date;

  QuizResultModel({
    required this.quizName,
    required this.score,
    required this.total,
    this.date,
  });

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      quizName: map['quizName'] ?? "Quiz",
      score: map['score'] ?? 0,
      total: map['total'] ?? 0,
      date: map['date'] != null
          ? (map['date'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizName': quizName,
      'score': score,
      'total': total,
      'date': date,
    };
  }
}