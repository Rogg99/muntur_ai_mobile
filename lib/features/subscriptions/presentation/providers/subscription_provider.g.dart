// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionRepositoryHash() =>
    r'198f72daca8926c3a56d8715f016398d4aeba334';

/// See also [subscriptionRepository].
@ProviderFor(subscriptionRepository)
final subscriptionRepositoryProvider =
    AutoDisposeProvider<SubscriptionRepositoryImpl>.internal(
  subscriptionRepository,
  name: r'subscriptionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionRepositoryRef
    = AutoDisposeProviderRef<SubscriptionRepositoryImpl>;
String _$subscriptionPlansHash() => r'a02bea4a3831fdbb4922a787851818406d24b691';

/// See also [subscriptionPlans].
@ProviderFor(subscriptionPlans)
final subscriptionPlansProvider =
    AutoDisposeFutureProvider<List<SubscriptionPlanEntity>>.internal(
  subscriptionPlans,
  name: r'subscriptionPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionPlansRef
    = AutoDisposeFutureProviderRef<List<SubscriptionPlanEntity>>;
String _$coinsBalanceHash() => r'2a33b3dd2cc9a7fa1f66ea4985527da3b38d6131';

/// See also [coinsBalance].
@ProviderFor(coinsBalance)
final coinsBalanceProvider = AutoDisposeFutureProvider<int>.internal(
  coinsBalance,
  name: r'coinsBalanceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$coinsBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CoinsBalanceRef = AutoDisposeFutureProviderRef<int>;
String _$currentSubscriptionHash() =>
    r'758e3fea3fc0518c6e7ea3961d8f801651752ac2';

/// See also [CurrentSubscription].
@ProviderFor(CurrentSubscription)
final currentSubscriptionProvider = AutoDisposeAsyncNotifierProvider<
    CurrentSubscription, SubscriptionEntity?>.internal(
  CurrentSubscription.new,
  name: r'currentSubscriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSubscriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentSubscription = AutoDisposeAsyncNotifier<SubscriptionEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
