// lib/data/models/assignment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String title;
  final String description;

  final String? courseId;   // ✅ FIXED (optional)
  final String? fileUrl;
  final String? createdBy;

  final DateTime dueDate;
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    this.courseId,     // ✅ optional
    this.fileUrl,
    this.createdBy,
    required this.dueDate,
    required this.createdAt,
  });

  /// ================= FROM FIRESTORE =================
  factory AssignmentModel.fromMap(Map<String, dynamic>? map, String id) {
    if (map == null) {
      return AssignmentModel(
        id: id,
        title: '',
        description: '',
        courseId: null,
        fileUrl: null,
        createdBy: null,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }

    return AssignmentModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',

      /// ✅ OPTIONAL FIELDS
      courseId: map['courseId']?.toString(),
      fileUrl: map['fileUrl']?.toString(),
      createdBy: map['createdBy']?.toString(),

      /// ✅ SAFE DATE HANDLING
      dueDate: map['dueDate'] is Timestamp
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['dueDate']?.toString() ?? '') ??
              DateTime.now(),

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  /// ================= TO FIRESTORE =================
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "courseId": courseId ?? '',
      "fileUrl": fileUrl ?? '',
      "createdBy": createdBy ?? '',
      "dueDate": Timestamp.fromDate(dueDate),
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}