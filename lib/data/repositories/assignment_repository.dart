// lib/data/repositories/assignment_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_model.dart';
import '../providers/firebase_provider.dart';

class AssignmentRepository {
  final FirebaseProvider _firebaseProvider;

  AssignmentRepository(this._firebaseProvider);

  CollectionReference get _assignmentRef =>
      _firebaseProvider.assignments();

  // Create Assignment
  Future<void> createAssignment(AssignmentModel assignment) async {
    await _assignmentRef.add(assignment.toMap());
  }

  // Get All Assignments
  Future<List<AssignmentModel>> getAssignments() async {
    final snapshot = await _assignmentRef.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      if (data == null) {
        return AssignmentModel.fromMap({}, doc.id);
      }

      return AssignmentModel.fromMap(
        Map<String, dynamic>.from(data as Map),
        doc.id,
      );
    }).toList();
  }

  // Get Assignments by Course
  Future<List<AssignmentModel>> getAssignmentsByCourse(String courseId) async {
    final snapshot =
        await _assignmentRef.where("courseId", isEqualTo: courseId).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      if (data == null) {
        return AssignmentModel.fromMap({}, doc.id);
      }

      return AssignmentModel.fromMap(
        Map<String, dynamic>.from(data as Map),
        doc.id,
      );
    }).toList();
  }

  // Update Assignment
  Future<void> updateAssignment(AssignmentModel assignment) async {
    await _assignmentRef
        .doc(assignment.id)
        .update(assignment.toMap());
  }

  // Delete Assignment
  Future<void> deleteAssignment(String assignmentId) async {
    await _assignmentRef.doc(assignmentId).delete();
  }
}