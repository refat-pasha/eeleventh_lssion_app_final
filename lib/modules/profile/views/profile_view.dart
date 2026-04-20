import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../app/routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

          final user = controller.user.value;

          if (user == null) {
            return Center(child: Text("No profile found", style: TextStyle(color: textColor?.withValues(alpha: 0.7))));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _tag(user.role.toUpperCase()),
                          if ((user.department ?? '').trim().isNotEmpty)
                            _tag(user.department!.trim()),
                          if ((user.university ?? '').trim().isNotEmpty)
                            _tag(user.university!.trim()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(user.enrolledCourses.length.toString(), "COURSES", cardColor, textColor),
                  _statCard(user.streak.toString(), "STREAK", cardColor, textColor),
                  _statCard("${user.xp}", "XP", cardColor, textColor),
                ],
              ),

              const SizedBox(height: 20),

              _sectionTitle("Academic Details", textColor),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _row("University", user.university ?? "-", textColor),
                    _row("Department", user.department ?? "-", textColor),
                    _row("Semester", user.semester ?? "-", textColor),
                    _row("Subjects", user.subjects.isEmpty ? "-" : user.subjects.join(" • "), textColor),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle("Settings", textColor),

              _menuTile(icon: Icons.settings, title: "Account Settings", subtitle: "Security, preferences", onTap: () => Get.toNamed(Routes.accountSettings), cardColor: cardColor, textColor: textColor),
              _menuTile(icon: Icons.school, title: "Academic Profile", subtitle: "University, department, subjects", onTap: () => Get.toNamed(Routes.academicProfile), cardColor: cardColor, textColor: textColor),
              _menuTile(icon: Icons.dark_mode, title: "Appearance", subtitle: "Theme & display", onTap: () => Get.toNamed(Routes.appearance), cardColor: cardColor, textColor: textColor),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: controller.logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                child: const Text("Sign Out"),
              ),

              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statCard(String value, String label, Color cardColor, Color? textColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: textColor?.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _row(String title, String value, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
          Text(value, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _menuTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required Color cardColor, required Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        subtitle: Text(subtitle, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor?.withValues(alpha: 0.54)),
      ),
    );
  }
}
