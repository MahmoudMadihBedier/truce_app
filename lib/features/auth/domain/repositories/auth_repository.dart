import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser> get user;
  AuthUser get currentUser;
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<Result<AuthUser>> logInWithEmail({
    required String email,
    required String password,
  });
  Future<Result<AuthUser>> logInWithGoogle();
  Future<Result<AuthUser>> logInAnonymously();
  Future<Result<void>> logOut();
  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  });
  Future<Result<AuthUser>> logInWithPhone({
    required String verificationId,
    required String smsCode,
  });
  Future<Result<void>> resetPassword({required String email});
}
