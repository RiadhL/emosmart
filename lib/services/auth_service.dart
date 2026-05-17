import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserProfile?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchProfile(cred.user!.uid);
  }

  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = UserProfile(uid: cred.user!.uid, name: name, age: age);
    await _db.child('users/${cred.user!.uid}').set(profile.toMap());
    await cred.user!.sendEmailVerification();
    return profile;
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserProfile?> getProfile(String uid) => _fetchProfile(uid);

  Future<UserProfile?> _fetchProfile(String uid) async {
    final snap = await _db.child('users/$uid').get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(snap.value as Map);
  }
}
