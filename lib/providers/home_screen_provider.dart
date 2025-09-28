import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 1. LocalStorageServiceを提供するシンプルなProvider

// 2. HomeScreenの状態を管理するためのNotifierとProvider
// 画面の状態を定義するクラス
class HomeScreenState {
  final String girlfriendText;
  final bool isLoading;

  HomeScreenState({
    this.girlfriendText = 'おはようございます先輩！ 今日も可愛いですね❤',
    this.isLoading = false, // isLoadingの初期値を追加
  });

  HomeScreenState copyWith({
    String? userId,
    String? girlfriendText,
    bool? isLoading,
  }) {
    return HomeScreenState(
      girlfriendText: girlfriendText ?? this.girlfriendText,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 状態とロジックを管理するNotifierクラス
class HomeScreenNotifier extends Notifier<HomeScreenState> {
  // LocalStorageServiceのインスタンスを取得

  @override
  HomeScreenState build() {
    return HomeScreenState();
  }

  // ★★★↓ aiChatメソッドをこの内容に置き換え ↓★★★
  Future<void> aiChat(String message, int saveAmount) async {
    state = state.copyWith(isLoading: true);

    final url =
        Uri.parse('http://192.168.50.37:5000/girlfriend_reaction'); //ipアドレスに注意！

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 'test_user',
          'user_input': message,
          'savings_amount': saveAmount,
        }),
      );
      print("ステータスコード：${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(girlfriendText: data['reaction']);
      } else {
        state = state.copyWith(girlfriendText: 'ごめんなさい、ちょっと調子が悪いです…');
      }
    } catch (error) {
      state = state.copyWith(girlfriendText: '通信エラーみたいです…電波届いてますか？');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// NotifierとStateをUIから使えるようにするためのProvider
final homeScreenProvider =
    NotifierProvider<HomeScreenNotifier, HomeScreenState>(() {
  return HomeScreenNotifier();
});
