import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/colors.dart';
import '../controllers/collaborative_controller.dart';
import 'thread_detail_view.dart';

/// Group detail screen with three tabs:
///   1. Forum    (FR-6 REQ-4)
///   2. Chat     (FR-6 REQ-5)
///   3. Members  (FR-6 REQ-6)
class GroupDetailView extends StatelessWidget {
  const GroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String groupId = args['groupId'] ?? '';
    final String groupName = args['groupName'] ?? 'Group';
    final CollaborativeController controller = Get.find();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(groupName),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.forum), text: "Forum"),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: "Chat"),
              Tab(icon: Icon(Icons.group), text: "Members"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ForumTab(groupId: groupId, controller: controller),
            _ChatTab(
              groupId: groupId,
              controller: controller,
              currentUid: currentUid,
            ),
            _MembersTab(
              groupId: groupId,
              controller: controller,
              currentUid: currentUid,
            ),
          ],
        ),
      ),
    );
  }
}

/// ================================ FORUM ================================
class _ForumTab extends StatelessWidget {
  const _ForumTab({required this.groupId, required this.controller});
  final String groupId;
  final CollaborativeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("New thread"),
        onPressed: () => _showCreateThreadDialog(context),
      ),
      body: StreamBuilder(
        stream: controller.watchThreads(groupId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final threads = snap.data!;
          if (threads.isEmpty) {
            return Center(
              child: Text("No threads yet. Start a discussion!",
                  style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (_, i) {
              final t = threads[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(t.title,
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${t.authorName} • ${t.replyCount} replies",
                    style: TextStyle(
                        color: textColor?.withValues(alpha: 0.7)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.to(() => const ThreadDetailView(),
                      arguments: {
                        'groupId': groupId,
                        'threadId': t.id,
                        'threadTitle': t.title,
                        'threadBody': t.body,
                        'authorName': t.authorName,
                      }),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateThreadDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("New Thread"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title")),
            TextField(
              controller: bodyCtrl,
              maxLines: 4,
              decoration:
                  const InputDecoration(labelText: "What's on your mind?"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              final body = bodyCtrl.text.trim();
              if (title.isEmpty) return;
              await controller.createThread(
                  groupId: groupId, title: title, body: body);
              Get.back();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }
}

/// ================================ CHAT ================================
class _ChatTab extends StatefulWidget {
  const _ChatTab({
    required this.groupId,
    required this.controller,
    required this.currentUid,
  });
  final String groupId;
  final CollaborativeController controller;
  final String? currentUid;

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _announce = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: widget.controller.watchMessages(widget.groupId),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final msgs = snap.data!;
              if (msgs.isEmpty) {
                return Center(
                    child: Text("No messages yet",
                        style: TextStyle(
                            color: textColor?.withValues(alpha: 0.7))));
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) {
                  _scroll.animateTo(
                      _scroll.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut);
                }
              });
              return ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final mine = m.senderId == widget.currentUid;
                  final bg = m.isAnnouncement
                      ? Colors.orange.withValues(alpha: 0.2)
                      : mine
                          ? AppColors.primary.withValues(alpha: 0.8)
                          : cardColor;
                  return Align(
                    alignment: mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!mine)
                            Text(m.senderName,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent)),
                          if (m.isAnnouncement)
                            const Text("📢 Announcement",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          Text(m.text,
                              style: TextStyle(
                                  color: mine ? Colors.white : textColor)),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('HH:mm').format(m.createdAt),
                            style: TextStyle(
                                fontSize: 9,
                                color: (mine ? Colors.white : textColor)
                                    ?.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: cardColor,
            child: Row(
              children: [
                IconButton(
                  tooltip: _announce
                      ? "Announcement mode ON"
                      : "Send as announcement",
                  icon: Icon(
                    Icons.campaign,
                    color: _announce ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _announce = !_announce),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    await widget.controller.sendMessage(
      groupId: widget.groupId,
      text: text,
      isAnnouncement: _announce,
    );
    _msgCtrl.clear();
    setState(() => _announce = false);
  }
}

/// ================================ MEMBERS ================================
class _MembersTab extends StatelessWidget {
  const _MembersTab({
    required this.groupId,
    required this.controller,
    required this.currentUid,
  });
  final String groupId;
  final CollaborativeController controller;
  final String? currentUid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data!.data() as Map<String, dynamic>? ?? {};
        final members = List<String>.from(data['members'] ?? []);
        final createdBy = data['createdBy']?.toString() ?? '';
        final isAdmin = currentUid == createdBy;

        if (members.isEmpty) {
          return Center(
              child: Text("No members yet",
                  style: TextStyle(
                      color: textColor?.withValues(alpha: 0.7))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (_, i) {
            final memberId = members[i];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(memberId)
                  .get(),
              builder: (context, userSnap) {
                final userData = (userSnap.data?.data()
                        as Map<String, dynamic>?) ??
                    {};
                final name = userData['name']?.toString() ?? memberId;
                final role = userData['role']?.toString() ?? 'student';
                final isCreator = memberId == createdBy;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style:
                              const TextStyle(color: Colors.white)),
                    ),
                    title: Text(name, style: TextStyle(color: textColor)),
                    subtitle: Text(
                      isCreator ? "$role • Creator" : role,
                      style: TextStyle(
                          color: textColor?.withValues(alpha: 0.7)),
                    ),
                    trailing: (isAdmin && !isCreator)
                        ? IconButton(
                            icon: const Icon(Icons.person_remove,
                                color: Colors.red),
                            onPressed: () =>
                                _confirmRemove(context, memberId, name),
                          )
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, String memberId, String name) {
    Get.dialog(
      AlertDialog(
        title: const Text("Remove member?"),
        content: Text("Remove $name from this group?"),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await controller.removeMember(groupId, memberId);
              Get.back();
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }
}
