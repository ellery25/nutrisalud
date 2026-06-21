/// Authenticated session state. Token itself lives only in secure storage;
/// it is loaded on demand by repositories that need it.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.username,
    required this.displayName,
  });

  final String userId;
  final String username;
  final String displayName;

  AuthSession copyWith({String? displayName}) => AuthSession(
        userId: userId,
        username: username,
        displayName: displayName ?? this.displayName,
      );
}
