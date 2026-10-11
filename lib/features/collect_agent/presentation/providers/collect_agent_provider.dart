import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/collect_agent_models.dart';
import '../../data/repositories_impl/collect_agent_repository_impl.dart';

final collectAgentRepositoryProvider = Provider<CollectAgentRepositoryImpl>(
  (ref) => CollectAgentRepositoryImpl(ApiClient()),
);

/// Null when this account has no agent profile yet.
final myAgentProfileProvider =
    FutureProvider.autoDispose<CollectAgentProfile?>((ref) {
  return ref.read(collectAgentRepositoryProvider).getMyAgentProfile();
});

/// Null when this account has no agent profile yet (same gate server-side
/// as the submit-* endpoints).
final mySubmissionsProvider = FutureProvider.autoDispose<MySubmissions?>((ref) {
  return ref.read(collectAgentRepositoryProvider).getMySubmissions();
});
