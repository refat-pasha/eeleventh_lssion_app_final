import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../providers/firebase_provider.dart';

class QuizRepository {
  final FirebaseProvider _firebaseProvider;

  QuizRepository(this._firebaseProvider);

  /// ================= REFERENCES =================
  CollectionReference get _quizRef => _firebaseProvider.quizzes();

  /// ================= QUIZ =================

  Future<String> createQuiz(QuizModel quiz) async {
    final doc = await _quizRef.add(quiz.toMap());
    return doc.id; // ✅ return quizId
  }

  Future<List<QuizModel>> getQuizzes() async {
    final snapshot = await _quizRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return QuizModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  Future<List<QuizModel>> getQuizzesByCourse(String courseId) async {
    final snapshot = await _quizRef
        .where("courseId", isEqualTo: courseId)
        .get();

    return snapshot.docs.map((doc) {
      return QuizModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    await _quizRef.doc(quiz.id).update(quiz.toMap());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _quizRef.doc(quizId).delete();
  }

  /// ================= QUESTIONS (SUBCOLLECTION) =================

  CollectionReference _questionRef(String quizId) =>
      _quizRef.doc(quizId).collection('questions');

  /// ADD QUESTION
  Future<void> addQuestion(String quizId, QuestionModel question) async {
    await _questionRef(quizId).add(question.toMap());
  }

  /// GET QUESTIONS BY QUIZ
  Future<List<QuestionModel>> getQuestionsByQuiz(String quizId) async {
    final snapshot = await _questionRef(quizId)
        .orderBy('createdAt')
        .get();

    return snapshot.docs.map((doc) {
      return QuestionModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  /// UPDATE QUESTION
  Future<void> updateQuestion(
      String quizId, QuestionModel question) async {
    await _questionRef(quizId)
        .doc(question.id)
        .update(question.toMap());
  }

  /// DELETE QUESTION
  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _questionRef(quizId).doc(questionId).delete();
  }
}