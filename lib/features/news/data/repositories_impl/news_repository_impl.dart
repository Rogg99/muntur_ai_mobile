import 'package:isar/isar.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final ApiClient _apiClient;
  NewsRepositoryImpl(this._apiClient);

  // ──────────────────────────── LIST ────────────────────────────────────────

  @override
  Future<List<NewsEntity>> getNews() async {
    try {
      final response = await _apiClient.get('/infos/');
      if (response.statusCode == 200) {
        final rawList = response.data['data'] ?? response.data;
        if (rawList is List) {
          final models = rawList.map((j) => NewsModel.fromJson(j)).toList();
          final isar = IsarDb.instance;
          await isar.writeTxn(() async {
            for (final m in models) {
              await isar.newsModels.put(m);
            }
          });
          return models.map(_toEntity).toList();
        }
      }
    } catch (_) {}
    return getCachedNews();
  }

  // ──────────────────────────── DETAIL ──────────────────────────────────────

  @override
  Future<NewsEntity?> getNewsDetail(String id) async {
    try {
      final response = await _apiClient.get('/infos/$id/');
      if (response.statusCode == 200) {
        final raw = response.data['data'] ?? response.data;
        final model = NewsModel.fromJson(raw as Map<String, dynamic>);
        final isar = IsarDb.instance;
        await isar.writeTxn(() async => isar.newsModels.put(model));
        return _toEntity(model);
      }
    } catch (_) {}
    final isar = IsarDb.instance;
    final local = await isar.newsModels.filter().idEqualTo(id).findFirst();
    return local != null ? _toEntity(local) : null;
  }

  // ──────────────────────────── LIKE ────────────────────────────────────────

  @override
  Future<bool> likeNews(String id) async {
    try {
      final response = await _apiClient.post('/infos/$id/like/');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ──────────────────────────── ISAR ────────────────────────────────────────

  @override
  Future<List<NewsEntity>> getCachedNews() async {
    final isar = IsarDb.instance;
    final all = await isar.newsModels.where().sortByTimeDesc().findAll();
    return all.map(_toEntity).toList();
  }

  // ──────────────────────────── HELPER ──────────────────────────────────────

  NewsEntity _toEntity(NewsModel m) => NewsEntity(
        id: m.id,
        title: m.title,
        image: m.image,
        contenu: m.contenu,
        path: m.path,
        statut: m.statut,
        time: m.time,
        likes: m.likes,
        comments: m.comments,
        liked: m.liked,
      );
}
