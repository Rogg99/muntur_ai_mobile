class SubscriptionEntity {
  final String id;
  final String userId;
  final String code;
  final String type;
  final double price;
  final String currency;
  final int days;
  final int expiresAt;
  final int coins;
  final bool active;

  const SubscriptionEntity({
    required this.id,
    this.userId = '',
    this.code = 'none',
    this.type = 'Free',
    this.price = 0,
    this.currency = 'XAF',
    this.days = 0,
    this.expiresAt = 0,
    this.coins = 0,
    this.active = false,
  });

  bool get isExpired =>
      expiresAt > 0 &&
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
          .isBefore(DateTime.now());
}

class SubscriptionPlanEntity {
  final String code;
  final String type;
  final double price;
  final String currency;
  final int days;
  final String description;

  const SubscriptionPlanEntity({
    required this.code,
    this.type = 'Free',
    this.price = 0,
    this.currency = 'XAF',
    this.days = 0,
    this.description = '',
  });
}
