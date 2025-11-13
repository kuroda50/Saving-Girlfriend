// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:saving_girlfriend/common/providers/uuid_provider.dart';
import 'package:saving_girlfriend/features/tribute/data/local/database.dart'
    as db;
import 'package:saving_girlfriend/features/tribute/data/repositories/drift_tribute_history_repository.dart';
import 'package:saving_girlfriend/features/tribute/domain/repositories/tribute_history_repository.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';

part 'tribute_history_provider.g.dart';

@Riverpod(keepAlive: true)
TributeHistoryRepository tributeHistoryRepository(
    TributeHistoryRepositoryRef ref) {
  final database = ref.watch(tributeAppDatabaseProvider);
  return DriftTributeHistoryRepository(database);
}

@Riverpod(keepAlive: true)
db.TributeAppDatabase tributeAppDatabase(TributeAppDatabaseRef ref) {
  return db.TributeAppDatabase();
}

@Riverpod(keepAlive: true)
class TributeHistory extends _$TributeHistory {
  @override
  Future<List<TributeState>> build() async {
    // Repository is now provided synchronously
    final repository = ref.watch(tributeHistoryRepositoryProvider);
    return repository.getTributionHistory();
  }

  /// 新しい貢ぎ物を追加する
  Future<void> add({
    required String character,
    required int amount,
  }) async {
    // Repository is now provided synchronously
    final repository = ref.read(tributeHistoryRepositoryProvider);

    final newTribute = TributeState(
      id: ref.read(uuidProvider).v4(),
      character: character,
      date: DateTime.now(),
      amount: amount,
    );

    final previousState = await future;
    final newState = [...previousState, newTribute];

    state = AsyncValue.data(newState);

    try {
      // The interface remains the same, so this call is still valid.
      await repository.saveTributionHistory(newState);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      // Optionally, revert to previous state
      // state = AsyncValue.data(previousState);
    }
  }
}
