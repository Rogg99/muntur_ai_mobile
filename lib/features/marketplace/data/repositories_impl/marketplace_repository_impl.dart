import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/marketplace_models.dart';

/// Read-only for now: catalogue browsing, vendor storefronts, and the
/// buyer's own order history — the stable endpoints from a4's commit
/// 14344ce. Checkout/pay/PIN/return are intentionally not wired here yet
/// (phase 3b, not shipped) per muntur-ai-9c's direction.
class MarketplaceRepositoryImpl {
  final ApiClient _apiClient;

  MarketplaceRepositoryImpl(this._apiClient);

  Future<List<PartListing>> getParts({String search = ''}) async {
    final response = await _apiClient.get(
      '/marketplace/parts/',
      queryParameters: search.isNotEmpty ? {'search': search} : null,
    );
    final rawList = asResponseList(response.data);
    return rawList
        .whereType<Map>()
        .map((j) => PartListing.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  Future<PartListing?> getPartDetail(int id) async {
    final response = await _apiClient.get('/marketplace/parts/$id/');
    final raw = response.data['data'] ?? response.data;
    if (raw is! Map) return null;
    return PartListing.fromJson(raw.cast<String, dynamic>());
  }

  Future<VendorProfile?> getVendor(int id) async {
    final response = await _apiClient.get('/marketplace/vendors/$id/');
    final raw = response.data['data'] ?? response.data;
    if (raw is! Map) return null;
    return VendorProfile.fromJson(raw.cast<String, dynamic>());
  }

  /// No `?vendor=` filter exists server-side yet, so a vendor's storefront
  /// catalog is the full active-parts list filtered client-side. Fine for a
  /// V1-sized catalog; revisit if this ever needs to scale to pagination.
  Future<List<PartListing>> getVendorListings(int vendorId) async {
    final all = await getParts();
    return all.where((p) => p.vendor.id == vendorId).toList();
  }

  /// Buyer sees their own orders; a vendor account additionally sees orders
  /// placed against their catalog (server-side filtering, same endpoint).
  Future<List<MarketplaceOrder>> getMyOrders() async {
    final response = await _apiClient.get('/marketplace/orders/');
    final rawList = asResponseList(response.data);
    return rawList
        .whereType<Map>()
        .map((j) => MarketplaceOrder.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  // ─────────────────────── VENDOR (own storefront) ───────────────────────

  /// Null if this account has no vendor profile yet (404 from the server).
  Future<VendorProfile?> getMyVendorProfile() async {
    try {
      final response = await _apiClient.get('/marketplace/vendors/me/');
      final raw = response.data['data'] ?? response.data;
      if (raw is! Map) return null;
      return VendorProfile.fromJson(raw.cast<String, dynamic>());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<VendorDashboard?> getVendorDashboard() async {
    try {
      final response = await _apiClient.get('/marketplace/vendors/dashboard/');
      final raw = response.data['data'] ?? response.data;
      if (raw is! Map) return null;
      return VendorDashboard.fromJson(raw.cast<String, dynamic>());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  // ─────────────────────── CATALOG MANAGEMENT ───────────────────────

  /// Uploads a local photo to the shared media store (same endpoint the
  /// chatbot attachments use) and returns its id, to include in
  /// [createPart]/[updatePart]'s `medias` list.
  Future<String?> uploadPartPhoto(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.uri.pathSegments.last),
    });
    final response = await _apiClient.postMultipart('/medias/', form);
    final data = response.data['data'] ?? response.data;
    return data is Map ? data['id']?.toString() : null;
  }

  Future<PartListing> createPart({
    required String title,
    required String description,
    required String condition,
    required double price,
    required int stockQuantity,
    required List<String> oemReferences,
    required List<String> mediaIds,
  }) async {
    final response = await _apiClient.post('/marketplace/parts/', data: {
      'title': title,
      'description': description,
      'condition': condition,
      'price': price,
      'stock_quantity': stockQuantity,
      'oem_references': oemReferences,
      'medias': mediaIds,
    });
    final raw = response.data['data'] ?? response.data;
    return PartListing.fromJson((raw as Map).cast<String, dynamic>());
  }

  Future<PartListing> updatePart({
    required int id,
    required String title,
    required String description,
    required String condition,
    required double price,
    required int stockQuantity,
    required List<String> oemReferences,
    required List<String> mediaIds,
    bool active = true,
  }) async {
    final response = await _apiClient.put('/marketplace/parts/$id/', data: {
      'title': title,
      'description': description,
      'condition': condition,
      'price': price,
      'stock_quantity': stockQuantity,
      'oem_references': oemReferences,
      'medias': mediaIds,
      'active': active,
    });
    final raw = response.data['data'] ?? response.data;
    return PartListing.fromJson((raw as Map).cast<String, dynamic>());
  }

  Future<void> deletePart(int id) async {
    await _apiClient.delete('/marketplace/parts/$id/');
  }
}
