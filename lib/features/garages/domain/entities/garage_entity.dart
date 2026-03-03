class GarageEntity {
  final String id;
  final String nom;
  final String description;
  final String email;
  final String telephone1;
  final String telephone2;
  final String photo;
  final String ville;
  final String pays;
  final String type;
  final String heureOuverture;
  final String heureFermeture;
  final double latitude;
  final double longitude;
  final double rating;
  final double distance;
  final String medias; // JSON array as string

  const GarageEntity({
    required this.id,
    required this.nom,
    this.description = '',
    this.email = '',
    this.telephone1 = '',
    this.telephone2 = '',
    this.photo = '',
    this.ville = '',
    this.pays = '',
    this.type = 'garage',
    this.heureOuverture = '08:00',
    this.heureFermeture = '18:00',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.rating = 0.0,
    this.distance = 0.0,
    this.medias = '[]',
  });
}
