// lib/features/story/widgets/story_chat_widget.dart
import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';

// 以前の _ChatWidget
class StoryChatWidget extends StatelessWidget {
  final String speaker;
  final String text;
  final String fullText;

  const StoryChatWidget({
    super.key,
    required this.speaker,
    required this.text,
    required this.fullText,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16, height: 1.4);

    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.mainBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.nonActive, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Stack(
        children: [
          // 1. 話者名
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 24,
            child: Visibility(
              visible: speaker != 'モノローグ',
              child: Text(
                speaker,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // 2. セリフ
          Positioned(
            top: speaker == 'モノローグ' ? 0 : 24,
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              children: [
                // 透明なテキストで事前にレイアウトを確保し、ちらつきを防ぐ
                Text(
                  fullText,
                  maxLines: 3,
                  style: textStyle.copyWith(color: Colors.transparent),
                ),
                // 表示用テキスト
                Text(
                  text,
                  maxLines: 4,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
