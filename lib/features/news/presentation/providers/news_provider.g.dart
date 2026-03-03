// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsRepositoryHash() => r'73f779f2c92b385a3edb53472c9074dee125839e';

/// See also [newsRepository].
@ProviderFor(newsRepository)
final newsRepositoryProvider = AutoDisposeProvider<NewsRepositoryImpl>.internal(
  newsRepository,
  name: r'newsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$newsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NewsRepositoryRef = AutoDisposeProviderRef<NewsRepositoryImpl>;
String _$newsDetailHash() => r'e5338b8d44dfa611ce28b9dced4d79d5771c0b83';

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

/// See also [newsDetail].
@ProviderFor(newsDetail)
const newsDetailProvider = NewsDetailFamily();

/// See also [newsDetail].
class NewsDetailFamily extends Family<AsyncValue<NewsEntity?>> {
  /// See also [newsDetail].
  const NewsDetailFamily();

  /// See also [newsDetail].
  NewsDetailProvider call(
    String id,
  ) {
    return NewsDetailProvider(
      id,
    );
  }

  @override
  NewsDetailProvider getProviderOverride(
    covariant NewsDetailProvider provider,
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
  String? get name => r'newsDetailProvider';
}

/// See also [newsDetail].
class NewsDetailProvider extends AutoDisposeFutureProvider<NewsEntity?> {
  /// See also [newsDetail].
  NewsDetailProvider(
    String id,
  ) : this._internal(
          (ref) => newsDetail(
            ref as NewsDetailRef,
            id,
          ),
          from: newsDetailProvider,
          name: r'newsDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$newsDetailHash,
          dependencies: NewsDetailFamily._dependencies,
          allTransitiveDependencies:
              NewsDetailFamily._allTransitiveDependencies,
          id: id,
        );

  NewsDetailProvider._internal(
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
    FutureOr<NewsEntity?> Function(NewsDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NewsDetailProvider._internal(
        (ref) => create(ref as NewsDetailRef),
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
  AutoDisposeFutureProviderElement<NewsEntity?> createElement() {
    return _NewsDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NewsDetailRef on AutoDisposeFutureProviderRef<NewsEntity?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _NewsDetailProviderElement
    extends AutoDisposeFutureProviderElement<NewsEntity?> with NewsDetailRef {
  _NewsDetailProviderElement(super.provider);

  @override
  String get id => (origin as NewsDetailProvider).id;
}

String _$newsListHash() => r'1cb846dbc327904692df7117aad94a7511389de5';

/// See also [NewsList].
@ProviderFor(NewsList)
final newsListProvider =
    AutoDisposeAsyncNotifierProvider<NewsList, List<NewsEntity>>.internal(
  NewsList.new,
  name: r'newsListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$newsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NewsList = AutoDisposeAsyncNotifier<List<NewsEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
