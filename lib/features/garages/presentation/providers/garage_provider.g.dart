// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$garageRepositoryHash() => r'89122cbb6dd7492e5ed298b0e8abe3812604e8c5';

/// See also [garageRepository].
@ProviderFor(garageRepository)
final garageRepositoryProvider =
    AutoDisposeProvider<GarageRepositoryImpl>.internal(
  garageRepository,
  name: r'garageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$garageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GarageRepositoryRef = AutoDisposeProviderRef<GarageRepositoryImpl>;
String _$garageDetailHash() => r'3aef4f8adcd92b2636c0870b40bb2ec6db6f164a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [garageDetail].
@ProviderFor(garageDetail)
const garageDetailProvider = GarageDetailFamily();

/// See also [garageDetail].
class GarageDetailFamily extends Family<AsyncValue<GarageEntity?>> {
  /// See also [garageDetail].
  const GarageDetailFamily();

  /// See also [garageDetail].
  GarageDetailProvider call(
    String id,
  ) {
    return GarageDetailProvider(
      id,
    );
  }

  @override
  GarageDetailProvider getProviderOverride(
    covariant GarageDetailProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'garageDetailProvider';
}

/// See also [garageDetail].
class GarageDetailProvider extends AutoDisposeFutureProvider<GarageEntity?> {
  /// See also [garageDetail].
  GarageDetailProvider(
    String id,
  ) : this._internal(
          (ref) => garageDetail(
            ref as GarageDetailRef,
            id,
          ),
          from: garageDetailProvider,
          name: r'garageDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$garageDetailHash,
          dependencies: GarageDetailFamily._dependencies,
          allTransitiveDependencies:
              GarageDetailFamily._allTransitiveDependencies,
          id: id,
        );

  GarageDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<GarageEntity?> Function(GarageDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GarageDetailProvider._internal(
        (ref) => create(ref as GarageDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GarageEntity?> createElement() {
    return _GarageDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GarageDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GarageDetailRef on AutoDisposeFutureProviderRef<GarageEntity?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _GarageDetailProviderElement
    extends AutoDisposeFutureProviderElement<GarageEntity?>
    with GarageDetailRef {
  _GarageDetailProviderElement(super.provider);

  @override
  String get id => (origin as GarageDetailProvider).id;
}

String _$garagesAroundHash() => r'e390bc325df2a37273a8b8cb675b99c02ee8625f';

abstract class _$GaragesAround
    extends BuildlessAutoDisposeAsyncNotifier<List<GarageEntity>> {
  late final String key;

  FutureOr<List<GarageEntity>> build({
    String key = '',
  });
}

/// See also [GaragesAround].
@ProviderFor(GaragesAround)
const garagesAroundProvider = GaragesAroundFamily();

/// See also [GaragesAround].
class GaragesAroundFamily extends Family<AsyncValue<List<GarageEntity>>> {
  /// See also [GaragesAround].
  const GaragesAroundFamily();

  /// See also [GaragesAround].
  GaragesAroundProvider call({
    String key = '',
  }) {
    return GaragesAroundProvider(
      key: key,
    );
  }

  @override
  GaragesAroundProvider getProviderOverride(
    covariant GaragesAroundProvider provider,
  ) {
    return call(
      key: provider.key,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'garagesAroundProvider';
}

/// See also [GaragesAround].
class GaragesAroundProvider extends AutoDisposeAsyncNotifierProviderImpl<
    GaragesAround, List<GarageEntity>> {
  /// See also [GaragesAround].
  GaragesAroundProvider({
    String key = '',
  }) : this._internal(
          () => GaragesAround()..key = key,
          from: garagesAroundProvider,
          name: r'garagesAroundProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$garagesAroundHash,
          dependencies: GaragesAroundFamily._dependencies,
          allTransitiveDependencies:
              GaragesAroundFamily._allTransitiveDependencies,
          key: key,
        );

  GaragesAroundProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String key;

  @override
  FutureOr<List<GarageEntity>> runNotifierBuild(
    covariant GaragesAround notifier,
  ) {
    return notifier.build(
      key: key,
    );
  }

  @override
  Override overrideWith(GaragesAround Function() create) {
    return ProviderOverride(
      origin: this,
      override: GaragesAroundProvider._internal(
        () => create()..key = key,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GaragesAround, List<GarageEntity>>
      createElement() {
    return _GaragesAroundProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GaragesAroundProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GaragesAroundRef
    on AutoDisposeAsyncNotifierProviderRef<List<GarageEntity>> {
  /// The parameter `key` of this provider.
  String get key;
}

class _GaragesAroundProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<GaragesAround,
        List<GarageEntity>> with GaragesAroundRef {
  _GaragesAroundProviderElement(super.provider);

  @override
  String get key => (origin as GaragesAroundProvider).key;
}

String _$garageSearchHash() => r'f56186dee238245bfee829802b3bdb8ae2a83748';

/// See also [GarageSearch].
@ProviderFor(GarageSearch)
final garageSearchProvider =
    AutoDisposeAsyncNotifierProvider<GarageSearch, List<GarageEntity>>.internal(
  GarageSearch.new,
  name: r'garageSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$garageSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GarageSearch = AutoDisposeAsyncNotifier<List<GarageEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
