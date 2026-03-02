class UserEntity {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? token;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.token,
  });
}
