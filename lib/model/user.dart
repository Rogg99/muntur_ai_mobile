import 'dart:convert';


class User {
  String id;
  String nom;
  String prenom;
  String sexe;
  String date_naissance;
  String telephone;
  String email;
  String password;
  String photo;
  String type;
  String ville;
  String pays;

  User({
    this.id = "",
    this.nom = "none",
    this.prenom = "none",
    this.sexe = "none",
    this.date_naissance = "",
    this.telephone = "none",
    this.email = "none",
    this.password = "none",
    this.photo = "none",
    this.type = "user",
    this.ville = "none",
    this.pays = "CAMEROUN",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id : json["id"],
      nom : json["nom"]??'none',
      prenom : json["prenom"]??'none',
      sexe : json["sexe"]??'none',
      date_naissance : json["date_naissance"]??'none',
      telephone : json["telephone"]??'none',
      email : json["email"]??'none',
      photo : json["photo"]??'none',
      type : json["type"]??'user',
      ville : json["ville"]??'none',
      pays : json["pays"]??'none',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'nom' : nom,
      'prenom' : prenom,
      'sexe' : sexe,
      'date_naissance' : date_naissance,
      'telephone' : telephone,
      'email' : email,
      'photo' : photo,
      'type' : type,
      'ville' : ville,
      'pays' : pays,
    };
  }

  Map<String, dynamic> toMap2() {
    return {
      'id' : id,
      'nom' : nom,
      'prenom' : prenom,
      'sexe' : sexe,
      'date_naissance' : date_naissance,
      'telephone' : telephone,
      'email' : email,
      'password' : password,
      "username": email,
      "last_name": "$nom $prenom",
      'photo' : photo,
      'type' : type,
      'ville' : ville,
      'pays' : pays,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

  String toJson2() {
    return json.encode(this.toMap2());
  }
}
