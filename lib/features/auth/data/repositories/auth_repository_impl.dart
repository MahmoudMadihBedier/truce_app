import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:truce_app/core/error/failures.dart';
import 'package:truce_app/core/error/result.dart';
import 'package:truce_app/features/auth/domain/entities/auth_user.dart';
import 'package:truce_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AuthUser> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? AuthUser.empty : firebaseUser.toUser;
      return user;
    });
  }

  @override
  AuthUser get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser == null ? AuthUser.empty : firebaseUser.toUser;
  }

  @override
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }
      return Result.success(credential.user!.toUser);
    } on FirebaseAuthException catch (e) {
      return Result.error(AuthFailure(e.message ?? 'Sign up failed'));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> logInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential.user!.toUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Result.error(const AuthFailure('Invalid email or password'));
      }
      return Result.error(AuthFailure(e.message ?? 'Login failed'));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return Result.success(null);
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> logInWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Result.success(userCredential.user!.toUser);
    } on FirebaseAuthException catch (e) {
      return Result.error(AuthFailure(e.message ?? 'Phone Login failed'));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(AuthFailure(e.message ?? 'Password reset failed'));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> logInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Result.error(const AuthFailure('Google sign in cancelled'));

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Result.success(userCredential.user!.toUser);
    } on FirebaseAuthException catch (e) {
      return Result.error(AuthFailure(e.message ?? 'Google Login failed'));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> logInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return Result.success(userCredential.user!.toUser);
    } on FirebaseAuthException catch (e) {
      return Result.error(AuthFailure(e.message ?? 'Guest login failed'));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return Result.success(null);
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }
}

extension on User {
  AuthUser get toUser {
    return AuthUser(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoURL,
      phoneNumber: phoneNumber,
      isGuest: isAnonymous,
    );
  }
}
