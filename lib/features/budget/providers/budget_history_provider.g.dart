// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'3d3a397d2ea952fc020fce0506793a5564e93530';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$budgetHistoryRepositoryHash() =>
    r'990d9f02dcc661907e3b0469fe2faa52b09e6c5a';

/// See also [budgetHistoryRepository].
@ProviderFor(budgetHistoryRepository)
final budgetHistoryRepositoryProvider =
    Provider<BudgetHistoryRepository>.internal(
  budgetHistoryRepository,
  name: r'budgetHistoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetHistoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetHistoryRepositoryRef = ProviderRef<BudgetHistoryRepository>;
String _$budgetHistoryHash() => r'5df433bdd3d1f71f6cb191a80b6b51036aa403d2';

/// See also [budgetHistory].
@ProviderFor(budgetHistory)
final budgetHistoryProvider =
    AutoDisposeFutureProvider<List<BudgetHistory>>.internal(
  budgetHistory,
  name: r'budgetHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetHistoryRef = AutoDisposeFutureProviderRef<List<BudgetHistory>>;
String _$currentDailyBudgetHash() =>
    r'c86a649c439584134d941069eb3b30c61dfbad8e';

/// See also [currentDailyBudget].
@ProviderFor(currentDailyBudget)
final currentDailyBudgetProvider = AutoDisposeFutureProvider<int>.internal(
  currentDailyBudget,
  name: r'currentDailyBudgetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentDailyBudgetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentDailyBudgetRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
