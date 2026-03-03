class UserEntity {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? photo;
  final String? ville;
  final String? pays;
  final String? dateNaissance;
  final String? sexe;
  final String? token;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.photo,
    this.ville,
    this.pays,
    this.dateNaissance,
    this.sexe,
    this.token,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
