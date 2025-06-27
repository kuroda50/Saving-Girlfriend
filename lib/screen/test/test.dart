import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850], // 画像のような濃い灰色
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // メニューボタンが押された時の処理
          },
        ),
        title: const Text(
          '無題', // ムダイ - Untitled
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        // 右側にアイコンがある場合はここにactionsを追加できます
      ),
      body: Column(
        children: [
          // ピンクのヘッダーセクション
          Container(
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFFC0CB), // 画像に似た薄いピンク色
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  // ここにアバター画像のパスを指定してください
                  // 例: backgroundImage: AssetImage('assets/girl_avatar.png'),
                  backgroundColor: Colors.white, // フォールバックの背景色
                  child: Icon(Icons.person, size: 60, color: Colors.grey), // 仮のアイコン
                ),
                SizedBox(height: 10),
                Text(
                  '鈴鳴 音', // スズナリ オト
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000), // テキストは濃い赤、または濃いピンク
                  ),
                ),
              ],
            ),
          ),
          // エピソードリストセクション
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildEpisodeItem(
                  context,
                  episodeNumber: '0話',
                  title: '出会い', // デアイ - Meeting
                  isLocked: false,
                ),
                _buildEpisodeItem(
                  context,
                  episodeNumber: '1話',
                  title: '???',
                  isLocked: true,
                ),
                _buildEpisodeItem(
                  context,
                  episodeNumber: '2話',
                  title: '???',
                  isLocked: true,
                ),
                _buildEpisodeItem(
                  context,
                  episodeNumber: '3話',
                  title: '???',
                  isLocked: true,
                ),
                _buildEpisodeItem(
                  context,
                  episodeNumber: '4話',
                  title: '???',
                  isLocked: true,
                ),
                _buildEpisodeItem(
                  context,
                  episodeNumber: '5話',
                  title: '???',
                  isLocked: true,
                ),
                _buildEpisodeItem(
                  context,
                  episodeNumber: '6話',
                  title: '???',
                  isLocked: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 全てのラベルを表示するために固定タイプに
        selectedItemColor: Colors.pink, // もしくは特定のピンク色
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // 「ホーム」が最初に選択されていると仮定
        onTap: (index) {
          // ナビゲーションの処理をここに追加
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム', // Home
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // またはIcons.womanなど適切なものがあれば
            label: '彼女', // カノジョ - Girlfriend/Her
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), // またはIcons.collections_bookmarkなど
            label: '思い出', // オモイデ - Memories
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note), // またはIcons.articleなど
            label: '記録', // キロク - Record
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(BuildContext context,
      {required String episodeNumber,
      required String title,
      required bool isLocked}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            if (isLocked)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.lock, color: Color(0xFFFF69B4)), // ホットピンクの鍵
              ),
            Text(
              episodeNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: isLocked ? Colors.grey : Colors.black,
                ),
              ),
            ),
            if (!isLocked) // ロックされていない場合のみ再生アイコンを表示
              IconButton(
                icon: const Icon(Icons.play_circle_fill, color: Colors.pink),
                onPressed: () {
                  // 再生ボタンが押された時の処理
                },
              ),
            IconButton(
              icon: Icon(Icons.info_outline, color: isLocked ? Colors.grey : Colors.blue),
              onPressed: () {
                // 情報ボタンが押された時の処理
              },
            ),
          ],
        ),
      ),
    );
  }
}

