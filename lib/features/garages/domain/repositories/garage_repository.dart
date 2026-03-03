import '../entities/garage_entity.dart';

abstract class GarageRepository {
  /// Get garages near current location filtered by [key] (type/keyword)
  Future<List<GarageEntity>> getGaragesAround({String key = ''});

  /// Get full garage details by [id]
  Future<GarageEntity?> getGarageDetail(String id);

  /// Search garages by keyword
  Future<List<GarageEntity>> searchGarages(String query);

  /// Get locally cached garages (Isar)
  Future<List<GarageEntity>> getCachedGarages();
}
