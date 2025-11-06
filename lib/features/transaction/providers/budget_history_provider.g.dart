// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../budget/providers/budget_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetHistoryHash() => r'8bc016975b9b770f02735df9c4c70e48cf66dea6';

/// 予算の変更履歴リストを提供するプロバイダー
///
/// Copied from [budgetHistory].
@ProviderFor(budgetHistory)
final budgetHistoryProvider = FutureProvider<List<BudgetHistory>>.internal(
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
typedef BudgetHistoryRef = FutureProviderRef<List<BudgetHistory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
