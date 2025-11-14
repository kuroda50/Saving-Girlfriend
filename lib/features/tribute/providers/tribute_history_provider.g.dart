// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tribute_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tributeHistoryRepositoryHash() =>
    r'3c2a164faeed3a56a94571fbbd934d46dceff8a0';

/// See also [tributeHistoryRepository].
@ProviderFor(tributeHistoryRepository)
final tributeHistoryRepositoryProvider =
    Provider<TributeHistoryRepository>.internal(
  tributeHistoryRepository,
  name: r'tributeHistoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tributeHistoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TributeHistoryRepositoryRef = ProviderRef<TributeHistoryRepository>;
String _$tributeAppDatabaseHash() =>
    r'd9163e60bc8bfd0f99383db9c0ecc1b13ee730d9';

/// See also [tributeAppDatabase].
@ProviderFor(tributeAppDatabase)
final tributeAppDatabaseProvider = Provider<db.TributeAppDatabase>.internal(
  tributeAppDatabase,
  name: r'tributeAppDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tributeAppDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TributeAppDatabaseRef = ProviderRef<db.TributeAppDatabase>;
String _$tributeHistoryHash() => r'6f8c842e7eeda409de1d1c933d9a7a8fbf57303c';

/// See also [TributeHistory].
@ProviderFor(TributeHistory)
final tributeHistoryProvider =
    AsyncNotifierProvider<TributeHistory, List<TributeState>>.internal(
  TributeHistory.new,
  name: r'tributeHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tributeHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TributeHistory = AsyncNotifier<List<TributeState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
