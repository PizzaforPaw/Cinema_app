import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Current Firebase user (null if not logged in)
  static User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (login/logout)
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email, password, and name
  /// Returns null on success, or an error message string on failure
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user profile in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': 'user', // Default role, admin sets manually in Firestore
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update display name
      await cred.user!.updateDisplayName(name.trim());

      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  /// Login with email and password
  /// Returns null on success, or an error message string on failure
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  /// Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get the current user's role from Firestore
  static Future<String> getUserRole() async {
    if (currentUser == null) return 'user';
    try {
      final doc = await _db.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return doc.get('role') ?? 'user';
      }
    } catch (_) {}
    return 'user';
  }

  /// Get the current user's profile data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    try {
      final doc = await _db.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (_) {}
    return null;
  }

  /// Send password reset email
  static Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  /// Map Firebase error codes to Vietnamese messages
  static String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Sai mật khẩu.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng đợi một lát.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      default:
        return 'Đã xảy ra lỗi ($code). Vui lòng thử lại.';
    }
  }
}