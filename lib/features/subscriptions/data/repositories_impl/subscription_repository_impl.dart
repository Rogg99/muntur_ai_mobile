import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../domain/entities/subscription_entity.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl {
  final ApiClient _apiClient;
  SubscriptionRepositoryImpl(this._apiClient);

  // ─── Mon abonnement actif ────────────────────────────────────────────────

  Future<SubscriptionEntity?> getMySubscription() async {
    try {
      final response = await _apiClient.get('/abonnements/my/');
      if (response.statusCode == 200) {
        final raw = response.data['data'] ?? response.data;
        final model = SubscriptionModel.fromJson(raw as Map<String, dynamic>);
        final isar = IsarDb.instance;
        await isar.writeTxn(() async => isar.subscriptionModels.put(model));
        return _toEntity(model);
      }
    } catch (_) {}
    final isar = IsarDb.instance;
    final local =
        await isar.subscriptionModels.where().sortByExpiresAtDesc().findFirst();
    return local != null ? _toEntity(local) : null;
  }

  // ─── Plans disponibles ───────────────────────────────────────────────────

  Future<List<SubscriptionPlanEntity>> getPlans() async {
    try {
      final response = await _apiClient.get('/abonnements/plans/');
      if (response.statusCode == 200) {
        final rawList = response.data['data'] ?? response.data;
        if (rawList is List) {
          final plans =
              rawList.map((j) => SubscriptionPlanModel.fromJson(j)).toList();
          final isar = IsarDb.instance;
          await isar.writeTxn(() async {
            for (final p in plans) {
              await isar.subscriptionPlanModels.put(p);
            }
          });
          return plans.map(_toPlanEntity).toList();
        }
      }
    } catch (_) {}
    final isar = IsarDb.instance;
    final all = await isar.subscriptionPlanModels.where().findAll();
    return all.map(_toPlanEntity).toList();
  }

  // ─── Solde coins ────────────────────────────────────────────────────────

  Future<int> getCoins() async {
    try {
      final response = await _apiClient.get('/coins/balance/');
      if (response.statusCode == 200) {
        return (response.data['coins'] ?? response.data['balance'] as num?)
                ?.toInt() ??
            0;
      }
    } catch (_) {}
    return 0;
  }

  // ─── Souscrire à un plan ─────────────────────────────────────────────────

  Future<bool> subscribe(String planCode, String paymentMethod) async {
    try {
      final response = await _apiClient.post('/abonnements/subscribe/', data: {
        'plan': planCode,
        'payment_method': paymentMethod,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  SubscriptionEntity _toEntity(SubscriptionModel m) => SubscriptionEntity(
        id: m.id,
        userId: m.userId,
        code: m.code,
        type: m.type,
        price: m.price,
        currency: m.currency,
        days: m.days,
        expiresAt: m.expiresAt,
        coins: m.coins,
        active: m.active,
      );

  SubscriptionPlanEntity _toPlanEntity(SubscriptionPlanModel m) =>
      SubscriptionPlanEntity(
        code: m.code,
        type: m.type,
        price: m.price,
        currency: m.currency,
        days: m.days,
        description: m.description,
      );
}
