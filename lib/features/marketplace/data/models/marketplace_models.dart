/// Marketplace models mirror api/apps/api/serializers.py's
/// VendorProfileReadSerializer / PartListingReadSerializer /
/// OrderReadSerializer exactly (field names, not the earlier indicative
/// mock in Doc/11-plan-marketplace.md) — e.g. there's no `rating` or
/// `compatible_vehicles` on the real backend, only what's listed below.
library;

class VendorProfile {
  final int id;
  final String shopName;
  final bool verified;
  final bool pricePartyAgreed;
  final bool subscriptionActive;
  final int catalogCount;

  const VendorProfile({
    required this.id,
    required this.shopName,
    this.verified = false,
    this.pricePartyAgreed = false,
    this.subscriptionActive = false,
    this.catalogCount = 0,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) => VendorProfile(
        id: json['id'] as int,
        shopName: json['shop_name']?.toString() ?? '',
        verified: json['verified'] == true,
        pricePartyAgreed: json['price_parity_agreed'] == true,
        subscriptionActive: json['subscription_active'] == true,
        catalogCount: (json['catalog_count'] as num?)?.toInt() ?? 0,
      );
}

class MediaRefItem {
  final String id;
  final String file;
  final String kind;

  const MediaRefItem({required this.id, required this.file, this.kind = 'unknown'});

  factory MediaRefItem.fromJson(Map<String, dynamic> json) => MediaRefItem(
        id: json['id']?.toString() ?? '',
        file: json['file']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'unknown',
      );
}

class PartListing {
  final int id;
  final VendorProfile vendor;
  final String title;
  final String description;
  final String condition; // 'brand_new' | 'used'
  final double price;
  final String currency;
  final int stockQuantity;
  final List<String> oemReferences;
  final List<MediaRefItem> medias;
  final bool active;

  const PartListing({
    required this.id,
    required this.vendor,
    required this.title,
    this.description = '',
    this.condition = 'used',
    this.price = 0,
    this.currency = 'XAF',
    this.stockQuantity = 0,
    this.oemReferences = const [],
    this.medias = const [],
    this.active = true,
  });

  factory PartListing.fromJson(Map<String, dynamic> json) => PartListing(
        id: json['id'] as int,
        vendor: VendorProfile.fromJson(
            (json['vendor'] as Map).cast<String, dynamic>()),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        condition: json['condition']?.toString() ?? 'used',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'XAF',
        stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
        oemReferences: (json['oem_references'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        medias: (json['medias'] as List? ?? [])
            .whereType<Map>()
            .map((e) => MediaRefItem.fromJson(e.cast<String, dynamic>()))
            .toList(),
        active: json['active'] != false,
      );
}

class BuyerInfo {
  final String nom;
  final String prenom;
  final String telephone;

  const BuyerInfo({this.nom = '', this.prenom = '', this.telephone = ''});

  factory BuyerInfo.fromJson(Map<String, dynamic> json) => BuyerInfo(
        nom: json['nom']?.toString() ?? '',
        prenom: json['prenom']?.toString() ?? '',
        telephone: json['telephone']?.toString() ?? '',
      );

  String get fullName => '$prenom $nom'.trim();
}

class MarketplaceOrder {
  final int id;
  final BuyerInfo buyer;
  final PartListing listing;
  final VendorProfile vendor;
  final int quantity;
  final double priceTotal;
  final String currency;
  final String status;
  final String dateCreation;

  const MarketplaceOrder({
    required this.id,
    this.buyer = const BuyerInfo(),
    required this.listing,
    required this.vendor,
    this.quantity = 1,
    this.priceTotal = 0,
    this.currency = 'XAF',
    this.status = 'pending_payment',
    this.dateCreation = '',
  });

  factory MarketplaceOrder.fromJson(Map<String, dynamic> json) =>
      MarketplaceOrder(
        id: json['id'] as int,
        buyer: json['buyer'] is Map
            ? BuyerInfo.fromJson((json['buyer'] as Map).cast<String, dynamic>())
            : const BuyerInfo(),
        listing: PartListing.fromJson(
            (json['listing'] as Map).cast<String, dynamic>()),
        vendor: VendorProfile.fromJson(
            (json['vendor'] as Map).cast<String, dynamic>()),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        priceTotal: (json['price_total'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'XAF',
        status: json['status']?.toString() ?? 'pending_payment',
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}

class VendorDashboard {
  final VendorProfile vendor;
  final List<PartListing> catalog;
  final List<MarketplaceOrder> orders;

  const VendorDashboard({
    required this.vendor,
    this.catalog = const [],
    this.orders = const [],
  });

  factory VendorDashboard.fromJson(Map<String, dynamic> json) => VendorDashboard(
        vendor: VendorProfile.fromJson(
            (json['vendor'] as Map).cast<String, dynamic>()),
        catalog: (json['catalog'] as List? ?? [])
            .whereType<Map>()
            .map((e) => PartListing.fromJson(e.cast<String, dynamic>()))
            .toList(),
        orders: (json['orders'] as List? ?? [])
            .whereType<Map>()
            .map((e) => MarketplaceOrder.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
}
