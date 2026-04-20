// lib/app/data/models/question_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String quizId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.createdAt,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      quizId: map['quizId'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'],

      /// 🔥 FIXED (handles Timestamp + String)
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt']) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "quizId": quizId,
      "question": question,
      "options": options,
      "correctIndex": correctIndex,
      "explanation": explanation,

      /// 🔥 BEST PRACTICE (store as Timestamp)
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }
}