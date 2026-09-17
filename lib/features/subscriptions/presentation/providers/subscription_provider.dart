import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../data/repositories_impl/subscription_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/payment_models.dart';

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

  /// Starts a real Campay collect — no longer activates instantly, see
  /// SubscriptionRepositoryImpl.subscribe. The plan only actually applies
  /// once the webhook confirms and pushes a `subscription`/`transaction` WS
  /// event, at which point RealtimeDispatcher invalidates this provider on
  /// its own — [refresh] here is just an optimistic best-effort poll.
  Future<MomoCollectResult> subscribe(String planCode, String phone) async {
    final result = await ref
        .read(subscriptionRepositoryProvider)
        .subscribe(planCode, phone);
    await refresh();
    return result;
  }

  Future<String> subscribeByLink(String planCode) {
    return ref.read(subscriptionRepositoryProvider).subscribeByLink(
          planCode,
          redirectUrl: subscriptionPaymentSuccessUrl,
          failureRedirectUrl: subscriptionPaymentFailureUrl,
        );
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

// ── Coins packs ───────────────────────────────────────────────────────────────

/// Plain (non-codegen) provider — no build_runner available in this
/// environment to generate a new @riverpod provider's .g.dart entry, same
/// convention as every other provider added this session.
final coinsPacksProvider = FutureProvider<List<CoinsPackEntity>>(
  (ref) => ref.read(subscriptionRepositoryProvider).getCoinsPacks(),
);

/// Redirect scheme for card payments on coins packs / subscriptions — same
/// custom-URI-scheme approach the shared PaymentScreen/PaymentWebview use
/// for marketplace too (see payment_screen.dart / payment_webview.dart),
/// just distinct paths so a webview knows which flow it's intercepting.
const String coinsPaymentSuccessUrl = 'autosynx://payment/coins-success';
const String coinsPaymentFailureUrl = 'autosynx://payment/coins-failure';
const String subscriptionPaymentSuccessUrl =
    'autosynx://payment/subscription-success';
const String subscriptionPaymentFailureUrl =
    'autosynx://payment/subscription-failure';
