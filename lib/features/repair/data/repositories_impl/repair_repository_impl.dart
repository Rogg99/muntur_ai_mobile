import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/repair_models.dart';

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

/// NOT testable against a real server yet — backend code is merged on main
/// but has no Django migration and isn't deployed (confirmed by c7/90,
/// 2026-10-11). Written against the contract relayed by c7 from the actual
/// serializers/viewsets, not a summary.
class RepairRepositoryImpl {
  final ApiClient _apiClient;

  RepairRepositoryImpl(this._apiClient);

  // ─────────────────────── GARAGE STAFF ───────────────────────

  /// Null if this account has no garage-staff profile yet (404).
  Future<GarageStaffProfile?> getMyGarageStaffProfile() async {
    try {
      final response = await _apiClient.get('/repair-garages/me/');
      final raw = response.data['data'] ?? response.data;
      if (raw is! Map) return null;
      return GarageStaffProfile.fromJson(raw.cast<String, dynamic>());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<GarageStaffProfile> registerAsGarageStaff({
    required String relatedGarageId,
    required String payoutPhoneNumber,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/repair-garages/', data: {
        'related_garage': relatedGarageId,
        'payout_phone_number': payoutPhoneNumber,
      });
      final raw = response.data['data'] ?? response.data;
      return GarageStaffProfile.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Staff + the garage's bookings, per c7's contract.
  Future<List<RepairBooking>> getGarageDashboard() {
    return _withCleanError(() async {
      final response = await _apiClient.get('/repair-garages/dashboard/');
      final rawList = asResponseList(response.data);
      return rawList
          .whereType<Map>()
          .map((j) => RepairBooking.fromJson(j.cast<String, dynamic>()))
          .toList();
    });
  }

  // ─────────────────────── CLIENT BOOKINGS ───────────────────────

  Future<RepairBooking> createBooking({
    required String garageId,
    String? description,
  }) {
    return _withCleanError(() async {
      final response = await _apiClient.post('/repair-bookings/', data: {
        'garage_id': garageId,
        if (description != null && description.isNotEmpty)
          'description': description,
      });
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  Future<List<RepairBooking>> getMyBookings() {
    return _withCleanError(() async {
      final response = await _apiClient.get('/repair-bookings/');
      final rawList = asResponseList(response.data);
      return rawList
          .whereType<Map>()
          .map((j) => RepairBooking.fromJson(j.cast<String, dynamic>()))
          .toList();
    });
  }

  Future<RepairBooking> getBookingDetail(String bookingId) {
    return _withCleanError(() async {
      final response = await _apiClient.get('/repair-bookings/$bookingId/');
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Client, triggers the 1000 XAF Campay collect — stays 'pending' until
  /// the webhook confirms (same async-confirmation pattern as marketplace
  /// orders), never optimistic.
  Future<void> payBooking(String bookingId, String phone) {
    return _withCleanError(() async {
      await _apiClient.post('/repair-bookings/$bookingId/pay/',
          data: {'phone': phone});
    });
  }

  /// Client-only, only while still 'pending' (before the garage responds).
  Future<RepairBooking> cancelBooking(String bookingId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/repair-bookings/$bookingId/cancel/');
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Client-only, only while 'accepted' (garage never showed up).
  Future<RepairBooking> reportNoShow(String bookingId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/repair-bookings/$bookingId/no-show/');
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  // ─────────────────────── GARAGE-SIDE ACTIONS ───────────────────────

  /// Garage staff-only, requires escrow already held.
  Future<RepairBooking> acceptBooking(String bookingId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/repair-bookings/$bookingId/accept/');
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  Future<RepairBooking> refuseBooking(String bookingId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/repair-bookings/$bookingId/refuse/');
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Garage staff-only, optional step ('accepted' -> 'in_progress').
  Future<RepairBooking> startBooking(String bookingId) {
    return _withCleanError(() async {
      final response =
          await _apiClient.post('/repair-bookings/$bookingId/start/');
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }

  /// Garage staff-only. Verifies the client-provided PIN and triggers the
  /// 700 XAF withdraw — status only moves to 'completed' on the withdraw
  /// webhook confirmation, never optimistically.
  Future<RepairBooking> completeBooking(String bookingId, String pin) {
    return _withCleanError(() async {
      final response = await _apiClient
          .post('/repair-bookings/$bookingId/complete/', data: {'pin': pin});
      final raw = response.data['data'] ?? response.data;
      return RepairBooking.fromJson((raw as Map).cast<String, dynamic>());
    });
  }
}
