part of 'auth_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, unknown, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser user;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user = AuthUser.empty,
    this.errorMessage,
  });

  const AuthState.authenticated(AuthUser user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
