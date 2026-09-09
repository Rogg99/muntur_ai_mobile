import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chatbot/presentation/providers/chatbot_provider.dart';
import '../../features/garages/presentation/providers/garage_provider.dart';
import '../../features/news/presentation/providers/news_provider.dart';

/// Refreshes every home-tab data source together — discussions, forums,
/// news, garages, and the profile — regardless of which tab's pull-to-
/// refresh triggered it. The Search/map tab has no scrollable content to
/// pull down on (it's a full-bleed pannable map), so this is what keeps its
/// data current: refreshing from any other tab refreshes it too.
Future<void> refreshAllHomeData(WidgetRef ref) async {
  await Future.wait([
    ref.read(discussionsProvider.notifier).refresh(),
    ref.read(forumsProvider.notifier).refresh(),
    ref.read(newsListProvider.notifier).refresh(),
    ref.read(garagesAroundProvider().notifier).refresh(),
    ref.read(authStateProvider.notifier).refresh(),
  ]);
}
