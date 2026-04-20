import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/assignment_controller.dart';

class GradeSubmissionsView extends GetView<AssignmentController> {
  final String assignmentId;

  const GradeSubmissionsView({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    controller.fetchSubmissionsByAssignment(assignmentId);
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Grade Submissions"), backgroundColor: Colors.transparent, elevation: 0),
      body: Obx(() {
        if (controller.submissions.isEmpty) {
          return Center(child: Text("No submissions yet", style: TextStyle(color: textColor?.withValues(alpha: 0.7))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.submissions.length,
          itemBuilder: (context, index) {
            final sub = controller.submissions[index];
            final marksController = TextEditingController(text: sub.marks?.toString() ?? "");
            final feedbackController = TextEditingController(text: sub.feedback);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Student: ${sub.userId}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(sub.answer, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: marksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Marks"),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: feedbackController, decoration: const InputDecoration(labelText: "Feedback")),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final marks = int.tryParse(marksController.text);
                      if (marks == null) {
                        Get.snackbar("Error", "Enter valid marks");
                        return;
                      }
                      controller.gradeSubmission(
                        submissionId: sub.id,
                        marks: marks,
                        feedback: feedbackController.text,
                      );
                    },
                    child: const Text("Grade"),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
