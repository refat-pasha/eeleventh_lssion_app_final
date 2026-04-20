import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/progress_controller.dart';

class ProgressView extends GetView<ProgressController> {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.user.value;

          return RefreshIndicator(
            onRefresh: controller.refreshProgress,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                Text(
                  "Progress & Analytics",
                  style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  "Your academic performance overview",
                  style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                ),

                const SizedBox(height: 16),

                Obx(() {
                  final role = controller.user.value?.role ?? 'student';
                  final isTeacher = role == 'teacher' || role == 'admin';
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isExporting.value
                              ? null
                              : () async {
                                  final path =
                                      await controller.exportMyProgressCsv();
                                  if (path != null) {
                                    Get.snackbar("Exported", "Saved: $path",
                                        duration: const Duration(seconds: 3));
                                    await controller.openExportedFile(path);
                                  } else {
                                    Get.snackbar(
                                        "Export failed", "Could not write CSV");
                                  }
                                },
                          icon: const Icon(Icons.download),
                          label: const Text("Export My Progress (CSV)"),
                        ),
                      ),
                      if (isTeacher) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.isExporting.value
                                ? null
                                : () async {
                                    final path = await controller
                                        .exportTeacherAnalyticsCsv();
                                    if (path != null) {
                                      Get.snackbar(
                                          "Exported", "Saved: $path",
                                          duration:
                                              const Duration(seconds: 3));
                                      await controller.openExportedFile(path);
                                    } else {
                                      Get.snackbar("Export failed",
                                          "Could not write CSV");
                                    }
                                  },
                            icon: const Icon(Icons.bar_chart),
                            label: const Text("Teacher Analytics"),
                          ),
                        ),
                      ],
                    ],
                  );
                }),

                const SizedBox(height: 16),

                Text(
                  "Course Milestones",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 16),

                controller.courses.isEmpty
                    ? Text("No courses found", style: TextStyle(color: textColor?.withValues(alpha: 0.7)))
                    : GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: controller.courses.map((course) {
                          final progress = controller.getProgress(course.id);
                          return milestoneCard(progress, course.code, course.title, cardColor, textColor);
                        }).toList(),
                      ),

                const SizedBox(height: 30),

                Text(
                  "Recent Quiz Results",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 12),

                Obx(() {
                  if (controller.quizResults.isEmpty) {
                    return Text("No quiz attempts yet", style: TextStyle(color: textColor?.withValues(alpha: 0.7)));
                  }

                  return Column(
                    children: controller.quizResults.map((quiz) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
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
                                    quiz['quizName'] ?? "Quiz",
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Score: ${quiz['score']}/${quiz['total'] ?? ''}",
                                    style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 30),

                Text(
                  "Weekly Activity",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 12),

                Obx(() => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: controller.weeklyActivity.map((value) {
                          return bar(value / 10);
                        }).toList(),
                      ),
                    )),

                const SizedBox(height: 30),

                Text(
                  "XP & Level",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${user?.xp ?? 0} / 3500 XP",
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Lv. ${user?.level ?? 1} • Scholar",
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: controller.xpProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Keep going to level up!",
                        style: TextStyle(color: textColor?.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget milestoneCard(double progress, String code, String title, Color cardColor, Color? textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school, color: textColor),
          const SizedBox(height: 10),
          Text(
            "${(progress * 100).toInt()}%",
            style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text("$code • $title", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white12),
        ],
      ),
    );
  }

  Widget bar(double height) {
    return Container(
      width: 18,
      height: 80 * height,
      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(6)),
    );
  }
}
