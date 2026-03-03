import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../data/repositories_impl/subscription_repository_impl.dart';
import '../../../../core/network/api_client.dart';

part 'subscription_provider.g.dart';

@riverpod
SubscriptionRepositoryImpl subscriptionRepository(
        SubscriptionRepositoryRef ref) =>
    SubscriptionRepositoryImpl(ApiClient());

// ── Abonnement actif ─────────────────────────────────────────────────────────

@riverpod
class CurrentSubscription extends _$CurrentSubscription {
  @override
  FutureOr<SubscriptionEntity?> build() async =>
      ref.read(subscriptionRepositoryProvider).getMySubscription();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(subscriptionRepositoryProvider).getMySubscription());
  }

  Future<bool> subscribe(String planCode, String paymentMethod) async {
    final success = await ref
        .read(subscriptionRepositoryProvider)
        .subscribe(planCode, paymentMethod);
    if (success) await refresh();
    return success;
  }
}

// ── Plans ─────────────────────────────────────────────────────────────────────

@riverpod
Future<List<SubscriptionPlanEntity>> subscriptionPlans(
        SubscriptionPlansRef ref) =>
    ref.read(subscriptionRepositoryProvider).getPlans();

// ── Solde coins ───────────────────────────────────────────────────────────────

@riverpod
Future<int> coinsBalance(CoinsBalanceRef ref) =>
    ref.read(subscriptionRepositoryProvider).getCoins();
