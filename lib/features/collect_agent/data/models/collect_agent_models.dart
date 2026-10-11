/// Mirrors api/apps/api's CollectAgentProfileReadSerializer /
/// PanneCaseSubmissionReadSerializer / GarageSubmissionReadSerializer as
/// relayed by the backend session (c7, 2026-10-11) after checking
/// serializers.py/viewsets.py directly — not an indicative summary.
/// Verified deployed (migration 0018_collectagentprofile_pannecasesubmission_and_more,
/// confirmed by 90).
library;

class MediaRef {
  final String id;
  final String file;
  final String kind;

  const MediaRef({required this.id, required this.file, this.kind = 'unknown'});

  factory MediaRef.fromJson(Map<String, dynamic> json) => MediaRef(
        id: json['id']?.toString() ?? '',
        file: json['file']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'unknown',
      );
}

double? _parseDecimalOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class CollectAgentProfile {
  final String id;
  final String status; // pending | approved | rejected
  final String? rejectionReason;
  final String? reviewedAt;
  final MediaRef? cniFront;
  final MediaRef? cniBack;
  final MediaRef? selfieFace;
  final MediaRef? selfieLeft;
  final MediaRef? selfieRight;
  final String dateCreation;

  const CollectAgentProfile({
    required this.id,
    this.status = 'pending',
    this.rejectionReason,
    this.reviewedAt,
    this.cniFront,
    this.cniBack,
    this.selfieFace,
    this.selfieLeft,
    this.selfieRight,
    this.dateCreation = '',
  });

  static MediaRef? _media(dynamic json) =>
      json is Map ? MediaRef.fromJson(json.cast<String, dynamic>()) : null;

  factory CollectAgentProfile.fromJson(Map<String, dynamic> json) =>
      CollectAgentProfile(
        id: json['id'].toString(),
        status: json['status']?.toString() ?? 'pending',
        rejectionReason: json['rejection_reason']?.toString(),
        reviewedAt: json['reviewed_at']?.toString(),
        cniFront: _media(json['cni_front']),
        cniBack: _media(json['cni_back']),
        selfieFace: _media(json['selfie_face']),
        selfieLeft: _media(json['selfie_left']),
        selfieRight: _media(json['selfie_right']),
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}

class PanneCaseSubmission {
  final String id;
  final String vehicle;
  final String type;
  final String description;
  final String reparation;
  final String ville;
  final double? submissionLatitude;
  final double? submissionLongitude;
  final String status; // pending | approved | rejected
  final String? rejectionReason;
  final String? promotedCaseId;
  final String dateCreation;

  const PanneCaseSubmission({
    required this.id,
    this.vehicle = '',
    this.type = '',
    this.description = '',
    this.reparation = '',
    this.ville = '',
    this.submissionLatitude,
    this.submissionLongitude,
    this.status = 'pending',
    this.rejectionReason,
    this.promotedCaseId,
    this.dateCreation = '',
  });

  factory PanneCaseSubmission.fromJson(Map<String, dynamic> json) =>
      PanneCaseSubmission(
        id: json['id'].toString(),
        vehicle: json['vehicle']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        reparation: json['reparation']?.toString() ?? '',
        ville: json['ville']?.toString() ?? '',
        submissionLatitude: _parseDecimalOrNull(json['submission_latitude']),
        submissionLongitude: _parseDecimalOrNull(json['submission_longitude']),
        status: json['status']?.toString() ?? 'pending',
        rejectionReason: json['rejection_reason']?.toString(),
        promotedCaseId: json['promoted_case']?.toString(),
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}

class GarageSubmission {
  final String id;
  final String nom;
  final String description;
  final String email;
  final String telephone1;
  final String telephone2;
  final String ville;
  final String pays;
  final double latitude;
  final double longitude;
  final String heureOuverture;
  final String heureFermeture;
  final String type;
  final List<MediaRef> medias;
  final double? submissionLatitude;
  final double? submissionLongitude;
  final double? distanceKm;
  final String status; // pending | approved | rejected
  final String? rejectionReason;
  final String? promotedGarageId;
  final String dateCreation;

  const GarageSubmission({
    required this.id,
    this.nom = '',
    this.description = '',
    this.email = '',
    this.telephone1 = '',
    this.telephone2 = '',
    this.ville = '',
    this.pays = 'CAMEROUN',
    this.latitude = 0,
    this.longitude = 0,
    this.heureOuverture = '08:00',
    this.heureFermeture = '18:00',
    this.type = 'garage',
    this.medias = const [],
    this.submissionLatitude,
    this.submissionLongitude,
    this.distanceKm,
    this.status = 'pending',
    this.rejectionReason,
    this.promotedGarageId,
    this.dateCreation = '',
  });

  factory GarageSubmission.fromJson(Map<String, dynamic> json) =>
      GarageSubmission(
        id: json['id'].toString(),
        nom: json['nom']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        telephone1: json['telephone1']?.toString() ?? '',
        telephone2: json['telephone2']?.toString() ?? '',
        ville: json['ville']?.toString() ?? '',
        pays: json['pays']?.toString() ?? 'CAMEROUN',
        latitude: _parseDecimalOrNull(json['latitude']) ?? 0,
        longitude: _parseDecimalOrNull(json['longitude']) ?? 0,
        heureOuverture: json['heure_ouverture']?.toString() ?? '08:00',
        heureFermeture: json['heure_fermeture']?.toString() ?? '18:00',
        type: json['type']?.toString() ?? 'garage',
        medias: (json['medias'] as List? ?? const [])
            .whereType<Map>()
            .map((m) => MediaRef.fromJson(m.cast<String, dynamic>()))
            .toList(),
        submissionLatitude: _parseDecimalOrNull(json['submission_latitude']),
        submissionLongitude: _parseDecimalOrNull(json['submission_longitude']),
        distanceKm: _parseDecimalOrNull(json['distance_km']),
        status: json['status']?.toString() ?? 'pending',
        rejectionReason: json['rejection_reason']?.toString(),
        promotedGarageId: json['promoted_garage']?.toString(),
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}

class MySubmissions {
  final List<PanneCaseSubmission> panneCases;
  final List<GarageSubmission> garages;

  const MySubmissions({this.panneCases = const [], this.garages = const []});

  factory MySubmissions.fromJson(Map<String, dynamic> json) => MySubmissions(
        panneCases: (json['panne_case_submissions'] as List? ?? const [])
            .whereType<Map>()
            .map((j) => PanneCaseSubmission.fromJson(j.cast<String, dynamic>()))
            .toList(),
        garages: (json['garage_submissions'] as List? ?? const [])
            .whereType<Map>()
            .map((j) => GarageSubmission.fromJson(j.cast<String, dynamic>()))
            .toList(),
      );
}
