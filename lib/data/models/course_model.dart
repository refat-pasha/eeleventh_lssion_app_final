// lib/data/models/course_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String code;
  final String description;
  final String teacherId;
  final String? thumbnail;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.teacherId,
    this.thumbnail,
    required this.createdAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic>? map, String id) {
    if (map == null) {
      return CourseModel(
        id: id,
        title: '',
        code: '',
        description: '',
        teacherId: '',
        thumbnail: '',
        createdAt: DateTime.now(),
      );
    }

    return CourseModel(
      id: id,
      title: map['title']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      teacherId: map['teacherId']?.toString() ?? '',
      thumbnail: map['thumbnail']?.toString(),

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "code": code,
      "description": description,
      "teacherId": teacherId,
      "thumbnail": thumbnail ?? '',
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}