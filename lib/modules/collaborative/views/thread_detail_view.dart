import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/colors.dart';
import '../controllers/collaborative_controller.dart';

/// Forum thread detail screen showing the original post and replies.
/// (FR-6 REQ-4)
class ThreadDetailView extends StatefulWidget {
  const ThreadDetailView({super.key});

  @override
  State<ThreadDetailView> createState() => _ThreadDetailViewState();
}

class _ThreadDetailViewState extends State<ThreadDetailView> {
  final TextEditingController _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String groupId = args['groupId'] ?? '';
    final String threadId = args['threadId'] ?? '';
    final String title = args['threadTitle'] ?? 'Thread';
    final String body = args['threadBody'] ?? '';
    final String author = args['authorName'] ?? '';
    final controller = Get.find<CollaborativeController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Discussion"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("by $author",
                    style: const TextStyle(
                        color: Colors.blueAccent, fontSize: 12)),
                const SizedBox(height: 10),
                Text(body,
                    style: TextStyle(
                        color: textColor?.withValues(alpha: 0.85))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: controller.watchReplies(groupId, threadId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final replies = snap.data!;
                if (replies.isEmpty) {
                  return Center(
                      child: Text("No replies yet. Be the first!",
                          style: TextStyle(
                              color:
                                  textColor?.withValues(alpha: 0.6))));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: replies.length,
                  itemBuilder: (_, i) {
                    final r = replies[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r.authorName,
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                DateFormat('MMM d, HH:mm')
                                    .format(r.createdAt),
                                style: TextStyle(
                                    color: textColor?.withValues(
                                        alpha: 0.5),
                                    fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(r.body,
                              style: TextStyle(color: textColor)),
                        ],
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              color: cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      decoration: const InputDecoration(
                          hintText: "Reply...",
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: AppColors.primary),
                    onPressed: () async {
                      final text = _replyCtrl.text.trim();
                      if (text.isEmpty) return;
                      await controller.addReply(
                          groupId: groupId,
                          threadId: threadId,
                          body: text);
                      _replyCtrl.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
