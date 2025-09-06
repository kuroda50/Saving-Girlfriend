import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

// --- ① UIに表示するデータ（お皿）の定義 ---
// この部分は generator を使う場合と全く同じです。
class TributeHistoryState {
  final List<Map<String, dynamic>> tributeHistory;
  final int targetSavingAmount;
  final int currentYear;
  final int currentMonth;
  final DateTime selectedDate; // ★追加: タップされた日付
  final List<Map<String, dynamic>> selectedDateTributes; // ★追加: タップされた日付の履歴

  TributeHistoryState({
    this.tributeHistory = const [],
    this.targetSavingAmount = 0,
    required this.currentYear,
    required this.currentMonth,
    required this.selectedDate,
    required this.selectedDateTributes,
  });

  TributeHistoryState copyWith({
    List<Map<String, dynamic>>? tributeHistory,
    int? targetSavingAmount,
    int? currentYear,
    int? currentMonth,
    DateTime? selectedDate,
    List<Map<String, dynamic>>? selectedDateTributes,
  }) {
    return TributeHistoryState(
      tributeHistory: tributeHistory ?? this.tributeHistory,
      targetSavingAmount: targetSavingAmount ?? this.targetSavingAmount,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateTributes: selectedDateTributes ?? this.selectedDateTributes,
    );
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// --- ② データを操作するロジック（お料理人）の定義 ---
class TributeHistoryNotifier extends AsyncNotifier<TributeHistoryState> {
  @override
  Future<TributeHistoryState> build() async {
    final localStorageService = LocalStorageService();
    final history = await localStorageService.getTributeHistory();
    final target = await localStorageService.getTargetSavingAmount() ?? 0;

    // ★buildメソッドで、今日の履歴を初期値として設定する
    final now = DateTime.now();
    final todaysTributes = history.where((tribute) {
      final tributeDate = DateTime.parse(tribute['date']);
      return tributeDate.year == now.year &&
          tributeDate.month == now.month &&
          tributeDate.day == now.day;
    }).toList();

    return TributeHistoryState(
      tributeHistory: history,
      targetSavingAmount: target,
      currentYear: now.year,
      currentMonth: now.month,
      selectedDate: now, // ★今日のデータを初期値に
      selectedDateTributes: todaysTributes, // ★今日の履歴を初期値に
    );
  }

  void changeMonth(int direction) {
    final currentState = state.value!;

    int newMonth = currentState.currentMonth + direction;
    int newYear = currentState.currentYear;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    state = AsyncData(currentState.copyWith(
      currentYear: newYear,
      currentMonth: newMonth,
    ));
  }

  Future<void> addTribute(Map<String, dynamic> newTribute) async {
    final localStorageService = ref.read(localStorageServiceProvider);
    final currentHistory =
        List<Map<String, dynamic>>.from(state.value!.tributeHistory);
    // ★ idがなければ付与する
    final tributeWithId = {
      ...newTribute,
      'id': newTribute['id'] ??
          'tribute_${DateTime.now().millisecondsSinceEpoch}',
    };

    currentHistory.add(tributeWithId);
    await localStorageService.saveTributeHistory(currentHistory);

    final newState = state.value!.copyWith(
      tributeHistory: currentHistory,
    );
    state = AsyncData(newState);
    selectDate(newState.selectedDate);
  }

  Future<void> updateTribute(
      String id, Map<String, dynamic> updatedTribute) async {
    final localStorageService = ref.read(localStorageServiceProvider);
    // state.value! で現在の状態（データ）を安全に取得
    final currentHistory =
        List<Map<String, dynamic>>.from(state.value!.tributeHistory);

    // 更新対象の履歴をIDで探す
    final index = currentHistory.indexWhere((tribute) => tribute['id'] == id);

    // もし見つかったら
    if (index != -1) {
      // 新しいデータで置き換える
      currentHistory[index] = updatedTribute;
      // 保存する
      await localStorageService.saveTributeHistory(currentHistory);

      // アプリの状態を更新して、画面に即時反映させる
      state = AsyncData(state.value!.copyWith(
        tributeHistory: currentHistory,
      ));
      // 選択中の日付のリストも更新する
      selectDate(state.value!.selectedDate);
    }
  }

  void selectDate(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    // 全履歴の中から、選択された日付と一致するものだけをフィルタリング
    final filteredTributes = currentState.tributeHistory.where((tribute) {
      final tributeDate = DateTime.parse(tribute['date']);
      return tributeDate.year == date.year &&
          tributeDate.month == date.month &&
          tributeDate.day == date.day;
    }).toList();

    // 状態を更新してUIに通知
    state = AsyncData(currentState.copyWith(
      selectedDate: date,
      selectedDateTributes: filteredTributes,
    ));
  }
}

// --- ③ Provider（メニュー表）の定義 ---
final tributeHistoryProvider =
    AsyncNotifierProvider<TributeHistoryNotifier, TributeHistoryState>(() {
  return TributeHistoryNotifier();
});

final selectedTributesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tributes = ref.watch(tributeHistoryProvider.select(
    (asyncState) => asyncState.value?.selectedDateTributes ?? [],
  ));
  return tributes;
});
