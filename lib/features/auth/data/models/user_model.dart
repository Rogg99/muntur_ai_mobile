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
  String? token;

  UserModel();

  static UserModel create({
    required String id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String? token,
  }) {
    final m = UserModel();
    m.id = id;
    m.username = username;
    m.email = email;
    m.firstName = firstName;
    m.lastName = lastName;
    m.token = token;
    return m;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.create(
      id: json['id'] ?? '',
      username: json['username'] ?? json['email'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      token: json['token'],
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? token,
  }) {
    return UserModel.create(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
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
      token: entity.token,
    );
  }
}
