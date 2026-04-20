import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/question_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/providers/firebase_provider.dart';
import '../../progress/controllers/progress_controller.dart';

class QuizController extends GetxController {
  late QuizRepository _quizRepository;

  /// ================= STATE =================
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool quizFinished = false.obs;
  final RxBool isQuizStarted = false.obs;

  final RxMap<int, int> answers = <int, int>{}.obs;

  /// 🔥 TIMER
  final RxInt remainingSeconds = 0.obs;
  Timer? _timer;

  String quizId = 'demo_quiz';

  /// 🔥 PREVENT MULTIPLE SAVE
  bool _isSaving = false;

  @override
  void onInit() {
    super.onInit();

    _quizRepository = QuizRepository(Get.find<FirebaseProvider>());

    final args = Get.arguments;
    if (args != null && args['quizId'] != null) {
      quizId = args['quizId'];
    }
  }

  /// ================= START QUIZ =================
  Future<void> startQuiz(String id, {int durationMinutes = 10}) async {
    quizId = id;

    currentIndex.value = 0;
    score.value = 0;
    answers.clear();
    quizFinished.value = false;

    isQuizStarted.value = true;

    await loadQuestions();

    /// START TIMER
    startTimer(durationMinutes);
  }

  /// ================= TIMER =================
  void startTimer(int minutes) {
    _timer?.cancel();

    remainingSeconds.value = minutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();

        /// AUTO SUBMIT
        finishQuiz();

        Get.snackbar(
          "Time Up ⏱️",
          "Quiz submitted automatically",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  /// ================= LOAD QUESTIONS =================
  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;

      final data = await _quizRepository.getQuestionsByQuiz(quizId);
      questions.assignAll(data);

      if (data.isEmpty) {
        Get.snackbar("No Quiz Found", "No questions available");
      }

    } catch (e) {
      Get.snackbar("Quiz Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= SELECT ANSWER =================
  void selectAnswer(int optionIndex) {
    answers[currentIndex.value] = optionIndex;
  }

  /// ================= NEXT =================
  void nextQuestion() {
    if (!answers.containsKey(currentIndex.value)) {
      Get.snackbar("Answer Required", "Please select an answer");
      return;
    }

    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    } else {
      finishQuiz();
    }
  }

  /// ================= PREVIOUS =================
  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  /// ================= FINISH =================
  Future<void> finishQuiz() async {
    _timer?.cancel();

    if (quizFinished.value) return; // 🔥 prevent duplicate

    int total = 0;

    answers.forEach((qi, selected) {
      if (questions[qi].correctIndex == selected) {
        total++;
      }
    });

    score.value = total;
    quizFinished.value = true;

    await _saveQuizResult();
  }

  /// ================= SAVE RESULT =================
  Future<void> _saveQuizResult() async {
    if (_isSaving) return;
    _isSaving = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;

      /// SAVE RESULT
      await FirebaseFirestore.instance.collection('quiz_attempts').add({
        'userId': userId,
        'quizId': quizId,
        'score': score.value,
        'totalQuestions': questions.length,
        'percentage':
            ((score.value / questions.length) * 100).toInt(),
        'submittedAt': FieldValue.serverTimestamp(),
      });

      /// UPDATE XP
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'xp': FieldValue.increment(50),
      });

      /// UPDATE ACTIVITY + STREAK
      await Get.find<ProgressController>().updateWeeklyActivity();

    } catch (e) {
      print("Quiz Save Error: $e");
    } finally {
      _isSaving = false;
    }
  }

  /// ================= RESTART =================
  void restartQuiz() {
    _timer?.cancel();

    currentIndex.value = 0;
    score.value = 0;
    answers.clear();
    quizFinished.value = false;

    /// restart timer
    startTimer(10);
  }

  /// ================= EXIT =================
  void exitQuiz() {
    _timer?.cancel();

    isQuizStarted.value = false;
    quizFinished.value = false;
    currentIndex.value = 0;
    answers.clear();
    questions.clear();
  }

  /// ================= CLEANUP =================
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}