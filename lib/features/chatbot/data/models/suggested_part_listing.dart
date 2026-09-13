import 'dart:convert';

/// One entry of `Message.suggested_action_params.listings` when
/// `suggested_action == 'part_purchase'` (suggest_part_purchase function
/// call, see chat.dart's onSuggestedAction wiring). Up to 3 per message.
class SuggestedPartListing {
  final String partListingId;
  final String title;
  final String condition;
  final double price;
  final String currency;
  final String vendorId;
  final String vendorShopName;
  final String vendorVille;
  /// null when the ask-question call didn't include a location fix.
  final double? distanceKm;
  /// A flat estimate (env-configurable server-side), never a guaranteed
  /// price — always label it as such in the UI.
  final double deliveryFeeEstimateXaf;

  const SuggestedPartListing({
    required this.partListingId,
    this.title = '',
    this.condition = 'used',
    this.price = 0,
    this.currency = 'XAF',
    this.vendorId = '',
    this.vendorShopName = '',
    this.vendorVille = '',
    this.distanceKm,
    this.deliveryFeeEstimateXaf = 1000,
  });

  factory SuggestedPartListing.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return SuggestedPartListing(
      partListingId: json['part_listing_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      condition: json['condition']?.toString() ?? 'used',
      price: parseNum(json['price']) ?? 0,
      currency: json['currency']?.toString() ?? 'XAF',
      vendorId: json['vendor_id']?.toString() ?? '',
      vendorShopName: json['vendor_shop_name']?.toString() ?? '',
      vendorVille: json['vendor_ville']?.toString() ?? '',
      distanceKm: parseNum(json['distance_km']),
      deliveryFeeEstimateXaf: parseNum(json['delivery_fee_estimate_xaf']) ?? 1000,
    );
  }

  /// Parses the whole `suggested_action_params` JSON string for a
  /// `part_purchase` message into its listings (empty if malformed/absent).
  static List<SuggestedPartListing> listFromParamsJson(String paramsRaw) {
    try {
      final decoded = jsonDecode(paramsRaw);
      final listings = decoded is Map ? decoded['listings'] : null;
      if (listings is! List) return const [];
      return listings
          .whereType<Map>()
          .map((e) => SuggestedPartListing.fromJson(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
