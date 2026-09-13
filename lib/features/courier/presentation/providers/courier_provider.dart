import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/courier_models.dart';
import '../../data/repositories_impl/courier_repository_impl.dart';

final courierRepositoryProvider = Provider<CourierRepositoryImpl>(
  (ref) => CourierRepositoryImpl(ApiClient()),
);

/// Null when this account has no courier profile yet.
final myCourierProfileProvider = FutureProvider.autoDispose<CourierProfile?>((ref) {
  return ref.read(courierRepositoryProvider).getMyCourierProfile();
});

final availableDeliveriesProvider = FutureProvider.autoDispose<List<Delivery>>((ref) {
  return ref.read(courierRepositoryProvider).getAvailableDeliveries();
});

final myDeliveriesProvider = FutureProvider.autoDispose<List<Delivery>>((ref) {
  return ref.read(courierRepositoryProvider).getMyDeliveries();
});

final deliveryDetailProvider =
    FutureProvider.autoDispose.family<Delivery, String>((ref, id) {
  return ref.read(courierRepositoryProvider).getDeliveryDetail(id);
});
