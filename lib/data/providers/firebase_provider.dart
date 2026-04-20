import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseProvider {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // REGISTER
  Future<UserCredential> register(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGIN
  Future<UserCredential> login(String email, String password) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await auth.signOut();
  }

  User? get currentUser => auth.currentUser;

  CollectionReference users() {
    return firestore.collection('users');
  }

  CollectionReference courses() {
    return firestore.collection('courses');
  }

  CollectionReference assignments() {
    return firestore.collection('assignments');
  }

  CollectionReference quizzes() {
    return firestore.collection('quizzes');
  }

  CollectionReference materials() {
    return firestore.collection('materials');
  }

  CollectionReference groups() {
    return firestore.collection('groups');
  }

  CollectionReference groupThreads(String groupId) {
    return firestore.collection('groups').doc(groupId).collection('threads');
  }

  CollectionReference threadReplies(String groupId, String threadId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('threads')
        .doc(threadId)
        .collection('replies');
  }

  CollectionReference groupMessages(String groupId) {
    return firestore.collection('groups').doc(groupId).collection('messages');
  }

 

  CollectionReference materialViews() {
    return firestore.collection('material_views');
  }

  CollectionReference quizAttempts() {
    return firestore.collection('quiz_attempts');
  }

  CollectionReference assignmentSubmissions() {
    return firestore.collection('assignment_submissions');
  }

  Reference storageRef(String path) {
    return storage.ref().child(path);
  }

  Future<String> uploadFile({
    required String path,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = storage.ref().child("$path/$fileName");

    final uploadTask = await ref.putData(bytes);

    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  }
}
