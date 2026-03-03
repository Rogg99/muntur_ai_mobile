import 'package:isar/isar.dart';

part 'garage_model.g.dart';

@Collection()
class GarageModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id = '';

  String nom = '';
  String description = '';
  String email = '';
  String telephone1 = '';
  String telephone2 = '';
  String photo = '';
  String ville = '';
  String pays = '';
  String type = 'garage';
  String heureOuverture = '08:00';
  String heureFermeture = '18:00';
  double latitude = 0.0;
  double longitude = 0.0;
  double rating = 0.0;
  double distance = 0.0;

  /// JSON array of photo URLs (stored as string)
  String medias = '[]';

  /// Whether this record needs an API refresh
  bool stale = false;

  GarageModel();

  factory GarageModel.fromJson(Map<String, dynamic> json) {
    final g = GarageModel();
    g.id = json['id']?.toString() ?? '';
    g.nom = json['nom'] ?? '';
    g.description = json['description'] ?? '';
    g.email = json['email'] ?? '';
    g.telephone1 = json['telephone1'] ?? '';
    g.telephone2 = json['telephone2'] ?? '';
    g.photo = json['photo'] ?? '';
    g.ville = json['ville'] ?? '';
    g.pays = json['pays'] ?? '';
    g.type = json['type'] ?? 'garage';
    g.heureOuverture = json['heure_ouverture'] ?? '08:00';
    g.heureFermeture = json['heure_fermeture'] ?? '18:00';
    g.latitude = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    g.longitude = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    g.rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    g.distance = (json['distance'] as num?)?.toDouble() ?? 0.0;
    final rawMedias = json['medias'];
    g.medias = rawMedias is List
        ? rawMedias.toString()
        : (rawMedias?.toString() ?? '[]');
    return g;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'description': description,
        'email': email,
        'telephone1': telephone1,
        'telephone2': telephone2,
        'photo': photo,
        'ville': ville,
        'pays': pays,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'distance': distance,
        'medias': medias,
      };
}
