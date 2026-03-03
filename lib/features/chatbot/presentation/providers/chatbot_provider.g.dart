// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatbotRepositoryHash() => r'b3f7d35eac322b560e396f72018767744300920c';

/// See also [chatbotRepository].
@ProviderFor(chatbotRepository)
final chatbotRepositoryProvider =
    AutoDisposeProvider<ChatbotRepositoryImpl>.internal(
  chatbotRepository,
  name: r'chatbotRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatbotRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChatbotRepositoryRef = AutoDisposeProviderRef<ChatbotRepositoryImpl>;
String _$discussionsHash() => r'c095ec5e41a8b0b89b68c814fe4bc75e1e684b6f';

/// See also [Discussions].
@ProviderFor(Discussions)
final discussionsProvider = AutoDisposeAsyncNotifierProvider<Discussions,
    List<DiscussionModel>>.internal(
  Discussions.new,
  name: r'discussionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$discussionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Discussions = AutoDisposeAsyncNotifier<List<DiscussionModel>>;
String _$forumsHash() => r'235e402af21fb2abc8e1fe9ba1ec711151d120f6';

/// See also [Forums].
@ProviderFor(Forums)
final forumsProvider =
    AutoDisposeAsyncNotifierProvider<Forums, List<DiscussionModel>>.internal(
  Forums.new,
  name: r'forumsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$forumsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Forums = AutoDisposeAsyncNotifier<List<DiscussionModel>>;
String _$chatMessagesHash() => r'ed629f1905f966eae32ea17e9334af04b5956357';

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

abstract class _$ChatMessages
    extends BuildlessAutoDisposeAsyncNotifier<List<MessageModel>> {
  late final String discussionId;

  FutureOr<List<MessageModel>> build(
    String discussionId,
  );
}

/// See also [ChatMessages].
@ProviderFor(ChatMessages)
const chatMessagesProvider = ChatMessagesFamily();

/// See also [ChatMessages].
class ChatMessagesFamily extends Family<AsyncValue<List<MessageModel>>> {
  /// See also [ChatMessages].
  const ChatMessagesFamily();

  /// See also [ChatMessages].
  ChatMessagesProvider call(
    String discussionId,
  ) {
    return ChatMessagesProvider(
      discussionId,
    );
  }

  @override
  ChatMessagesProvider getProviderOverride(
    covariant ChatMessagesProvider provider,
  ) {
    return call(
      provider.discussionId,
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
  String? get name => r'chatMessagesProvider';
}

/// See also [ChatMessages].
class ChatMessagesProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChatMessages, List<MessageModel>> {
  /// See also [ChatMessages].
  ChatMessagesProvider(
    String discussionId,
  ) : this._internal(
          () => ChatMessages()..discussionId = discussionId,
          from: chatMessagesProvider,
          name: r'chatMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatMessagesHash,
          dependencies: ChatMessagesFamily._dependencies,
          allTransitiveDependencies:
              ChatMessagesFamily._allTransitiveDependencies,
          discussionId: discussionId,
        );

  ChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.discussionId,
  }) : super.internal();

  final String discussionId;

  @override
  FutureOr<List<MessageModel>> runNotifierBuild(
    covariant ChatMessages notifier,
  ) {
    return notifier.build(
      discussionId,
    );
  }

  @override
  Override overrideWith(ChatMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesProvider._internal(
        () => create()..discussionId = discussionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        discussionId: discussionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatMessages, List<MessageModel>>
      createElement() {
    return _ChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.discussionId == discussionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, discussionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatMessagesRef
    on AutoDisposeAsyncNotifierProviderRef<List<MessageModel>> {
  /// The parameter `discussionId` of this provider.
  String get discussionId;
}

class _ChatMessagesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatMessages,
        List<MessageModel>> with ChatMessagesRef {
  _ChatMessagesProviderElement(super.provider);

  @override
  String get discussionId => (origin as ChatMessagesProvider).discussionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
