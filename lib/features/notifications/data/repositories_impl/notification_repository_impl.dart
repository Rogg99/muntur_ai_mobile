import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl {
  final ApiClient _apiClient;
  NotificationRepositoryImpl(this._apiClient);

  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications/');
      if (response.statusCode == 200) {
        final rawList = response.data['data'] ?? response.data;
        if (rawList is List) {
          final models =
              rawList.map((j) => NotificationModel.fromJson(j)).toList();
          final isar = IsarDb.instance;
          await isar.writeTxn(() async {
            for (final m in models) {
              await isar.notificationModels.put(m);
            }
          });
          return models.map(_toEntity).toList();
        }
      }
    } catch (_) {}
    return _getCached();
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _apiClient.post('/notifications/$id/read/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final isar = IsarDb.instance;
        final local =
            await isar.notificationModels.filter().idEqualTo(id).findFirst();
        if (local != null) {
          await isar.writeTxn(() async {
            local.isRead = true;
            await isar.notificationModels.put(local);
          });
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.post('/notifications/read-all/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final isar = IsarDb.instance;
        final all = await isar.notificationModels.where().findAll();
        await isar.writeTxn(() async {
          for (final m in all) {
            m.isRead = true;
            await isar.notificationModels.put(m);
          }
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<List<NotificationEntity>> _getCached() async {
    final isar = IsarDb.instance;
    final all =
        await isar.notificationModels.where().sortByTimeDesc().findAll();
    return all.map(_toEntity).toList();
  }

  NotificationEntity _toEntity(NotificationModel m) => NotificationEntity(
        id: m.id,
        title: m.title,
        text: m.text,
        image: m.image,
        url: m.url,
        isRead: m.isRead,
        time: m.time,
      );
}
