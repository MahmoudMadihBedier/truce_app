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

  Future<void> logInWithEmail(String email, String password) async {
    emit(const AuthState.loading());
    final result = await _authRepository.logInWithEmail(email: email, password: password);
    if (result.isError) {
      emit(AuthState.error(result.failure!.message));
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    emit(const AuthState.loading());
    final result = await _authRepository.signUp(email: email, password: password, displayName: displayName);
    if (result.isError) {
      emit(AuthState.error(result.failure!.message));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(const AuthState.loading());
    final result = await _authRepository.resetPassword(email: email);
    if (result.isError) {
      emit(AuthState.error(result.failure!.message));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> logInWithGoogle() async {
    emit(const AuthState.loading());
    final result = await _authRepository.logInWithGoogle();
    if (result.isError) {
      emit(AuthState.error(result.failure!.message));
    }
  }

  Future<void> logInAnonymously() async {
    emit(const AuthState.loading());
    final result = await _authRepository.logInAnonymously();
    if (result.isError) {
      emit(AuthState.error(result.failure!.message));
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    emit(const AuthState.loading());
    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (id) {
        emit(const AuthState.unauthenticated());
        onCodeSent(id);
      },
      onError: (err) {
        emit(AuthState.error(err));
        onError(err);
      },
    );
  }

  Future<void> logInWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(const AuthState.loading());
    final result = await _authRepository.logInWithPhone(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (result.isError) {
      emit(AuthState.error(result.failure!.message));
    }
  }

  Future<void> logOut() async {
    await _authRepository.logOut();
  }
}
