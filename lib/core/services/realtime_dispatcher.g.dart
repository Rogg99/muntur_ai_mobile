// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_dispatcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$realtimeDispatcherHash() =>
    r'7b2a4876ef3dae11f8fe5cc82c91cba4cb9a74d5';

/// Wires [WebSocketService] events to the Riverpod caches that render them, so
/// discussions/forums/notifications/subscriptions update live instead of
/// waiting for the next pull-to-refresh or app restart. Started from
/// [AuthState.login]/app startup and left running for the whole session — see
/// [WebSocketService] lifecycle wiring in auth_provider.dart.
///
/// Copied from [RealtimeDispatcher].
@ProviderFor(RealtimeDispatcher)
final realtimeDispatcherProvider =
    NotifierProvider<RealtimeDispatcher, void>.internal(
  RealtimeDispatcher.new,
  name: r'realtimeDispatcherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeDispatcherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RealtimeDispatcher = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
