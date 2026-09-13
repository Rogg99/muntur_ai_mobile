import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories_impl/marketplace_repository_impl.dart';

// Plain (non-generated) Riverpod providers — no build_runner available in
// this environment, so these deliberately skip the @riverpod codegen
// pattern used elsewhere (garage_provider.dart etc).

final marketplaceRepositoryProvider = Provider<MarketplaceRepositoryImpl>(
  (ref) => MarketplaceRepositoryImpl(ApiClient()),
);

/// Keyed by the search text itself rather than a shared StateProvider —
/// the main Marketplace tab (always mounted, embedded in HomeScreen's
/// IndexedStack) and the standalone screen pushed from chat's "Pièces
/// compatibles" shortcut used to both read/write one global search
/// provider, so using the shortcut once left the tab permanently filtered
/// by that leftover query (looked like "the catalogue doesn't load").
/// Each MarketplaceHome instance now owns its own search text locally.
/// Best-effort, last-known fix only — never blocks the catalogue on
/// acquiring a fresh GPS lock or a permission prompt. Feeds distance
/// sort/display in [marketplacePartsProvider]; absence just means no
/// distance annotation, not an error.
final marketplaceLastKnownPositionProvider = FutureProvider.autoDispose<Position?>((ref) async {
  try {
    return await Geolocator.getLastKnownPosition();
  } catch (_) {
    return null;
  }
});

final marketplacePartsProvider =
    FutureProvider.autoDispose.family<List<PartListing>, String>((ref, search) async {
  final position = await ref.watch(marketplaceLastKnownPositionProvider.future);
  return ref.read(marketplaceRepositoryProvider).getParts(
        search: search,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
});

final marketplacePartDetailProvider =
    FutureProvider.autoDispose.family<PartListing?, String>((ref, id) {
  return ref.read(marketplaceRepositoryProvider).getPartDetail(id);
});

final marketplaceVendorProvider =
    FutureProvider.autoDispose.family<VendorProfile?, String>((ref, id) {
  return ref.read(marketplaceRepositoryProvider).getVendor(id);
});

final marketplaceVendorListingsProvider =
    FutureProvider.autoDispose.family<List<PartListing>, String>((ref, vendorId) {
  return ref.read(marketplaceRepositoryProvider).getVendorListings(vendorId);
});

final marketplaceMyOrdersProvider = FutureProvider.autoDispose<List<MarketplaceOrder>>((ref) {
  return ref.read(marketplaceRepositoryProvider).getMyOrders();
});

final marketplaceOrderDetailProvider =
    FutureProvider.autoDispose.family<MarketplaceOrder, String>((ref, id) {
  return ref.read(marketplaceRepositoryProvider).getOrderDetail(id);
});

/// Null when this account has no vendor storefront yet.
final marketplaceMyVendorProvider = FutureProvider.autoDispose<VendorProfile?>((ref) {
  return ref.read(marketplaceRepositoryProvider).getMyVendorProfile();
});

final marketplaceVendorDashboardProvider =
    FutureProvider.autoDispose<VendorDashboard?>((ref) {
  return ref.read(marketplaceRepositoryProvider).getVendorDashboard();
});

final marketplaceWishlistProvider = FutureProvider.autoDispose<List<WishlistItem>>((ref) {
  return ref.read(marketplaceRepositoryProvider).getWishlist();
});

/// Convenience lookup for a single part's "is this saved?" heart state,
/// derived from the shared wishlist fetch rather than a separate request
/// per part card.
final marketplaceIsWishlistedProvider =
    Provider.autoDispose.family<bool, String>((ref, partId) {
  final wishlist = ref.watch(marketplaceWishlistProvider).valueOrNull ?? const [];
  return wishlist.any((w) => w.partListing.id == partId);
});
