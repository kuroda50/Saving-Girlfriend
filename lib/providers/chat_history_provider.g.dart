// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatHistoryNotifierHash() =>
    r'5f1a19fd0e0aec6554d4f129aae74eed909e2501';

/// See also [ChatHistoryNotifier].
@ProviderFor(ChatHistoryNotifier)
final chatHistoryNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ChatHistoryNotifier, List<Message>>.internal(
  ChatHistoryNotifier.new,
  name: r'chatHistoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatHistoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatHistoryNotifier = AutoDisposeAsyncNotifier<List<Message>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
