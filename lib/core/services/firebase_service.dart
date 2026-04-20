// placeholder
// lib/core/services/firebase_service.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService extends GetxService {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;

  Future<FirebaseService> init() async {
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    return this;
  }

  // ---------- AUTH ----------
  User? get currentUser => auth.currentUser;

  Stream<User?> authStateChanges() {
    return auth.authStateChanges();
  }

  // ---------- FIRESTORE ----------
  CollectionReference usersCollection() {
    return firestore.collection('users');
  }

  CollectionReference coursesCollection() {
    return firestore.collection('courses');
  }

  CollectionReference assignmentsCollection() {
    return firestore.collection('assignments');
  }

  CollectionReference quizzesCollection() {
    return firestore.collection('quizzes');
  }

  CollectionReference materialsCollection() {
    return firestore.collection('materials');
  }

  CollectionReference groupsCollection() {
    return firestore.collection('groups');
  }

  // ---------- STORAGE ----------
  Reference storageRef(String path) {
    return storage.ref().child(path);
  }

  Future<String> uploadFile({
    required String path,
    required String filePath,
  }) async {
    final ref = storage.ref().child(path);

    final uploadTask = await ref.putFile(
      Uri.file(filePath).toFilePath() as dynamic,
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}