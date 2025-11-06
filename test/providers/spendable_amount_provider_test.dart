// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saving_girlfriend/app/providers/spendable_amount_provider.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/providers/transaction_history_provider.dart';
// Project imports:
import 'package:saving_girlfriend/models/budget_history.dart';
import 'package:saving_girlfriend/models/tribute_history_state.dart';
import 'package:saving_girlfriend/providers/budget_history_provider.dart';
import 'package:saving_girlfriend/providers/tribute_history_provider.dart';

void main() {
  group('spendableAmountProvider', () {
    test('履歴が何もないケース', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider.overrideWith((ref) => Future.value([])),
          transactionsProvider.overrideWith(() => TransactionsNotifierFake([])),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      // Act
      final result = await container.read(spendableAmountProvider.future);

      // Assert
      expect(result, 0);
    });

    test('予算履歴のみがあるケース', () async {
      // Arrange
      final budgetHistory = [
        BudgetHistory(
          date: DateTime.now().subtract(const Duration(days: 10)),
          amount: 1000,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider.overrideWith(() => TransactionsNotifierFake([])),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      // Act
      final result = await container.read(spendableAmountProvider.future);

      // Assert
      // 支出がない日は貯金が0になるため、10日経っても0のまま
      expect(result, 0);
    });

    test('基本的な予算履歴、取引履歴、貢ぎ履歴があるケース', () async {
      // Arrange
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 2)), amount: 1000),
      ];
      final transactionList = [
        TransactionState(
          id: '1',
          date: now.subtract(const Duration(days: 1)),
          amount: 500,
          type: 'expense',
          category: 'Lunch',
        ),
      ];
      final tributeHistory = [
        TributeState(
          id: '1',
          date: now,
          amount: 200,
          character: 'Girlfriend',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider
              .overrideWith(() => TributeHistoryFake(tributeHistory)),
        ],
      );

      // Act
      final result = await container.read(spendableAmountProvider.future);

      // Assert
      // Day 1: budget 1000, no expense -> carry over 0
      // Day 2: budget 1000, expense 500 -> carry over 500
      // Cumulative: 0 + 500 = 500
      // Tributes: 200
      // Final: 500 - 200 = 300
      expect(result, 300);
    });

    test('複数の予算期間をまたぐケース', () async {
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 5)), amount: 1000),
        BudgetHistory(
            date: now.subtract(const Duration(days: 2)), amount: 2000),
      ];
      final transactionList = [
        TransactionState(
            id: '1',
            date: now.subtract(const Duration(days: 4)),
            amount: 500,
            type: 'expense',
            category: 'test'),
        TransactionState(
            id: '2',
            date: now.subtract(const Duration(days: 1)),
            amount: 800,
            type: 'expense',
            category: 'test'),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      final result = await container.read(spendableAmountProvider.future);

      // Day(now-4): budget 1000, expense 500 -> carry-over 500. cumulative = 500.
      // Day(now-3): budget 1000, no expense -> carry-over 0. cumulative = 500.
      // Day(now-2): budget 2000, no expense -> carry-over 0. cumulative = 500.
      // Day(now-1): budget 2000, expense 800 -> carry-over 1200. cumulative = 500 + 1200 = 1700.
      expect(result, 1700);
    });

    test('支出が予算を超えたケース', () async {
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 2)), amount: 1000),
      ];
      final transactionList = [
        TransactionState(
            id: '1',
            date: now.subtract(const Duration(days: 1)),
            amount: 1200,
            type: 'expense',
            category: 'test'),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      final result = await container.read(spendableAmountProvider.future);

      // Day(now-1): budget 1000, expense 1200 -> dailyAvailable -200 -> clamp gives 0. cumulative = 0.
      expect(result, 0);
    });

    test('同日に複数の取引があるケース', () async {
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 2)), amount: 1000),
      ];
      final transactionList = [
        TransactionState(
            id: '1',
            date: now.subtract(const Duration(days: 1)),
            amount: 500,
            type: 'expense',
            category: 'test'),
        TransactionState(
            id: '2',
            date: now.subtract(const Duration(days: 1)),
            amount: 300,
            type: 'expense',
            category: 'test'),
        TransactionState(
            id: '3',
            date: now.subtract(const Duration(days: 1)),
            amount: 200,
            type: 'income',
            category: 'test'),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      final result = await container.read(spendableAmountProvider.future);

      // Day(now-1): budget 1000, net expense 500+300-200=600 -> dailyAvailable 400 -> carry-over 400.
      expect(result, 400);
    });

    test('取引がない日を挟むケース', () async {
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 4)), amount: 1000),
      ];
      final transactionList = [
        TransactionState(
            id: '1',
            date: now.subtract(const Duration(days: 3)),
            amount: 200,
            type: 'expense',
            category: 'test'),
        TransactionState(
            id: '2',
            date: now.subtract(const Duration(days: 1)),
            amount: 400,
            type: 'expense',
            category: 'test'),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      final result = await container.read(spendableAmountProvider.future);

      // Day(now-3): budget 1000, expense 200 -> carry-over 800. cumulative = 800.
      // Day(now-2): budget 1000, no expense -> carry-over 0. cumulative = 800.
      // Day(now-1): budget 1000, expense 400 -> carry-over 600. cumulative = 800 + 600 = 1400.
      expect(result, 1400);
    });

    test('収入の計算が仕様通り行われるかのケース（上限あり）', () async {
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 2)), amount: 1000),
      ];
      final transactionList = [
        TransactionState(
            id: '1',
            date: now.subtract(const Duration(days: 1)),
            amount: 5000,
            type: 'income',
            category: 'test'),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      final result = await container.read(spendableAmountProvider.future);

      // Day(now-1): budget 1000, net expense -5000 -> dailyAvailable 6000 -> clamp(6000, 1000) is 1000.
      expect(result, 1000);
    });

    test('予算設定日と支出日が同日のケース', () async {
      final now = DateTime.now();
      final budgetHistory = [
        BudgetHistory(
            date: now.subtract(const Duration(days: 1)), amount: 1000),
      ];
      final transactionList = [
        TransactionState(
            id: '1',
            date: now.subtract(const Duration(days: 1)),
            amount: 400,
            type: 'expense',
            category: 'test'),
      ];

      final container = ProviderContainer(
        overrides: [
          budgetHistoryProvider
              .overrideWith((ref) => Future.value(budgetHistory)),
          transactionsProvider
              .overrideWith(() => TransactionsNotifierFake(transactionList)),
          tributeHistoryProvider.overrideWith(() => TributeHistoryFake([])),
        ],
      );

      final result = await container.read(spendableAmountProvider.future);

      // Day(now-1): budget 1000, expense 400 -> carry-over 600.
      expect(result, 600);
    });
  });
}

class TransactionsNotifierFake extends TransactionsNotifier {
  final List<TransactionState> _state;

  TransactionsNotifierFake(this._state);

  @override
  Future<List<TransactionState>> build() => Future.value(_state);
}

class TributeHistoryFake extends TributeHistory {
  final List<TributeState> _state;

  TributeHistoryFake(this._state);

  @override
  Future<List<TributeState>> build() => Future.value(_state);
}
