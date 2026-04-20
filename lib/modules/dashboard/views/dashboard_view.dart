import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../../app/routes/app_routes.dart';
import 'offline_library_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

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
            onRefresh: controller.refreshDashboard,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                /// 🔥 HEADER
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      "Good afternoon, ${user?.name ?? "User"} 👋",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(user?.name[0] ?? "U"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔥 STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard("🔥", "${user?.streak ?? 0}", "Streak", cardColor, textColor),
                    _statCard("⚡", "${user?.xp ?? 0}", "XP", cardColor, textColor),
                    _statCard("🏅", "4", "Badges", cardColor, textColor),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔥 COURSES (teacher = My Courses, student = Continue Learning)
                Row(
                  children: [
                    Text(
                      controller.isTeacher ? "My Courses" : "Continue Learning",
                      style: TextStyle(color: textColor),
                    ),
                    const Spacer(),
                    if (controller.isTeacher)
                      IconButton(
                        tooltip: "Create course",
                        icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                        onPressed: () => _showCreateCourseDialog(context),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                controller.courses.isEmpty
                    ? _emptyCard(
                        Icons.school,
                        controller.isTeacher
                            ? "You don't teach any courses yet 📚"
                            : "Enroll in courses to start learning 🎓",
                        cardColor,
                        textColor,
                      )
                    : SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.courses.length,
                          itemBuilder: (context, index) {
                            final course = controller.courses[index];
                            return _learningCard(
                              title: course.title,
                              code: course.code,
                              isTeacher: controller.isTeacher,
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 20),

                /// 🔥 RECOMMENDED
                Text("Recommended for You", style: TextStyle(color: textColor)),

                const SizedBox(height: 10),

                controller.recommendedMaterials.isEmpty
                    ? _emptyCard(Icons.lightbulb, "Start studying to unlock recommendations 🚀", cardColor, textColor)
                    : Column(
                        children: controller.recommendedMaterials.map((item) {
                          final data = item.data();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    data['title'] ?? "Material",
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 20),

                /// 🔥 QUICK ACCESS
                Text("Quick Access", style: TextStyle(color: textColor)),

                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _quickCard("🎯", "Quiz", () => Get.toNamed(Routes.quiz), cardColor, textColor),
                    _quickCard("📊", "Progress", () => Get.toNamed(Routes.progress), cardColor, textColor),
                    _quickCard("📁", "Offline", () => Get.to(() => const OfflineLibraryView()), cardColor, textColor),
                    _quickCard("📝", "Assignments", () => Get.toNamed(Routes.assignment), cardColor, textColor),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _statCard(String icon, String value, String label, Color cardColor, Color? textColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _learningCard({
    required String title,
    required String code,
    required bool isTeacher,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code.toUpperCase(), style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(children: [
            Text(isTeacher ? "Manage" : "Resume",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 14, color: Colors.white70),
          ]),
        ],
      ),
    );
  }

  Widget _emptyCard(IconData icon, String text, Color cardColor, Color? textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: textColor?.withValues(alpha: 0.7)))),
        ],
      ),
    );
  }

  void _showCreateCourseDialog(BuildContext context) {
    final titleCtl = TextEditingController();
    final codeCtl = TextEditingController();
    final descCtl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Create Course"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtl, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: codeCtl, decoration: const InputDecoration(labelText: "Code (e.g. CSE101)")),
              TextField(controller: descCtl, maxLines: 2, decoration: const InputDecoration(labelText: "Description")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await controller.createCourse(
                title: titleCtl.text,
                code: codeCtl.text,
                description: descCtl.text,
              );
              Get.back();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(String icon, String title, VoidCallback onTap, Color cardColor, Color? textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
