/*ストーリー画面*/
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/screen/home_screen.dart';
import 'package:saving_girlfriend/screen/select_story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加

import '../stories/suzunari_oto.dart';
import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';

class StoryScreen extends StatefulWidget {
  final int story_index;
  const StoryScreen({super.key, required this.story_index});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late int _story_index;
  int _lineIndex = 0;
  bool _isValidIndex = true;

  @override
  void initState() {
    super.initState();
    _story_index = widget.story_index;
    if (_story_index < 0 ||
        _story_index >= EpisodeSuzunariOto.suzunariOtoStory.length) {
      _isValidIndex = false;
    }
  }

// _StoryScreenState クラス内の nextLine() メソッド
  void nextLine() async {
    // async を追加
    if (!_isValidIndex) return;

    // 1. ストーリーの途中の場合 (略)
    if (_lineIndex <
        EpisodeSuzunariOto.suzunariOtoStory[_story_index].length - 1)
      setState(() {
        _lineIndex++;
      });
    // 2. ストーリーの最後のセリフの場合 (終了処理)
    else if (_lineIndex >=
        EpisodeSuzunariOto.suzunariOtoStory[_story_index].length - 1) {
      // 🔽🔽🔽 修正箇所 1: ストーリー再生フラグを保存 🔽🔽🔽
      final prefs = await SharedPreferences.getInstance();
      // ストーリーが完了したことを記録
      await prefs.setBool('has_played_story', true);
      // 修正箇所 2: TitleScreen と同じ判定ロジックを適用
      // ここでは、フラグを立てた直後なので、nextPath は '/home' になることが期待されます。
      final hasPlayed = prefs.getBool('has_played_story') ?? false;
      final String nextPath = hasPlayed
          ? '/home' // 再生済みならホーム画面
          : '/select_story'; // (到達しないはず)
      // 🔼🔼🔼 修正箇所終わり 🔼🔼🔼

      if (mounted) {
        context.go(nextPath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidIndex)
      // 範囲外の場合のエラー画面
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'ストーリーが見つかりません',
                style: TextStyle(fontSize: 20, color: AppColors.error),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.mainIcon,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('戻る'),
                ),
              )
            ],
          ),
        ),
      );
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
        ),
        body: GestureDetector(
          onTap: () => nextLine(),
          child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(AppAssets.backgroundClassroom),
                fit: BoxFit.cover,
              )),
              child: Center(
                child: Stack(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            AppAssets.characterSuzunari,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height * 0.5,
                          ),
                          ChatWidget(
                              text: EpisodeSuzunariOto
                                  .suzunariOtoStory[_story_index][_lineIndex]),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _circleButton(Icons.play_arrow),
                              const SizedBox(width: 16),
                              _circleButton(Icons.skip_next),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: Colors.pink[300],
                        child: Text(
                          '第${_story_index}話',
                          style:
                              TextStyle(color: AppColors.subText, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _circleButton(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 40,
        color: AppColors.mainIcon,
        onPressed: () {},
      ),
    );
  }
}

class ChatWidget extends StatelessWidget {
  final String text;
  const ChatWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.mainBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.nonActive,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
