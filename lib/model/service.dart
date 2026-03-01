import 'dart:convert';

class Product {
  late String longName;
  late String shortName;
  late String code;
  late String currency;
  late double price;
  late double realPrice;
  late int months;

  Product({
    required this.longName,
    required this.shortName,
    required this.code,
    required this.currency,
    required this.price,
    required this.realPrice,
    this.months=0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code']??'',
      currency: json['currency']??'',
      shortName: json['data']['token'],
      longName: json['data']['longName']??'',
      price: json['price']??0,
      realPrice: json['realPrice']??0,
      months: json['months']??0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shortName': shortName,
      'longName': longName,
      'code': code,
      'currency': currency,
      'price': price,
      'realPrice': realPrice,
      'months': months,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

}
