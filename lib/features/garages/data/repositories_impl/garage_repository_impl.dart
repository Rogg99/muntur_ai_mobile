import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../domain/entities/garage_entity.dart';
import '../../domain/repositories/garage_repository.dart';
import '../models/garage_model.dart';

class GarageRepositoryImpl implements GarageRepository {
  final ApiClient _apiClient;

  GarageRepositoryImpl(this._apiClient);

  // ──────────────────────────── GARAGES AROUND ─────────────────────────────

  @override
  Future<List<GarageEntity>> getGaragesAround({String key = ''}) async {
    try {
      // Get current position
      final position = await _getCurrentPosition();

      final response = await _apiClient.post('/garages/around/', data: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'key': key,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawList = response.data['data'] ?? response.data;
        if (rawList is List) {
          final garages = rawList.map((j) => GarageModel.fromJson(j)).toList();

          // Persist to Isar
          final isar = IsarDb.instance;
          await isar.writeTxn(() async {
            for (final g in garages) {
              g.stale = false;
              await isar.garageModels.put(g);
            }
          });

          return garages.map(_toEntity).toList();
        }
      }
    } catch (_) {}

    // Fallback to Isar cache
    return getCachedGarages();
  }

  // ─────────────────────────── GARAGE DETAIL ────────────────────────────────

  @override
  Future<GarageEntity?> getGarageDetail(String id) async {
    try {
      final response = await _apiClient.get('/garages/$id/');
      if (response.statusCode == 200) {
        final raw = response.data['data'] ?? response.data;
        final model = GarageModel.fromJson(raw as Map<String, dynamic>);
        final isar = IsarDb.instance;
        await isar.writeTxn(() async => isar.garageModels.put(model));
        return _toEntity(model);
      }
    } catch (_) {}

    // Fallback to local
    final isar = IsarDb.instance;
    final local = await isar.garageModels.filter().idEqualTo(id).findFirst();
    return local != null ? _toEntity(local) : null;
  }

  // ──────────────────────────── SEARCH ─────────────────────────────────────

  @override
  Future<List<GarageEntity>> searchGarages(String query) async {
    try {
      final response =
          await _apiClient.get('/garages/', queryParameters: {'search': query});
      if (response.statusCode == 200) {
        final rawList = response.data['data'] ?? response.data;
        if (rawList is List) {
          return rawList
              .map((j) => _toEntity(GarageModel.fromJson(j)))
              .toList();
        }
      }
    } catch (_) {}
    // Fallback: filter local cache by name
    final isar = IsarDb.instance;
    final all = await isar.garageModels.where().findAll();
    final q = query.toLowerCase();
    return all
        .where((g) =>
            g.nom.toLowerCase().contains(q) ||
            g.ville.toLowerCase().contains(q))
        .map(_toEntity)
        .toList();
  }

  // ──────────────────────────── ISAR CACHE ─────────────────────────────────

  @override
  Future<List<GarageEntity>> getCachedGarages() async {
    final isar = IsarDb.instance;
    final all = await isar.garageModels.where().findAll();
    return all.map(_toEntity).toList();
  }

  // ─────────────────────────── HELPERS ─────────────────────────────────────

  GarageEntity _toEntity(GarageModel m) => GarageEntity(
        id: m.id,
        nom: m.nom,
        description: m.description,
        email: m.email,
        telephone1: m.telephone1,
        telephone2: m.telephone2,
        photo: m.photo,
        ville: m.ville,
        pays: m.pays,
        type: m.type,
        heureOuverture: m.heureOuverture,
        heureFermeture: m.heureFermeture,
        latitude: m.latitude,
        longitude: m.longitude,
        rating: m.rating,
        distance: m.distance,
        medias: m.medias,
      );

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    return Geolocator.getCurrentPosition();
  }
}
