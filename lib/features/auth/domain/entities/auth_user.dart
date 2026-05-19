import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isGuest;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.isGuest = false,
  });

  static const empty = AuthUser(id: '');

  bool get isEmpty => this == AuthUser.empty;
  bool get isNotEmpty => this != AuthUser.empty;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, phoneNumber, isGuest];
}
