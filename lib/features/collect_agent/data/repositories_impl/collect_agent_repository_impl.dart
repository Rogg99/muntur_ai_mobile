import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/collect_agent_models.dart';

/// Rethrows a DioException carrying the backend's `{"detail": "..."}` body
/// as a plain Exception with that message (same pattern as
/// marketplace_repository_impl.dart's _withCleanError).
Future<T> _withCleanError<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    throw Exception(detail?.toString() ?? 'La requête a échoué.');
  }
}

/// Contract verified directly against serializers.py/viewsets.py by the
/// backend session (c7, 2026-10-11) and confirmed deployed (90) — not an
/// indicative summary.
class CollectAgentRepositoryImpl {
  final ApiClient _apiClient;

  CollectAgentRepositoryImpl(this._apiClient);

  /// Null if this account has no agent profile yet (404).
  Future<CollectAgentProfile?> getMyAgentProfile() async {
    try {
      final response = await _apiClient.get('/collect-agents/me/');
      final raw = response.data['data'] ?? response.data;
      if (raw is! Map) return null;
      return CollectAgentProfile.fromJson(raw.cast<String, dynamic>());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// `update_or_create` server-side — idempotent by design. Re-applying
  /// (e.g. after a rejection) overwrites the previous profile and resets
  /// status to 'pending', no "already applied" error.
  Future<CollectAgentProfile> apply({
    required String cniFrontMediaId,
    required String cniBackMediaId,
    required String selfieFaceMediaId,
    required String selfieLeftMediaId,
    required String selfieRightMediaId,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/collect-agents/apply/', data: {
        'cni_front': cniFrontMediaId,
        'cni_back': cniBackMediaId,
        'selfie_face': selfieFaceMediaId,
        'selfie_left': selfieLeftMediaId,
        'selfie_right': selfieRightMediaId,
      });
      final raw = response.data['data'] ?? response.data;
      return CollectAgentProfile.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// 403/404 if the account has no 'approved' agent profile — surfaced as
  /// a clean message by _withCleanError either way.
  Future<PanneCaseSubmission> submitPanneCase({
    required String description,
    String? vehicle,
    String? type,
    String? reparation,
    String? ville,
    double? submissionLatitude,
    double? submissionLongitude,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/collect-agents/submit-panne-case/', data: {
        'description': description,
        if (vehicle != null && vehicle.isNotEmpty) 'vehicle': vehicle,
        if (type != null && type.isNotEmpty) 'type': type,
        if (reparation != null && reparation.isNotEmpty) 'reparation': reparation,
        if (ville != null && ville.isNotEmpty) 'ville': ville,
        if (submissionLatitude != null) 'submission_latitude': submissionLatitude,
        if (submissionLongitude != null) 'submission_longitude': submissionLongitude,
      });
      final raw = response.data['data'] ?? response.data;
      return PanneCaseSubmission.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  Future<GarageSubmission> submitGarage({
    required String nom,
    required String telephone1,
    required double latitude,
    required double longitude,
    String? description,
    String? email,
    String? telephone2,
    String? ville,
    String? pays,
    String? heureOuverture,
    String? heureFermeture,
    String? type,
    List<String>? mediaIds,
    double? submissionLatitude,
    double? submissionLongitude,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/collect-agents/submit-garage/', data: {
        'nom': nom,
        'telephone1': telephone1,
        'latitude': latitude,
        'longitude': longitude,
        if (description != null && description.isNotEmpty) 'description': description,
        if (email != null && email.isNotEmpty) 'email': email,
        if (telephone2 != null && telephone2.isNotEmpty) 'telephone2': telephone2,
        if (ville != null && ville.isNotEmpty) 'ville': ville,
        if (pays != null && pays.isNotEmpty) 'pays': pays,
        if (heureOuverture != null && heureOuverture.isNotEmpty) 'heure_ouverture': heureOuverture,
        if (heureFermeture != null && heureFermeture.isNotEmpty) 'heure_fermeture': heureFermeture,
        if (type != null && type.isNotEmpty) 'type': type,
        if (mediaIds != null && mediaIds.isNotEmpty) 'medias': mediaIds,
        if (submissionLatitude != null) 'submission_latitude': submissionLatitude,
        if (submissionLongitude != null) 'submission_longitude': submissionLongitude,
      });
      final raw = response.data['data'] ?? response.data;
      return GarageSubmission.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Null if this account has no agent profile yet (404) — same gate as
  /// the submit-* endpoints, so a non-agent never sees this UI anyway.
  Future<MySubmissions?> getMySubmissions() async {
    try {
      final response = await _apiClient.get('/collect-agents/my-submissions/');
      final raw = response.data['data'] ?? response.data;
      if (raw is! Map) return null;
      return MySubmissions.fromJson(raw.cast<String, dynamic>());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
