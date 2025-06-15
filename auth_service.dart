import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges().map((user) => 
    user != null ? User(uid: user.uid, email: user.email ?? '') : null);

  Future<User> signUpWithEmail(
    String email,
    String password,
    String name,
    int age,
    double weight,
    double height,
    String fitnessGoal,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'age': age,
        'weight': weight,
        'height': height,
        'fitnessGoal': fitnessGoal,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return User(
        uid: userCredential.user!.uid,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastSignInTime': FieldValue.serverTimestamp(),
      });

      return User(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}
