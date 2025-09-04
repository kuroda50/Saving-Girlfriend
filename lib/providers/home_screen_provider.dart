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
  final String userId;
  final String girlfriendText;
  final bool isLoading;

  HomeScreenState({
    this.userId = '', // userIdの初期値を追加
    this.girlfriendText = 'おはようございます先輩！ 今日も可愛いですね❤',
    this.isLoading = false, // isLoadingの初期値を追加
  });

  HomeScreenState copyWith({
    String? userId,
    String? girlfriendText,
    bool? isLoading,
  }) {
    return HomeScreenState(
      userId: userId ?? this.userId,
      girlfriendText: girlfriendText ?? this.girlfriendText,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 状態とロジックを管理するNotifierクラス
class HomeScreenNotifier extends Notifier<HomeScreenState> {
  // LocalStorageServiceのインスタンスを取得
  final _localStorageService = LocalStorageService();

  @override
  HomeScreenState build() {
    // Notifierの初期化時に、保存されているユーザーIDを読み込む
    _loadUserId();
    return HomeScreenState();
  }

  // ★★★↓ このメソッドをまるごと追加 ↓★★★
  Future<void> _loadUserId() async {
    String? userId = await _localStorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}'; 
      await _localStorageService.saveUserId(userId);
    }
    state = state.copyWith(userId: userId);
  }

  // ★★★↓ aiChatメソッドをこの内容に置き換え ↓★★★
  Future<void> aiChat(String message, int saveAmount) async {
    if (state.userId.isEmpty) {
      await _loadUserId();
    }

    state = state.copyWith(isLoading: true);

    final url = Uri.parse('http://10.191.102.208:5000/girlfriend_reaction');//ipアドレスに注意！

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // bodyにuser_idを追加
        body: jsonEncode({
          'user_id': state.userId, // ★ここでユーザーIDを送信
          'user_input': message,
          'savings_amount': saveAmount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(girlfriendText: data['reaction']);
        
        if (saveAmount != 0) {
          final newTribute = {
            'date': DateTime.now().toIso8601String(),
            'amount': saveAmount,
            'category': message,
          };
          await ref.read(tributeHistoryProvider.notifier).addTribute(newTribute);
        }
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