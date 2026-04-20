// lib/modules/collaborative/controllers/collaborative_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/models/group_model.dart';
import '../../../data/models/thread_model.dart';
import '../../../data/models/group_message_model.dart';
import '../../../data/providers/firebase_provider.dart';

class CollaborativeController extends GetxController {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();

  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchGroups();
    super.onInit();
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;

      final snapshot = await _firebaseProvider.groups().get();

      final data = snapshot.docs.map((doc) {
        return GroupModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      groups.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGroup(GroupModel group) async {
    try {
      await _firebaseProvider.groups().add(group.toMap());
      fetchGroups();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      final doc = await _firebaseProvider.groups().doc(groupId).get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['members'] ?? []);

      if (!members.contains(userId)) {
        members.add(userId);

        await _firebaseProvider.groups().doc(groupId).update({
          "members": members,
        });
      }

      fetchGroups();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      final doc = await _firebaseProvider.groups().doc(groupId).get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['members'] ?? []);

      members.remove(userId);

      await _firebaseProvider.groups().doc(groupId).update({
        "members": members,
      });

      fetchGroups();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _firebaseProvider.groups().doc(groupId).delete();
      fetchGroups();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ===================== FR-6 REQ-6: MEMBER MANAGEMENT =====================
  Future<void> removeMember(String groupId, String memberId) async {
    try {
      final doc = await _firebaseProvider.groups().doc(groupId).get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['members'] ?? []);
      members.remove(memberId);
      await _firebaseProvider.groups().doc(groupId).update({"members": members});
      fetchGroups();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ===================== FR-6 REQ-4: DISCUSSION FORUM =====================
  Stream<List<ThreadModel>> watchThreads(String groupId) {
    return _firebaseProvider
        .groupThreads(groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ThreadModel.fromMap(
                d.data() as Map<String, dynamic>, d.id, groupId))
            .toList());
  }

  Future<void> createThread({
    required String groupId,
    required String title,
    required String body,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String authorName = user.displayName ?? user.email ?? 'Anonymous';
    try {
      final userDoc =
          await _firebaseProvider.users().doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        authorName = data['name']?.toString() ?? authorName;
      }
    } catch (_) {}

    await _firebaseProvider.groupThreads(groupId).add({
      'title': title,
      'body': body,
      'authorId': user.uid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'replyCount': 0,
    });
  }

  Stream<List<ReplyModel>> watchReplies(String groupId, String threadId) {
    return _firebaseProvider
        .threadReplies(groupId, threadId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                ReplyModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> addReply({
    required String groupId,
    required String threadId,
    required String body,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String authorName = user.displayName ?? user.email ?? 'Anonymous';
    try {
      final userDoc =
          await _firebaseProvider.users().doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        authorName = data['name']?.toString() ?? authorName;
      }
    } catch (_) {}

    final replies = _firebaseProvider.threadReplies(groupId, threadId);
    final threadRef = _firebaseProvider.groupThreads(groupId).doc(threadId);

    final batch = _firebaseProvider.firestore.batch();
    batch.set(replies.doc(), {
      'body': body,
      'authorId': user.uid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(threadRef, {'replyCount': FieldValue.increment(1)});
    await batch.commit();
  }

  /// ===================== FR-6 REQ-5: GROUP MESSAGING =====================
  Stream<List<GroupMessageModel>> watchMessages(String groupId) {
    return _firebaseProvider
        .groupMessages(groupId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GroupMessageModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
    bool isAnnouncement = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;
    String senderName = user.displayName ?? user.email ?? 'User';
    try {
      final userDoc =
          await _firebaseProvider.users().doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        senderName = data['name']?.toString() ?? senderName;
      }
    } catch (_) {}

    await _firebaseProvider.groupMessages(groupId).add({
      'senderId': user.uid,
      'senderName': senderName,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isAnnouncement': isAnnouncement,
    });
  }
}