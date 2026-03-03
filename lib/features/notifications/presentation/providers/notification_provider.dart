import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/repositories_impl/notification_repository_impl.dart';
import '../../../../core/network/api_client.dart';

part 'notification_provider.g.dart';

@riverpod
NotificationRepositoryImpl notificationRepository(
        NotificationRepositoryRef ref) =>
    NotificationRepositoryImpl(ApiClient());

@riverpod
class NotificationsList extends _$NotificationsList {
  @override
  FutureOr<List<NotificationEntity>> build() async =>
      ref.read(notificationRepositoryProvider).getNotifications();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(notificationRepositoryProvider).getNotifications());
  }

  Future<void> markAsRead(String id) async {
    final current = state.valueOrNull ?? [];
    final success =
        await ref.read(notificationRepositoryProvider).markAsRead(id);
    if (success) {
      state = AsyncValue.data(
        current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    final success =
        await ref.read(notificationRepositoryProvider).markAllAsRead();
    if (success) {
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
          current.map((n) => n.copyWith(isRead: true)).toList());
    }
  }

  int get unreadCount =>
      (state.valueOrNull ?? []).where((n) => !n.isRead).length;
}
