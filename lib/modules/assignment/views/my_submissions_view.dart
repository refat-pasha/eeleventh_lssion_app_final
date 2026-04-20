import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/assignment_controller.dart';

class MySubmissionsView extends GetView<AssignmentController> {
  const MySubmissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchMySubmissions();
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("My Submissions"), backgroundColor: Colors.transparent, elevation: 0),
      body: Obx(() {
        if (controller.submissions.isEmpty) {
          return Center(child: Text("No submissions yet", style: TextStyle(color: textColor?.withValues(alpha: 0.7))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.submissions.length,
          itemBuilder: (context, index) {
            final sub = controller.submissions[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Assignment: ${sub.assignmentId}",
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sub.status == "graded"
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          sub.status.toUpperCase(),
                          style: TextStyle(
                            color: sub.status == "graded" ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(sub.answer, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                  const SizedBox(height: 10),
                  Text(
                    "Marks: ${sub.marks ?? 'Pending'}",
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Feedback: ${sub.feedback.isEmpty ? 'Not yet' : sub.feedback}",
                    style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
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
