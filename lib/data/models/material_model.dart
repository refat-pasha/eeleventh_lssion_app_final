// placeholder
// lib/data/models/material_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String uploadedBy;
  final String fileUrl;
  final String fileType;
  final bool isPublic;
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.uploadedBy,
    required this.fileUrl,
    required this.fileType,
    required this.isPublic,
    required this.createdAt,
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return MaterialModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseId: map['courseId'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      isPublic: map['isPublic'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "courseId": courseId,
      "uploadedBy": uploadedBy,
      "fileUrl": fileUrl,
      "fileType": fileType,
      "isPublic": isPublic,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}