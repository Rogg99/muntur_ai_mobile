import 'dart:convert';

class Token {
  final int id = 1;
  late String refresh;
  late String access;
  late String email;
  late String password;
  late double time;

  Token({
    required this.refresh,
    required this.access,
    required this.email,
    required this.password,
    required this.time,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      email: json['email']??'',
      password: json['password']??'',
      access: json['data']['token'],
      refresh: json['data']['refresh']??'',
      time: json['time']??0,
    );
  }

  factory Token.fromJson2(Map<String, dynamic> json) {
    return Token(
      email: json['email'],
      password: json['password'],
      refresh: json['refresh'],
      access: json['access'],
      time: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'access': access,
      'refresh': refresh,
      'email': email,
      'password': password,
      'time': time,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

}
