class Abonnement {
  late String user;
  late String id;
  late String code;
  late String type;
  late int time;
  late double price;
  late String currency;

  Abonnement({
    this.user = 'none',
    this.id = 'none',
    this.code = 'none',
    this.currency = 'XAF',
    this.type = 'Free',
    this.time = 0,
    this.price = 0,
  });

  factory Abonnement.fromJson(Map<String, dynamic> json) {
    return Abonnement(
      type: json['type'],
      user: json['user'],
      id: json['id'],
      time: json['time'],
    );
  }
}

class PackAbonnement {
  late String code;
  late String type;
  late int days;
  late double price;
  late String currency;

  PackAbonnement({
    this.code = 'none',
    this.currency = 'XAF',
    this.type = 'Free',
    this.days = 0,
    this.price = 0,
  });

  factory PackAbonnement.fromJson(Map<String, dynamic> json) {
    return PackAbonnement(
      type: json['type'],
      code: json['code'],
      price: json['price'],
      days: json['days'],
    );
  }


}



