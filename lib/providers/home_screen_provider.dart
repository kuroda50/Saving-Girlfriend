import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage_service.dart';
import '../providers/tribute_history_provider.dart';

// 1. LocalStorageServiceを提供するシンプルなProvider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// 2. HomeScreenの状態を管理するためのNotifierとProvider
// 画面の状態を定義するクラス
class HomeScreenState {
  final String girlfriendText;
  // 他にも管理したい状態があればここに追加（例: final bool isLoading;）

  HomeScreenState({
    this.girlfriendText = 'おはようございます先輩！ 今日も可愛いですね❤',
    // this.isLoading = false,
  });

  // 状態をコピーして新しい状態を作るためのメソッド
  HomeScreenState copyWith({String? girlfriendText, bool? isLoading}) {
    return HomeScreenState(
      girlfriendText: girlfriendText ?? this.girlfriendText,
      // isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 状態とロジックを管理するNotifierクラス
class HomeScreenNotifier extends Notifier<HomeScreenState> {
  @override
  HomeScreenState build() {
    return HomeScreenState(); // 初期状態
  }

  // aiChatロジックをここに移動
  Future<void> aiChat(String message, int saveAmount) async {
    // state = state.copyWith(isLoading: true); // ローディング開始

    final url = Uri.parse('http://172.20.10.2:5000/girlfriend_reaction');//ipアドレスに注意！

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_input': message, 'savings_amount': saveAmount}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('AIリアクション: ${data['reaction']} / 感情: ${data['emotion']}');
        // stateを更新してUIに変更を通知
        state = state.copyWith(girlfriendText: data['reaction']);
        // 貢いだ金額が0でない場合のみ、履歴を追加する
        if (saveAmount != 0) {
          // 履歴に追加するデータを作成
          final newTribute = {
            'date': DateTime.now().toIso8601String(),
            'amount': saveAmount,
          };
          // ref を使って他のProvider(tributeHistoryProvider)のメソッドを呼び出す
          await ref
              .read(tributeHistoryProvider.notifier)
              .addTribute(newTribute);
        }
      } else {
        print('APIエラー: ${response.body}');
        state = state.copyWith(girlfriendText: 'ごめんなさい、ちょっと調子が悪いです…');
      }
    } catch (error) {
      print('通信エラー: $error');
      state = state.copyWith(girlfriendText: '通信エラーみたいです…電波届いてますか？');
    } finally {
      // state = state.copyWith(isLoading: false); // ローディング終了
    }
  }
}

// 上記のNotifierをUIから使えるようにするためのProvider
final homeScreenProvider =
    NotifierProvider<HomeScreenNotifier, HomeScreenState>(() {
  return HomeScreenNotifier();
});
