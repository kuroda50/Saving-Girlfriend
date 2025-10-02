import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/tribute_history_state.dart';
import 'package:saving_girlfriend/providers/uuid_provider.dart';
import 'package:saving_girlfriend/repositories/tribute_history_repository.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'package:uuid/uuid.dart';

// TributeHistoryNotifier を提供する
final tributeHistoryProvider = StateNotifierProvider<TributeHistoryNotifier,
    AsyncValue<List<TributeHistoryState>>>((ref) {
  final repository = ref.watch(tributeHistoryRepositoryProvider.future);
  final uuid = ref.watch(uuidProvider);
  return TributeHistoryNotifier(repository, uuid);
});

// 貢ぎ履歴の状態を管理する StateNotifier
class TributeHistoryNotifier
    extends StateNotifier<AsyncValue<List<TributeHistoryState>>> {
  TributeHistoryNotifier(this._repositoryFuture, this._uuid)
      : super(const AsyncValue.loading()) {
    getTributionHistory();
  }

  final Future<TributeHistoryRepository> _repositoryFuture;
  final Uuid _uuid;

  // 履歴を非同期に読み込む
  Future<void> getTributionHistory() async {
    state = const AsyncValue.loading();
    try {
      final repository = await _repositoryFuture;
      final history = await repository.getTributionHistory();
      state = AsyncValue.data(history);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// 新しい貢ぎ物を追加する
  Future<void> add({
    required String character,
    required String itemName,
    required int amount,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newTribute = TributeHistoryState(
      id: _uuid,
      character: character,
      amount: amount,
      date: DateTime.now(),
    );

    final newState = [...currentState, newTribute];
    state = AsyncValue.data(newState);

    try {
      final repository = await _repositoryFuture;
      await repository.saveTributionHistory(newState);
    } catch (e) {
      state = AsyncValue.data(currentState);
      print('Failed to save tribute: $e');
    }
  }
}

final tributeHistoryRepositoryProvider =
    FutureProvider<TributeHistoryRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return TributeHistoryRepository(localStorageService);
});
