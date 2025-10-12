// lib/models/comment_model.dart

import 'package:flutter/material.dart';

// 金額に応じた色情報を管理するクラス
class SuperChatColorConfig {
  final Color backgroundColor;
  final Color textColor;
  SuperChatColorConfig({required this.backgroundColor, required this.textColor});
}

// 全てのコメントの共通の型（基底クラス）
abstract class Comment {
  final String userName;
  final String iconAsset; // アイコン画像のパス
  final String text;
  Comment({required this.userName, required this.iconAsset, required this.text});
}

// 通常コメント
class NormalComment extends Comment {
  NormalComment({
    required super.userName,
    required super.iconAsset,
    required super.text,
  });
}

// スパチャ
class SuperChat extends Comment {
  final int amount;
  SuperChat({
    required super.userName,
    required super.iconAsset,
    required super.text,
    required this.amount,
  });

  // 金額に応じて色を返すヘルパーメソッド
  SuperChatColorConfig get colorConfig {
    if (amount >= 10000) {
      return SuperChatColorConfig(backgroundColor: Colors.red.shade700, textColor: Colors.white);
    } else if (amount >= 5000) {
      return SuperChatColorConfig(backgroundColor: Colors.orange.shade700, textColor: Colors.white);
    } else if (amount >= 1000) {
      return SuperChatColorConfig(backgroundColor: Colors.yellow.shade400, textColor: Colors.black87);
    } else if (amount >= 500) {
      return SuperChatColorConfig(backgroundColor: Colors.cyan.shade400, textColor: Colors.black87);
    } else {
      return SuperChatColorConfig(backgroundColor: Colors.blue.shade600, textColor: Colors.white);
    }
  }
}