import '../entities/news_entity.dart';

abstract class NewsRepository {
  Future<List<NewsEntity>> getNews();
  Future<NewsEntity?> getNewsDetail(String id);
  Future<bool> likeNews(String id);
  Future<List<NewsEntity>> getCachedNews();
}
