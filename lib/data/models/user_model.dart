import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  final String? avatarUrl;

  final List<String> enrolledCourses;
  final List<String> subjects;

  final String? university;
  final String? department;
  final String? semester;

  final DateTime createdAt;

  final int xp;
  final int level; // ✅ ADDED
  final int streak;
  final List<String> achievements;

  final int totalCourse; // optional but kept

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.enrolledCourses = const [],
    this.subjects = const [],
    this.university,
    this.department,
    this.semester,
    required this.createdAt,
    this.xp = 0,
    this.level = 1, // ✅ DEFAULT
    this.streak = 0,
    this.achievements = const [],
    this.totalCourse = 0, // ✅ SAFE DEFAULT
  });

  /// ================= FROM MAP =================
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      avatarUrl: map['avatarUrl'],

      enrolledCourses:
          List<String>.from(map['enrolledCourses'] ?? []),

      subjects: List<String>.from(map['subjects'] ?? []),

      university: map['university'],
      department: map['department'],
      semester: map['semester'],

      /// 🔥 HANDLE TIMESTAMP + STRING
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString()) ??
                  DateTime.now()
              : DateTime.now(),

      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1, // ✅ ADDED
      streak: map['streak'] ?? 0,
      achievements:
          List<String>.from(map['achievements'] ?? []),

      totalCourse: map['totalCourse'] ??
          (map['enrolledCourses'] != null
              ? (map['enrolledCourses'] as List).length
              : 0), // ✅ AUTO FALLBACK
    );
  }

  /// ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "role": role,
      "avatarUrl": avatarUrl,
      "enrolledCourses": enrolledCourses,
      "subjects": subjects,
      "university": university,
      "department": department,
      "semester": semester,

      /// 🔥 STORE AS TIMESTAMP
      "createdAt": Timestamp.fromDate(createdAt),

      "xp": xp,
      "level": level, // ✅ ADDED
      "streak": streak,
      "achievements": achievements,

      "totalCourse": totalCourse,
    };
  }

  /// ================= COPY WITH =================
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    List<String>? enrolledCourses,
    List<String>? subjects,
    String? university,
    String? department,
    String? semester,
    DateTime? createdAt,
    int? xp,
    int? level,
    int? streak,
    List<String>? achievements,
    int? totalCourse,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      subjects: subjects ?? this.subjects,
      university: university ?? this.university,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      achievements: achievements ?? this.achievements,
      totalCourse: totalCourse ?? this.totalCourse,
    );
  }
}