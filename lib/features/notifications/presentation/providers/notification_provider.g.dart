// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRepositoryHash() =>
    r'540baffad44b196b61932ad77488f36107d12979';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepositoryImpl>.internal(
  notificationRepository,
  name: r'notificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationRepositoryRef
    = AutoDisposeProviderRef<NotificationRepositoryImpl>;
String _$notificationsListHash() => r'935c963351d9bfca962463944efe918bdb026884';

/// See also [NotificationsList].
@ProviderFor(NotificationsList)
final notificationsListProvider = AutoDisposeAsyncNotifierProvider<
    NotificationsList, List<NotificationEntity>>.internal(
  NotificationsList.new,
  name: r'notificationsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsList
    = AutoDisposeAsyncNotifier<List<NotificationEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
