/// Mirrors api/apps/api/serializers.py's CourierProfileReadSerializer /
/// DeliveryReadSerializer exactly — checked directly against the backend
/// code (models.py/serializers.py/viewsets.py), not an indicative summary.
library;

class CourierProfile {
  final String id;
  final bool verified;
  final bool active;
  final String dateCreation;

  const CourierProfile({
    required this.id,
    this.verified = false,
    this.active = true,
    this.dateCreation = '',
  });

  factory CourierProfile.fromJson(Map<String, dynamic> json) => CourierProfile(
        id: json['id'].toString(),
        verified: json['verified'] == true,
        active: json['active'] == true,
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}

const List<String> deliveryStatusOrder = [
  'pending',
  'assigned',
  'picked_up',
  'in_transit',
  'delivered',
];

class Delivery {
  final String id;
  final String orderId;
  final String partTitle;
  final String vendorShopName;
  final String vendorVille;
  final String status; // pending|assigned|picked_up|in_transit|delivered|failed
  final String partner;
  final CourierProfile? courier;
  final String addressText;
  final String? pickupConfirmedAt;
  final String? dropoffConfirmedAt;
  final String dateCreation;

  const Delivery({
    required this.id,
    required this.orderId,
    this.partTitle = '',
    this.vendorShopName = '',
    this.vendorVille = '',
    this.status = 'pending',
    this.partner = 'internal_courier',
    this.courier,
    this.addressText = '',
    this.pickupConfirmedAt,
    this.dropoffConfirmedAt,
    this.dateCreation = '',
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
        id: json['id'].toString(),
        orderId: json['order_id']?.toString() ?? '',
        partTitle: json['part_title']?.toString() ?? '',
        vendorShopName: json['vendor_shop_name']?.toString() ?? '',
        vendorVille: json['vendor_ville']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        partner: json['partner']?.toString() ?? 'internal_courier',
        courier: json['courier'] is Map
            ? CourierProfile.fromJson((json['courier'] as Map).cast<String, dynamic>())
            : null,
        addressText: json['address_text']?.toString() ?? '',
        pickupConfirmedAt: json['pickup_confirmed_at']?.toString(),
        dropoffConfirmedAt: json['dropoff_confirmed_at']?.toString(),
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}
