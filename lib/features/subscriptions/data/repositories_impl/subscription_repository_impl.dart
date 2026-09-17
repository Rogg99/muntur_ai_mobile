import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../domain/entities/subscription_entity.dart';
import '../models/subscription_model.dart';

/// DRF `DecimalField`s serialize to a JSON string by default — accepts both
/// a bare num and a numeric string so a `price` field never crashes parsing
/// regardless of which shape the backend sends (see the marketplace parsing
/// bug this same pattern was introduced to fix).
double _parseDecimal(dynamic raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '') ?? 0;
}

/// Mirrors marketplace_repository_impl.dart's `_withCleanError`: rethrows a
/// DioException carrying the backend's `{"detail": "..."}` body as a plain
/// Exception with that message.
Future<T> _withCleanError<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    throw Exception(detail?.toString() ?? 'La requête a échoué.');
  }
}

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
        final rawList = asResponseList(response.data);
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

  // ─── Souscrire à un plan (MoMo) ──────────────────────────────────────────

  /// Starts a real Campay collect prompt on [phone] — the plan is only
  /// actually activated once Campay's webhook confirms, pushed via the
  /// existing `subscription`/`transaction` WS events (RealtimeDispatcher
  /// already invalidates currentSubscriptionProvider on those). This no
  /// longer activates instantly, same `payment_pending` pattern as
  /// marketplace `pay/`.
  Future<MomoCollectResult> subscribe(String planCode, String phone) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/abonnements/subscribe/', data: {
        'plan': planCode,
        'phone': phone,
      });
      final raw = response.data['data'] ?? response.data;
      final map = (raw as Map).cast<String, dynamic>();
      return MomoCollectResult(
        status: map['status']?.toString() ?? 'payment_pending',
        ussdCode: map['ussd_code']?.toString(),
      );
    });
  }

  /// Card alternative to [subscribe] — same Campay-hosted-widget pattern as
  /// marketplace `payOrderByLink`.
  Future<String> subscribeByLink(
    String planCode, {
    required String redirectUrl,
    required String failureRedirectUrl,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/abonnements/pay-by-link/', data: {
        'plan': planCode,
        'redirect_url': redirectUrl,
        'failure_redirect_url': failureRedirectUrl,
      });
      final raw = response.data['data'] ?? response.data;
      return (raw as Map)['payment_link'].toString();
    });
  }

  // ─── Coins packs ─────────────────────────────────────────────────────────

  Future<List<CoinsPackEntity>> getCoinsPacks() {
    return _withCleanError(() async {
      final response = await _apiClient.get('/coins-packs/');
      final rawList = asResponseList(response.data);
      return rawList
          .whereType<Map>()
          .map((j) => _toCoinsPackEntity(j.cast<String, dynamic>()))
          .where((p) => p.active)
          .toList();
    });
  }

  CoinsPackEntity _toCoinsPackEntity(Map<String, dynamic> json) =>
      CoinsPackEntity(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        coins: (json['coins'] as num?)?.toInt() ?? 0,
        price: _parseDecimal(json['price']),
        currency: json['currency']?.toString() ?? 'XAF',
        active: json['active'] != false,
      );

  /// MoMo collect for a coins pack — coins are only credited once Campay's
  /// webhook confirms, pushed live via the `coins_balance_updated` WS event
  /// (see RealtimeDispatcher), not returned here.
  Future<MomoCollectResult> buyCoinsPack(String packCode, String phone) {
    return _withCleanError(() async {
      final response = await _apiClient
          .post('/coins-packs/$packCode/buy/', data: {'phone': phone});
      final raw = response.data['data'] ?? response.data;
      final map = (raw as Map).cast<String, dynamic>();
      return MomoCollectResult(
        status: map['status']?.toString() ?? 'payment_pending',
        ussdCode: map['ussd_code']?.toString(),
      );
    });
  }

  /// Card alternative to [buyCoinsPack].
  Future<String> buyCoinsPackByLink(
    String packCode, {
    required String redirectUrl,
    required String failureRedirectUrl,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post(
        '/coins-packs/$packCode/buy-by-link/',
        data: {
          'redirect_url': redirectUrl,
          'failure_redirect_url': failureRedirectUrl,
        },
      );
      final raw = response.data['data'] ?? response.data;
      return (raw as Map)['payment_link'].toString();
    });
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
