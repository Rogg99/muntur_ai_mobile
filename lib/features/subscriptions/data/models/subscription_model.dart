import 'package:isar/isar.dart';

part 'subscription_model.g.dart';

@Collection()
class SubscriptionModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id = '';

  String userId = '';
  String code = 'none';
  String type = 'Free';
  String currency = 'XAF';
  double price = 0.0;
  int days = 0;
  int expiresAt = 0; // timestamp ms
  int coins = 0;
  bool active = false;

  SubscriptionModel();

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final m = SubscriptionModel();
    m.id = json['id']?.toString() ?? '';
    m.userId = json['user']?.toString() ?? '';
    m.code = json['code'] ?? 'none';
    m.type = json['type'] ?? 'Free';
    m.currency = json['currency'] ?? 'XAF';
    m.price = (json['price'] as num?)?.toDouble() ?? 0;
    m.days = (json['days'] as num?)?.toInt() ?? 0;
    m.expiresAt = (json['time'] ?? json['expires_at'] as num?)?.toInt() ?? 0;
    m.coins = (json['coins'] as num?)?.toInt() ?? 0;
    m.active = json['active'] == true;
    return m;
  }
}

@Collection()
class SubscriptionPlanModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String code = '';

  String type = 'Free';
  double price = 0.0;
  String currency = 'XAF';
  int days = 0;
  String description = '';

  SubscriptionPlanModel();

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final m = SubscriptionPlanModel();
    m.code = json['code'] ?? '';
    m.type = json['type'] ?? 'Free';
    m.price = (json['price'] as num?)?.toDouble() ?? 0;
    m.currency = json['currency'] ?? 'XAF';
    m.days = (json['days'] as num?)?.toInt() ?? 0;
    m.description = json['description'] ?? '';
    return m;
  }
}
