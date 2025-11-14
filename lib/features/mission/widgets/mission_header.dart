import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ★★★ カスタムヘッダーウィジェット (背景色を修正) ★★★
class CustomMissionHeader extends StatelessWidget {
  const CustomMissionHeader({super.key}); // ★ key を追加

  @override
  Widget build(BuildContext context) {
    return Container(
      // ★ 背景色を透明にし、下のボーダーで区切りをつける
      decoration: BoxDecoration(
        color: Colors.transparent, // ★ 透明に
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 戻るボタン
          Positioned(
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          // タイトル
          const Text(
            'ミッション',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                    offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
