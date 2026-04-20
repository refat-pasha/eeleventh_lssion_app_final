import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/collaborative_controller.dart';
import '../../../app/theme/colors.dart';
import 'group_detail_view.dart';

class StudyGroupsView extends GetView<CollaborativeController> {
  const StudyGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Study Groups"), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateGroupDialog(userId),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final groups = snapshot.data!.docs;

          if (groups.isEmpty) {
            return Center(child: Text("No study groups available", style: TextStyle(color: textColor?.withValues(alpha: 0.7))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final data = group.data();
              final members = List<String>.from(data['members'] ?? []);
              final isJoined = members.contains(userId);

              return GestureDetector(
                onTap: isJoined
                    ? () => Get.to(() => const GroupDetailView(), arguments: {
                          'groupId': group.id,
                          'groupName': data['name'] ?? 'Group',
                        })
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "Group",
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(data['subject'] ?? "", style: const TextStyle(color: Colors.blueAccent, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(data['description'] ?? "", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${members.length} members",
                            style: TextStyle(color: textColor?.withValues(alpha: 0.6), fontSize: 12),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isJoined)
                                IconButton(
                                  tooltip: "Open",
                                  icon: const Icon(Icons.forum, color: Colors.blueAccent),
                                  onPressed: () => Get.to(() => const GroupDetailView(), arguments: {
                                    'groupId': group.id,
                                    'groupName': data['name'] ?? 'Group',
                                  }),
                                ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isJoined ? Colors.grey : Colors.blueAccent,
                                ),
                                onPressed: isJoined ? null : () => controller.joinGroup(group.id, userId!),
                                child: Text(isJoined ? "Joined" : "Join"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog(String? userId) {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Create Study Group"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Group Name")),
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: "Subject")),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (userId == null) return;
              await FirebaseFirestore.instance.collection('groups').add({
                "name": nameController.text.trim(),
                "subject": subjectController.text.trim(),
                "description": descriptionController.text.trim(),
                "createdBy": userId,
                "members": [userId],
                "createdAt": FieldValue.serverTimestamp(),
              });
              Get.back();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
