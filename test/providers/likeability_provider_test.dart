// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Project imports:
import 'package:saving_girlfriend/app/providers/likeability_provider.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';
import 'package:saving_girlfriend/features/tribute/providers/tribute_history_provider.dart';

void main() {
  group('likeabilityProvider', () {
    test('履歴が何もないケース', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider.overrideWith(() => FakeTributeHistory([])),
        ],
      );

      // Act
      final result = await container.read(likeabilityProvider.future);

      // Assert
      expect(result, 0);
    });

    test('序盤の好感度計算（10,000円未満）', () async {
      // Arrange
      final tributeHistory = [
        TributeState(
            id: '1',
            date: DateTime.now(),
            amount: 5000,
            character: 'Girlfriend'),
      ];
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistory(tributeHistory)),
        ],
      );

      // Act
      final result = await container.read(likeabilityProvider.future);

      // Assert
      // (5000 / 10000) * 10 = 5
      expect(result, 5);
    });

    test('序盤の好感度計算（10,000円以上30,000円未満）', () async {
      // Arrange
      final tributeHistory = [
        TributeState(
            id: '1',
            date: DateTime.now(),
            amount: 20000,
            character: 'Girlfriend'),
      ];
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistory(tributeHistory)),
        ],
      );

      // Act
      final result = await container.read(likeabilityProvider.future);

      // Assert
      // 10 + ((20000 - 10000) / 20000) * 10 = 15
      expect(result, 15);
    });

    test('序盤の好感度計算（30,000円以上60,000円未満）', () async {
      // Arrange
      final tributeHistory = [
        TributeState(
            id: '1',
            date: DateTime.now(),
            amount: 45000,
            character: 'Girlfriend'),
      ];
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistory(tributeHistory)),
        ],
      );

      // Act
      final result = await container.read(likeabilityProvider.future);

      // Assert
      // 20 + ((45000 - 30000) / 30000) * 10 = 25
      expect(result, 25);
    });

    test('中盤以降の好感度計算（60,000円以上）', () async {
      // Arrange
      final tributeHistory = [
        TributeState(
            id: '1',
            date: DateTime.now(),
            amount: 70000,
            character: 'Girlfriend'),
      ];
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistory(tributeHistory)),
        ],
      );

      // Act
      final result = await container.read(likeabilityProvider.future);

      // Assert
      // 30 + (70000 - 60000) / 10000 = 31
      expect(result, 31);
    });

    test('複数の貢ぎ履歴があるケース', () async {
      // Arrange
      final tributeHistory = [
        TributeState(
            id: '1',
            date: DateTime.now(),
            amount: 5000,
            character: 'Girlfriend'),
        TributeState(
            id: '2',
            date: DateTime.now(),
            amount: 15000,
            character: 'Girlfriend'),
        TributeState(
            id: '3',
            date: DateTime.now(),
            amount: 40000,
            character: 'Girlfriend'),
      ];
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistory(tributeHistory)),
        ],
      );

      // Act
      final result = await container.read(likeabilityProvider.future);

      // Assert
      // totalTribute = 60000
      // 30 + (60000 - 60000) / 10000 = 30
      expect(result, 30);
    });

    test('tributeHistoryProviderがloading状態のケース', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistoryLoading()),
        ],
      );

      // Act
      final result = container.read(likeabilityProvider);

      // Assert
      expect(result, const AsyncValue<int>.loading());
    });

    test('tributeHistoryProviderがerror状態のケース', () async {
      // Arrange
      final error = Exception('Test Error');
      final stackTrace = StackTrace.current;
      final container = ProviderContainer(
        overrides: [
          tributeHistoryProvider
              .overrideWith(() => FakeTributeHistoryError(error, stackTrace)),
        ],
      );

      // Act
      // Assert
      await expectLater(
        container.read(likeabilityProvider.future),
        throwsA(error),
      );
    });
  });
}

// Fakes
class FakeTributeHistory extends TributeHistory {
  final List<TributeState> _initialValue;
  FakeTributeHistory(this._initialValue);

  @override
  Future<List<TributeState>> build() => Future.value(_initialValue);
}

class FakeTributeHistoryLoading extends TributeHistory {
  @override
  Future<List<TributeState>> build() => Completer<List<TributeState>>().future;
}

class FakeTributeHistoryError extends TributeHistory {
  final Object error;
  final StackTrace stackTrace;

  FakeTributeHistoryError(this.error, this.stackTrace);

  @override
  Future<List<TributeState>> build() => Future.error(error, stackTrace);
}
