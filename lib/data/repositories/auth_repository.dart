import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../providers/firebase_provider.dart';

class AuthRepository {
  final FirebaseProvider firebaseProvider;

  AuthRepository(this.firebaseProvider);

  User? get currentUser => firebaseProvider.auth.currentUser;

  // ================= LOGIN =================
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    return await firebaseProvider.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ================= REGISTER =================
  Future<UserCredential?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential =
        await firebaseProvider.auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    return credential;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await firebaseProvider.auth.signOut();
  }

  // ================= SAVE USER PROFILE =================
  Future<void> saveUserProfile(UserModel user) async {
    await firebaseProvider.users().doc(user.id).set(user.toMap());
  }

  // ================= GET USER PROFILE =================
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await firebaseProvider.users().doc(uid).get();

    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data() as Map<String, dynamic>;

    return UserModel.fromMap(data, doc.id);
  }
}