class UserEntity {
  final String id;
  final String email;
  final bool emailVerified;
  final String? name;
  final String? displayName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.emailVerified,
    this.name,
    this.displayName,
  });
}
