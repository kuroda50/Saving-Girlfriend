import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/models/tribute_history_state.dart';
import 'package:saving_girlfriend/providers/uuid_provider.dart';
import 'package:saving_girlfriend/repositories/tribute_history_repository.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

part 'tribute_history_provider.g.dart';

@Riverpod(keepAlive: true)
class TributeHistory extends _$TributeHistory {
  // buildメソッドで初期データを非同期に取得する
  @override
  Future<List<TributeState>> build() async {
    final repository = await ref.watch(tributeHistoryRepositoryProvider.future);
    // 初期データをリポジトリから取得して返すだけ
    return repository.getTributionHistory();
  }

  /// 新しい貢ぎ物を追加する
  Future<void> add({
    required String character,
    required int amount,
  }) async {
    final repository = await ref.read(tributeHistoryRepositoryProvider.future);

    final newTribute = TributeState(
      id: ref.read(uuidProvider).v4(), // uuidのインスタンスから新しいIDを生成
      character: character,
      date: DateTime.now(),
      amount: amount,
    );

    // 現在の状態を取得
    final previousState = await future;

    // 新しい状態リストを作成
    final newState = [...previousState, newTribute];

    // UIを即座に更新（オプティミスティックUI）
    state = AsyncValue.data(newState);

    // 永続化処理
    try {
      await repository.saveTributionHistory(newState);
    } catch (e, s) {
      // 保存に失敗した場合、UIの状態を元に戻し、エラー状態にする
      state = AsyncValue.error(e, s);
    }
  }
}

final tributeHistoryRepositoryProvider =
    FutureProvider<TributeHistoryRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return TributeHistoryRepository(localStorageService);
});
