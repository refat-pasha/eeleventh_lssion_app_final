import 'package:cloud_firestore/cloud_firestore.dart';

class ThreadModel {
  final String id;
  final String groupId;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int replyCount;

  ThreadModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.replyCount = 0,
  });

  factory ThreadModel.fromMap(
      Map<String, dynamic> map, String id, String groupId) {
    return ThreadModel(
      id: id,
      groupId: groupId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      replyCount: map['replyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': FieldValue.serverTimestamp(),
        'replyCount': replyCount,
      };
}

class ReplyModel {
  final String id;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  ReplyModel({
    required this.id,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory ReplyModel.fromMap(Map<String, dynamic> map, String id) {
    return ReplyModel(
      id: id,
      body: map['body'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'body': body,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
