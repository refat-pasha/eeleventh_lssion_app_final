// placeholder
// lib/modules/profile/views/settings_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          _settingsTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            trailing: Switch(value: true, onChanged: (value) {}),
            cardColor: cardColor,
            textColor: textColor,
          ),
          _settingsTile(
            icon: Icons.notifications,
            title: "Notifications",
            trailing: Switch(value: true, onChanged: (value) {}),
            cardColor: cardColor,
            textColor: textColor,
          ),
          _settingsTile(
            icon: Icons.language,
            title: "Language",
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor?.withValues(alpha: 0.54)),
            onTap: () {},
            cardColor: cardColor,
            textColor: textColor,
          ),
          const SizedBox(height: 20),
          _settingsTile(
            icon: Icons.info_outline,
            title: "About App",
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor?.withValues(alpha: 0.54)),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("11th Lesson"),
                  content: const Text("Version 1.0.0\n\nAn LMS platform for fast learning and collaboration."),
                  actions: [TextButton(onPressed: Get.back, child: const Text("Close"))],
                ),
              );
            },
            cardColor: cardColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap, required Color cardColor, required Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
