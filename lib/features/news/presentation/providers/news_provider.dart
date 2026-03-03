import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/news_entity.dart';
import '../../data/repositories_impl/news_repository_impl.dart';
import '../../../../core/network/api_client.dart';

part 'news_provider.g.dart';

@riverpod
NewsRepositoryImpl newsRepository(NewsRepositoryRef ref) =>
    NewsRepositoryImpl(ApiClient());

@riverpod
class NewsList extends _$NewsList {
  @override
  FutureOr<List<NewsEntity>> build() async =>
      ref.read(newsRepositoryProvider).getNews();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(newsRepositoryProvider).getNews());
  }

  Future<void> toggleLike(String id) async {
    final current = state.valueOrNull ?? [];
    final idx = current.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final item = current[idx];
    final success = await ref.read(newsRepositoryProvider).likeNews(id);
    if (success) {
      final updated = List<NewsEntity>.from(current);
      updated[idx] = item.copyWith(
        liked: !item.liked,
        likes: item.liked ? item.likes - 1 : item.likes + 1,
      );
      state = AsyncValue.data(updated);
    }
  }
}

@riverpod
Future<NewsEntity?> newsDetail(NewsDetailRef ref, String id) =>
    ref.read(newsRepositoryProvider).getNewsDetail(id);
