/*ストーリー画面*/

import 'package:flutter/material.dart';
import '../constants/color.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //キャラ画像
          Positioned(
            bottom: 150,
            left: 40,
            child:Text('ad')
          ),
          // 第1話ラベル（画面左上）
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.pink[300],
              child: const Text(
                '第１話',
                style: TextStyle(color: AppColors.subText, fontSize: 18),
              ),
            ),
          ),

          // キャラ名ラベル
          Positioned(
            top: 140,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '鈴鳴 おと',
                style: TextStyle(
                  color: AppColors.subText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // セリフの吹き出し
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mainBackground.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.nonActive,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  //吹き出し中イラスト                   
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'わたしがいないと…\n生きていけないようにしたいです。',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.favorite, color: AppColors.primary),
                ],
              ),
            ),
          ),

          // 再生・スキップボタン
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleButton(Icons.skip_previous),
                const SizedBox(width: 16),
                _circleButton(Icons.play_arrow),
                const SizedBox(width: 16),
                _circleButton(Icons.skip_next),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: AppColors.mainIcon,
        onPressed: () {},
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
