import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories_impl/marketplace_repository_impl.dart';

// Plain (non-generated) Riverpod providers — no build_runner available in
// this environment, so these deliberately skip the @riverpod codegen
// pattern used elsewhere (garage_provider.dart etc).

final marketplaceRepositoryProvider = Provider<MarketplaceRepositoryImpl>(
  (ref) => MarketplaceRepositoryImpl(ApiClient()),
);

/// Search text driving [marketplacePartsProvider] — set from the search bar.
final marketplaceSearchProvider = StateProvider<String>((ref) => '');

final marketplacePartsProvider = FutureProvider.autoDispose<List<PartListing>>((ref) {
  final search = ref.watch(marketplaceSearchProvider);
  return ref.read(marketplaceRepositoryProvider).getParts(search: search);
});

final marketplacePartDetailProvider =
    FutureProvider.autoDispose.family<PartListing?, int>((ref, id) {
  return ref.read(marketplaceRepositoryProvider).getPartDetail(id);
});

final marketplaceVendorProvider =
    FutureProvider.autoDispose.family<VendorProfile?, int>((ref, id) {
  return ref.read(marketplaceRepositoryProvider).getVendor(id);
});

final marketplaceVendorListingsProvider =
    FutureProvider.autoDispose.family<List<PartListing>, int>((ref, vendorId) {
  return ref.read(marketplaceRepositoryProvider).getVendorListings(vendorId);
});

final marketplaceMyOrdersProvider = FutureProvider.autoDispose<List<MarketplaceOrder>>((ref) {
  return ref.read(marketplaceRepositoryProvider).getMyOrders();
});
