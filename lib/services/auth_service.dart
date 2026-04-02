import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

/// Service class for Firebase Authentication operations
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  /// Sign up a new user with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        avatarUrl: '',
        role: 'parent', // Default role
        fcmToken: '',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await _firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Reset password by email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // ── Web: Use Firebase Auth's built-in Google popup ──
        // google_sign_in 7.x does NOT support authenticate() on web,
        // so we bypass the plugin entirely and use Firebase Auth directly.
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // ── Mobile / Desktop: Use google_sign_in plugin ──
        if (!_isGoogleInitialized) {
          await _googleSignIn.initialize();
          _isGoogleInitialized = true;
        }

        final googleUser = await _googleSignIn.authenticate();
        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      // Check if user is new, and create a Firestore document if so
      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user?.email ?? '',
          displayName: userCredential.user?.displayName ?? 'Google User',
          avatarUrl: userCredential.user?.photoURL ?? '',
          role: 'parent',
          fcmToken: '',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await _firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      }
      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Send Phone Auth OTP
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
         // Auto retrieval or instant validation (only on android sometimes)
         await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  /// Verify OTP and sign in
  Future<UserCredential> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Check if user is new
      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: '', // Phone auth might not have email
          displayName: 'Phone User',
          avatarUrl: '',
          role: 'parent',
          fcmToken: '',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await _firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      }

      return userCredential;
    } catch (e) {
      throw Exception('Invalid OTP. Please try again.');
    }
  }

  /// Get current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Update FCM token for the current user
  Future<void> updateFcmToken(String token) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        await _firebaseFirestore
            .collection('users')
            .doc(userId)
            .update({'fcmToken': token});
      }
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Update user last active timestamp
  Future<void> updateLastActive() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        await _firebaseFirestore
            .collection('users')
            .doc(userId)
            .update({'lastActive': Timestamp.now()});
      }
    } catch (e) {
      throw Exception('Failed to update last active: $e');
    }
  }

  /// Auth-gated profile update — demonstrates the security pattern required
  /// by Firestore rules: request.auth.uid == uid.
  ///
  /// This will throw a [FirebaseException] with PERMISSION_DENIED if:
  ///   - The user is not signed in, or
  ///   - The uid does not match the signed-in user's UID.
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? bio,
  }) async {
    // Guard: must be authenticated and operating on own document
    final currentUid = _firebaseAuth.currentUser?.uid;
    if (currentUid == null) throw Exception('Not authenticated');
    if (currentUid != uid) throw Exception('Permission denied');

    final updates = <String, dynamic>{
      'lastActive': Timestamp.now(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (bio != null) updates['bio'] = bio;

    try {
      await _firebaseFirestore.collection('users').doc(uid).update(updates);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }

  /// Handle Firebase Auth exceptions and return a user-friendly Exception
  Exception _handleAuthException(FirebaseAuthException e) {
    final message = switch (e.code) {
      'weak-password' => 'The password provided is too weak.',
      'email-already-in-use' => 'An account already exists for that email.',
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' => 'The user account has been disabled.',
      'user-not-found' => 'No user found for that email.',
      'wrong-password' => 'Wrong password provided.',
      'invalid-credential' => 'Invalid email or password.',
      'operation-not-allowed' => 'Email/password accounts are not enabled.',
      _ => 'Authentication error: ${e.message}',
    };
    return Exception(message);
  }
}
