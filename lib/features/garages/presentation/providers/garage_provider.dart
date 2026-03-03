import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/garage_entity.dart';
import '../../data/repositories_impl/garage_repository_impl.dart';
import '../../../../core/network/api_client.dart';

part 'garage_provider.g.dart';

// ── Repository provider ──────────────────────────────────────────────────────

@riverpod
GarageRepositoryImpl garageRepository(GarageRepositoryRef ref) {
  return GarageRepositoryImpl(ApiClient());
}

// ── Garages around current location ─────────────────────────────────────────

@riverpod
class GaragesAround extends _$GaragesAround {
  @override
  FutureOr<List<GarageEntity>> build({String key = ''}) async {
    return ref.read(garageRepositoryProvider).getGaragesAround(key: key);
  }

  Future<void> refresh({String key = ''}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(garageRepositoryProvider).getGaragesAround(key: key));
  }
}

// ── Garage detail ────────────────────────────────────────────────────────────

@riverpod
Future<GarageEntity?> garageDetail(GarageDetailRef ref, String id) {
  return ref.read(garageRepositoryProvider).getGarageDetail(id);
}

// ── Search provider ──────────────────────────────────────────────────────────

@riverpod
class GarageSearch extends _$GarageSearch {
  @override
  FutureOr<List<GarageEntity>> build() async => [];

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(garageRepositoryProvider).searchGarages(query));
  }
}
