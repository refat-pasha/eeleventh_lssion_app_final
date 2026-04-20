// lib/data/repositories/course_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/course_model.dart';
import '../providers/firebase_provider.dart';

class CourseRepository {
  final FirebaseProvider _firebaseProvider;

  CourseRepository(this._firebaseProvider);

  CollectionReference get _courseRef =>
      _firebaseProvider.courses();

  // Create Course
  Future<void> createCourse(CourseModel course) async {
    await _courseRef.add(course.toMap());
  }

  // Get All Courses
  Future<List<CourseModel>> getCourses() async {
    final snapshot = await _courseRef.get();

    final all = snapshot.docs.map((doc) {

      final data = doc.data();

      if (data == null) {
        return CourseModel.fromMap({}, doc.id);
      }

      return CourseModel.fromMap(
        Map<String, dynamic>.from(data as Map),
        doc.id,
      );

    }).toList();

    /// Dedupe by course code (case-insensitive) — Firestore may contain duplicates
    final seen = <String>{};
    return all.where((c) {
      final key = c.code.trim().toLowerCase();
      if (key.isEmpty) return true;
      return seen.add(key);
    }).toList();
  }

  // Get Course By ID
  Future<CourseModel?> getCourseById(String courseId) async {
    final doc = await _courseRef.doc(courseId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null) return null;

    return CourseModel.fromMap(
      Map<String, dynamic>.from(data as Map),
      doc.id,
    );
  }

  // Get Courses By Teacher
  Future<List<CourseModel>> getCoursesByTeacher(String teacherId) async {
    final snapshot =
        await _courseRef.where("teacherId", isEqualTo: teacherId).get();

    return snapshot.docs.map((doc) {

      final data = doc.data();

      if (data == null) {
        return CourseModel.fromMap({}, doc.id);
      }

      return CourseModel.fromMap(
        Map<String, dynamic>.from(data as Map),
        doc.id,
      );

    }).toList();
  }

  // Update Course
  Future<void> updateCourse(CourseModel course) async {
    await _courseRef.doc(course.id).update(course.toMap());
  }

  // Delete Course
  Future<void> deleteCourse(String courseId) async {
    await _courseRef.doc(courseId).delete();
  }
}