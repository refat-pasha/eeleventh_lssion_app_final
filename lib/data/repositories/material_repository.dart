// placeholder
// lib/data/repositories/material_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/material_model.dart';
import '../providers/firebase_provider.dart';

class MaterialRepository {
  final FirebaseProvider _firebaseProvider;

  MaterialRepository(this._firebaseProvider);

  CollectionReference get _materialRef =>
      _firebaseProvider.materials();

  // Create Material
  Future<void> uploadMaterial(MaterialModel material) async {
    await _materialRef.add(material.toMap());
  }

  // Get All Materials
  Future<List<MaterialModel>> getMaterials() async {
    final snapshot = await _materialRef.get();

    return snapshot.docs.map((doc) {
      return MaterialModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Get Materials by Course
  Future<List<MaterialModel>> getMaterialsByCourse(String courseId) async {
    final snapshot =
        await _materialRef.where("courseId", isEqualTo: courseId).get();

    return snapshot.docs.map((doc) {
      return MaterialModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Get Public Materials
  Future<List<MaterialModel>> getPublicMaterials() async {
    final snapshot =
        await _materialRef.where("isPublic", isEqualTo: true).get();

    return snapshot.docs.map((doc) {
      return MaterialModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Update Material
  Future<void> updateMaterial(MaterialModel material) async {
    await _materialRef.doc(material.id).update(material.toMap());
  }

  // Delete Material
  Future<void> deleteMaterial(String materialId) async {
    await _materialRef.doc(materialId).delete();
  }
}