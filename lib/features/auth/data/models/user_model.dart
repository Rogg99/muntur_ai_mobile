import 'package:isar/isar.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@Collection()
class UserModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id = '';

  @Index(unique: true, replace: true)
  String username = '';

  String email = '';
  String? firstName;
  String? lastName;
  String? phone;
  String? photo;
  String? ville;
  String? pays;
  String? dateNaissance;
  String? sexe;
  String? token;

  UserModel();

  static UserModel create({
    required String id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    String? photo,
    String? ville,
    String? pays,
    String? dateNaissance,
    String? sexe,
    String? token,
  }) {
    final m = UserModel();
    m.id = id;
    m.username = username;
    m.email = email;
    m.firstName = firstName;
    m.lastName = lastName;
    m.phone = phone;
    m.photo = photo;
    m.ville = ville;
    m.pays = pays;
    m.dateNaissance = dateNaissance;
    m.sexe = sexe;
    m.token = token;
    return m;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.create(
      id: json['id'] ?? '',
      username: json['username'] ?? json['email'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? json['prenom'],
      lastName: json['last_name'] ?? json['lastName'] ?? json['nom'],
      phone: json['telephone'] ?? json['phone'],
      photo: json['photo'],
      ville: json['ville'],
      pays: json['pays'],
      dateNaissance: json['date_naissance'] ?? json['dateNaissance'],
      sexe: json['sexe'],
      token: json['token'],
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? photo,
    String? ville,
    String? pays,
    String? dateNaissance,
    String? sexe,
    String? token,
  }) {
    return UserModel.create(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      ville: ville ?? this.ville,
      pays: pays ?? this.pays,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      sexe: sexe ?? this.sexe,
      token: token ?? this.token,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      photo: photo,
      ville: ville,
      pays: pays,
      dateNaissance: dateNaissance,
      sexe: sexe,
      token: token,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel.create(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      photo: entity.photo,
      ville: entity.ville,
      pays: entity.pays,
      dateNaissance: entity.dateNaissance,
      sexe: entity.sexe,
      token: entity.token,
    );
  }
}
