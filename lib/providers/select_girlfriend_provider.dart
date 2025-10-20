// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 永続化された選択状態を非同期で初期化するためのProvider
// FutureProvider が SharedPreferences からデータを読み込みます。
final selectionStatusProvider = FutureProvider<bool>((ref) async {
  // SharedPreferences のインスタンスを取得
  final prefs = await SharedPreferences.getInstance();

  // 'has_selected_girlfriend' キーの値を読み込む。未設定なら false。
  // 注意: このキーは TitleScreen のロジックで使っていた has_played_story ではなく、
  // 以前の 'has_selected_girlfriend' に戻す必要があります。
  // ここでは、どちらのキーを使うかは TitleScreen のロジックに合わせる必要がありますが、
  // 彼女選択の有無を判定したいので、'is_girlfriend_selected' という新しいキーを使います。
  return prefs.getBool('is_girlfriend_selected') ?? false;
});

// 彼女の選択状態を管理し、外部から更新するためのNotifier
// SharedPreferences への書き込みも担当します。
class SelectionStatusNotifier extends StateNotifier<bool> {
  // 初期状態は FutureProvider から読み込んだ値を使います。
  SelectionStatusNotifier(super.initialStatus);

  // 彼女選択状態を true に更新し、SharedPreferences に保存する
  Future<void> markAsSelected() async {
    state = true; // Riverpod の状態を更新

    // SharedPreferences に永続化
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_girlfriend_selected', true);
  }
}

// SelectionStatusNotifier のインスタンスを提供する StateNotifierProvider
// この Provider を使って、ウィジェットから状態の読み取りと更新を行います。
final selectionStatusNotifierProvider =
    StateNotifierProvider<SelectionStatusNotifier, bool>((ref) {
  // FutureProvider の初期値を待機し、Notifier の初期値として渡します
  final initialStatus = ref.watch(selectionStatusProvider).value ?? false;
  return SelectionStatusNotifier(initialStatus);
});
