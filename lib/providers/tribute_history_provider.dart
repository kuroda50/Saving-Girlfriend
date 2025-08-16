import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/providers/home_screen_provider.dart';

// --- ① UIに表示するデータ（お皿）の定義 ---
// この部分は generator を使う場合と全く同じです。
class TributeHistoryState {
  final List<Map<String, dynamic>> tributeHistory;
  final int targetSavingAmount;
  final int currentYear;
  final int currentMonth;

  TributeHistoryState({
    this.tributeHistory = const [],
    this.targetSavingAmount = 0,
    required this.currentYear,
    required this.currentMonth,
  });

  TributeHistoryState copyWith({
    List<Map<String, dynamic>>? tributeHistory,
    int? targetSavingAmount,
    int? currentYear,
    int? currentMonth,
  }) {
    return TributeHistoryState(
      tributeHistory: tributeHistory ?? this.tributeHistory,
      targetSavingAmount: targetSavingAmount ?? this.targetSavingAmount,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }
}

// --- ② データを操作するロジック（お料理人）の定義 ---
// `extends _$TributeHistory` ではなく `extends AsyncNotifier<TributeHistoryState>` と書きます。
class TributeHistoryNotifier extends AsyncNotifier<TributeHistoryState> {
  // buildメソッドの中身は全く同じです。
  @override
  Future<TributeHistoryState> build() async {
    final localStorageService = ref.watch(localStorageServiceProvider);
    final history = await localStorageService.getTributeHistory();
    final target = await localStorageService.getTargetSavingAmount() ?? 0;

    return TributeHistoryState(
      tributeHistory: history,
      targetSavingAmount: target,
      currentYear: DateTime.now().year,
      currentMonth: DateTime.now().month,
    );
  }

  // 他のメソッド（changeMonth, addTribute）も全く同じです。
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
    currentHistory.add(newTribute);
    await localStorageService.saveTributeHistory(currentHistory);

    state = AsyncData(state.value!.copyWith(
      tributeHistory: currentHistory,
    ));
  }
}

// --- ③ Provider（メニュー表）の定義 ---
// ★★★ ここが一番大きな違いです！ ★★★
// generatorが自動生成していたProviderを、このように手で書きます。
final tributeHistoryProvider =
    AsyncNotifierProvider<TributeHistoryNotifier, TributeHistoryState>(() {
  // 「このメニューを注文されたら、TributeHistoryNotifierというお料理人を準備してください」
  // という意味になります。
  return TributeHistoryNotifier();
});
