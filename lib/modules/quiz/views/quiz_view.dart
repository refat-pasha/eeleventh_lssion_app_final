import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/quiz_controller.dart';
import '../widgets/question_card.dart';
import '../widgets/option_tile.dart';
import '../views/add_question_view.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.isQuizStarted.value ? "Quiz" : "Available Quizzes"),
                if (controller.isQuizStarted.value)
                  Text(
                    _formatTime(controller.remainingSeconds.value),
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
              ],
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.isQuizStarted.value) {
              controller.exitQuiz();
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showCreateQuizDialog),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isQuizStarted.value) {
          return _quizListView(theme.cardColor, textColor);
        }

        if (controller.questions.isEmpty) {
          return Center(
            child: Text("No questions available", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
          );
        }

        if (controller.quizFinished.value) {
          return _resultView(textColor);
        }

        final question = controller.questions[controller.currentIndex.value];
        final selected = controller.answers[controller.currentIndex.value];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Question ${controller.currentIndex.value + 1} / ${controller.questions.length}",
                style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              QuestionCard(question: question.question),
              const SizedBox(height: 20),
              ...List.generate(question.options.length, (index) {
                return OptionTile(
                  text: question.options[index],
                  selected: selected == index,
                  onTap: () => controller.selectAnswer(index),
                );
              }),
              const Spacer(),
              Row(
                children: [
                  if (controller.currentIndex.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.previousQuestion,
                        child: const Text("Previous"),
                      ),
                    ),
                  if (controller.currentIndex.value > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.nextQuestion,
                      child: Text(
                        controller.currentIndex.value == controller.questions.length - 1 ? "Finish" : "Next",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "⏱️ ${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Widget _quizListView(Color cardColor, Color? textColor) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('quizzes').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final quizzes = snapshot.data!.docs;

        if (quizzes.isEmpty) {
          return Center(child: Text("No quizzes available", style: TextStyle(color: textColor?.withValues(alpha: 0.7))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final data = quiz.data();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.quiz, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? "Quiz",
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['description'] ?? "",
                          style: TextStyle(color: textColor?.withValues(alpha: 0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.startQuiz(quiz.id, durationMinutes: data['durationMinutes'] ?? 10),
                    child: const Text("Start"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateQuizDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Create Quiz"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Quiz Title")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final doc = await FirebaseFirestore.instance.collection('quizzes').add({
                "title": titleController.text.trim(),
                "description": descController.text.trim(),
                "durationMinutes": 10,
                "createdAt": FieldValue.serverTimestamp(),
              });
              Get.back();
              Get.to(() => AddQuestionView(quizId: doc.id));
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _resultView(Color? textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Quiz Completed 🎉",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          Obx(() => Text(
                "Score: ${controller.score.value} / ${controller.questions.length}",
                style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
              )),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: controller.restartQuiz, child: const Text("Retry Quiz")),
          const SizedBox(height: 10),
          TextButton(onPressed: controller.exitQuiz, child: const Text("Back to Quiz List")),
        ],
      ),
    );
  }
}
