/* ストーリー選択画面 */

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

// --- データモデル ---
// 各エピソードのデータを保持するクラス
class Episode {
  final int number;
  final String title;
  final bool isLocked;

  Episode({required this.number, required this.title, this.isLocked = false});
}


class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  // --- UIの色の定義 ---
  static const Color primaryPink = Color(0xFFF7AABF);
  static const Color lightPink = Color(0xFFFEDDE4);
  static const Color darkPinkText = Color(0xFFE5749A);
  static const Color playButtonColor = Color(0xFFF882A3);
  static const Color backgroundColor = Color(0xFFE6F0F5);

  // --- ボトムナビゲーションバーの状態管理 ---
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('Tapped on tab: $index');
  }
  
  // --- エピソードデータのリスト（10話分に増量） ---
  final List<Episode> episodes = [
    Episode(number: 0, title: '出会い', isLocked: false),
    Episode(number: 1, title: '？？？', isLocked: true),
    Episode(number: 2, title: '？？？', isLocked: true),
    Episode(number: 3, title: '？？？', isLocked: true),
    Episode(number: 4, title: '？？？', isLocked: true),
    Episode(number: 5, title: '？？？', isLocked: true),
    Episode(number: 6, title: '？？？', isLocked: true),
    Episode(number: 7, title: '？？？', isLocked: true),
    Episode(number: 8, title: '？？？', isLocked: true),
    Episode(number: 9, title: '？？？', isLocked: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: AppBar(
          backgroundColor: primaryPink,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          // --- キャラクター情報ヘッダー ---
          // この部分はスクロールさせずに固定
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCharacterHeader(),
          ),
          const SizedBox(height: 10),

          // --- エピソードリスト（スクロール部分） ---
          // Expandedを使うことで、残りの利用可能な空間全てをリスト表示に使う
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              // リストの項目数
              itemCount: episodes.length,
              // 各項目をどのように描画するかの設定
              itemBuilder: (BuildContext context, int index) {
                final episode = episodes[index];
                return EpisodeListItem(
                  episode: episode,
                  onPlay: () {
                    print('Play episode ${episode.number}');
                  },
                  onInfo: () {
                    print('Info for episode ${episode.number}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ヘッダー部分を生成するウィジェット
  Widget _buildCharacterHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'assets/images/suzunari.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const CircleAvatar(
                  radius: 40,
                  backgroundColor: lightPink,
                  child: Icon(Icons.person, color: primaryPink, size: 50),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '鈴鳴 音',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: darkPinkText,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 再利用可能なエピソード行ウィジェット（変更なし） ---
class EpisodeListItem extends StatelessWidget {
  final Episode episode;
  final VoidCallback onPlay;
  final VoidCallback onInfo;
  
  static const Color playButtonColor = Color(0xFFF882A3);
  static const Color listItemColor = Color(0xFFFFFBEA);
  static const Color lockColor = Color(0xFFF7AABF);

  const EpisodeListItem({
    super.key,
    required this.episode,
    required this.onPlay,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: listItemColor,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Row(
          children: [
            if (episode.isLocked)
              const Icon(Icons.lock, color: lockColor, size: 28)
            else
              const SizedBox(width: 28),
            const SizedBox(width: 16),
            Text(
              '${episode.number}話',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                episode.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: playButtonColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onInfo,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: const Icon(Icons.info_outline, color: Colors.grey, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}