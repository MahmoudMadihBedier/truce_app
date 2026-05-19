import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.unknown()) {
    _authRepository.user.listen((user) {
      if (user.isEmpty) {
        emit(const AuthState.unauthenticated());
      } else {
        emit(AuthState.authenticated(user));
      }
    });
  }

  Future<void> logInWithGoogle() async {
    final result = await _authRepository.logInWithGoogle();
    if (result.isError) {
      // Handled by UI or separate error state if needed
    }
  }

  Future<void> logInAnonymously() async {
    await _authRepository.logInAnonymously();
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  Future<void> logInWithPhone(String verificationId, String smsCode) async {
    final result = await _authRepository.logInWithPhone(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (result.isError) {
      // Handle error
    }
  }

  Future<void> logOut() async {
    await _authRepository.logOut();
  }
}
