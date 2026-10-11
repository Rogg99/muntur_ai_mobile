import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/repair_models.dart';
import '../../data/repositories_impl/repair_repository_impl.dart';

final repairRepositoryProvider = Provider<RepairRepositoryImpl>(
  (ref) => RepairRepositoryImpl(ApiClient()),
);

/// Null when this account has no garage-staff profile yet.
final myGarageStaffProfileProvider =
    FutureProvider.autoDispose<GarageStaffProfile?>((ref) {
  return ref.read(repairRepositoryProvider).getMyGarageStaffProfile();
});

final garageRepairDashboardProvider =
    FutureProvider.autoDispose<List<RepairBooking>>((ref) {
  return ref.read(repairRepositoryProvider).getGarageDashboard();
});

final myRepairBookingsProvider =
    FutureProvider.autoDispose<List<RepairBooking>>((ref) {
  return ref.read(repairRepositoryProvider).getMyBookings();
});

final repairBookingDetailProvider =
    FutureProvider.autoDispose.family<RepairBooking, String>((ref, id) {
  return ref.read(repairRepositoryProvider).getBookingDetail(id);
});
