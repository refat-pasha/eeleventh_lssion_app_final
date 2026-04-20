// lib/app/data/models/quiz_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String title;
  final String courseId;
  final String createdBy;
  final int durationMinutes;
  final int totalQuestions;
  final bool allowRetake;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.createdBy,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.allowRetake,
    required this.createdAt,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    return QuizModel(
      id: id,
      title: map['title'] ?? '',
      courseId: map['courseId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      allowRetake: map['allowRetake'] ?? true,

      /// 🔥 FIXED (handles both Timestamp & String)
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt']) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "courseId": courseId,
      "createdBy": createdBy,
      "durationMinutes": durationMinutes,
      "totalQuestions": totalQuestions,
      "allowRetake": allowRetake,

      /// 🔥 BEST PRACTICE (store as Timestamp)
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}