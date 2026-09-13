import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/courier_models.dart';

/// Rethrows a DioException carrying the backend's `{"detail": "..."}` body
/// as a plain Exception with that message (same pattern as
/// marketplace_repository_impl.dart's _withCleanError).
Future<T> _withCleanError<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    throw Exception(detail?.toString() ?? 'La requête a échoué.');
  }
}

class CourierRepositoryImpl {
  final ApiClient _apiClient;

  CourierRepositoryImpl(this._apiClient);

  // ─────────────────────── COURIER ACCOUNT ───────────────────────

  /// Null if this account has no courier profile yet (404 from the server).
  Future<CourierProfile?> getMyCourierProfile() async {
    try {
      final response = await _apiClient.get('/marketplace/couriers/me/');
      final raw = response.data['data'] ?? response.data;
      if (raw is! Map) return null;
      return CourierProfile.fromJson(raw.cast<String, dynamic>());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Nothing required — creates the account, unverified (admin approves
  /// separately, no mobile flow for that).
  Future<CourierProfile> registerAsCourier() {
    return _withCleanError(() async {
      final response = await _apiClient.post('/marketplace/couriers/', data: {});
      final raw = response.data['data'] ?? response.data;
      return CourierProfile.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  // ─────────────────────── JOB BOARD ───────────────────────

  /// Vendor-side: marks a paid order ready for courier pickup, creating (or
  /// returning the existing) Delivery.
  Future<Delivery> markOrderReady(String orderId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/marketplace/orders/$orderId/mark-ready/');
      final raw = response.data['data'] ?? response.data;
      return Delivery.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// 403 if this account has no verified+active courier profile.
  Future<List<Delivery>> getAvailableDeliveries() {
    return _withCleanError(() async {
      final response = await _apiClient.get('/marketplace/deliveries/available/');
      final rawList = asResponseList(response.data);
      return rawList
          .whereType<Map>()
          .map((j) => Delivery.fromJson(j.cast<String, dynamic>()))
          .toList();
    });
  }

  /// 409 (surfaced as a clean message) if another courier claimed it first.
  Future<Delivery> claimDelivery(String deliveryId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/marketplace/deliveries/$deliveryId/claim/');
      final raw = response.data['data'] ?? response.data;
      return Delivery.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// My deliveries — vendor sees their orders' deliveries, courier sees
  /// what they've claimed (server-side scoped, same endpoint for both).
  Future<List<Delivery>> getMyDeliveries() {
    return _withCleanError(() async {
      final response = await _apiClient.get('/marketplace/deliveries/');
      final rawList = asResponseList(response.data);
      return rawList
          .whereType<Map>()
          .map((j) => Delivery.fromJson(j.cast<String, dynamic>()))
          .toList();
    });
  }

  Future<Delivery> getDeliveryDetail(String deliveryId) {
    return _withCleanError(() async {
      final response = await _apiClient.get('/marketplace/deliveries/$deliveryId/');
      final raw = response.data['data'] ?? response.data;
      return Delivery.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  // ─────────────────────── QR HANDOFF ───────────────────────

  /// Vendor-only, delivery must be 'assigned'.
  Future<String> getPickupQrToken(String deliveryId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.get('/marketplace/deliveries/$deliveryId/pickup-qr/');
      final raw = response.data['data'] ?? response.data;
      return (raw as Map)['qr_token'].toString();
    });
  }

  /// Courier-only, delivery must be 'assigned'.
  Future<Delivery> confirmPickup(String deliveryId, String qrToken) {
    return _withCleanError(() async {
      final response = await _apiClient.post(
          '/marketplace/deliveries/$deliveryId/confirm-pickup/',
          data: {'qr_token': qrToken});
      final raw = response.data['data'] ?? response.data;
      return Delivery.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Courier-only, manual/optional, delivery must be 'picked_up'.
  Future<Delivery> startTransit(String deliveryId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/marketplace/deliveries/$deliveryId/start-transit/');
      final raw = response.data['data'] ?? response.data;
      return Delivery.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Courier-only, delivery must be 'picked_up' or 'in_transit'.
  Future<String> getDropoffQrToken(String deliveryId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.get('/marketplace/deliveries/$deliveryId/dropoff-qr/');
      final raw = response.data['data'] ?? response.data;
      return (raw as Map)['qr_token'].toString();
    });
  }

  /// Buyer-only, delivery must be 'picked_up' or 'in_transit'. Marks the
  /// Delivery 'delivered' — does NOT release escrow, that's still the
  /// separate confirm-delivery/ PIN step on the Order itself.
  Future<Delivery> confirmDropoff(String deliveryId, String qrToken) {
    return _withCleanError(() async {
      final response = await _apiClient.post(
          '/marketplace/deliveries/$deliveryId/confirm-dropoff/',
          data: {'qr_token': qrToken});
      final raw = response.data['data'] ?? response.data;
      return Delivery.fromJson((raw as Map).cast<String, dynamic>());
    });
  }
}
