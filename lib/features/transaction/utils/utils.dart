import 'dart:math' as math;

// [修正] 必要な enum ファイルをインポート
import 'package:saving_girlfriend/features/transaction/models/transaction_category.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_type.dart';

// [修正] 関数の引数を String から enum に変更
String getGirlfriendComment(
    TransactionCategory category, int amount, TransactionType type) {
  final random = math.Random(category.hashCode + amount);

  // [修正] "income" (String) との比較を enum との比較に変更
  if (type == TransactionType.income) {
    final incomeComments = [
      "お給料入ったね！今月もお疲れ様💕 ちゃんと貯金してね！",
      "やった！収入だ✨ 今月も頑張ったね！",
      "お金入ったね～！でも使いすぎないでよ？💰",
    ];
    return incomeComments[random.nextInt(incomeComments.length)];
  }

  // [修正] String.contains() のロジックを switch(category) に変更
  switch (category) {
    case TransactionCategory.food:
      // 「食費」「コンビニ」「カフェ」のロジックを food に統合
      if (amount > 3000) {
        return "ちょっと贅沢しすぎじゃない？たまにはいいけどね🍽️";
      }
      final convenienceComments = [
        "もう！またコンビニでお菓子買ってる～！ちゃんと貯金してよね💢",
        "コンビニ寄りすぎ！自炊したら節約できるのに...😤",
        "またコンビニ？毎日行ってない？ちゃんと管理してね！",
      ];
      final cafeComments = [
        "今日はカフェで勉強かな？お疲れ様！でもスタバは高いよ～💦",
        "カフェ代もバカにならないよ？たまには家で飲もうよ☕",
        "またカフェ？リラックスするのもいいけどほどほどにね！",
      ];
      final foodComments = [
        "美味しいもの食べた？栄養もちゃんと摂ってね！",
        ...convenienceComments,
        ...cafeComments
      ];
      return foodComments[random.nextInt(foodComments.length)];

    case TransactionCategory.transport:
      if (amount > 5000) {
        return "タクシー使ったの？終電逃したなら仕方ないけど...次は気をつけてね！🚕";
      }
      return "交通費かぁ。仕方ないよね、お疲れ様！";

    case TransactionCategory.entertainment:
      // 「娯楽」「書籍」のロジックを entertainment に統合
      final bookComments = [
        "勉強熱心なところ好き♡ でも図書館も活用してね～📚",
        "本買ったんだ！ちゃんと読んでね！積読禁止だよ？",
        "自己投資は大事だけど、読み切れる分だけにしてね📖",
      ];
      final entertainmentComments = [
        "遊ぶのもいいけど、使いすぎ注意だよ！🎮",
        ...bookComments,
      ];
      return entertainmentComments[
          random.nextInt(entertainmentComments.length)];

    // social, daily, other はデフォルトのコメントを使用
    case TransactionCategory.social:
    case TransactionCategory.salary:
    case TransactionCategory.sideJob:
    case TransactionCategory.extraIncome:
    case TransactionCategory.daily:
    case TransactionCategory.other:
      break; // デフォルトのコメント処理に進む
  }

  // デフォルトのコメント
  final defaultComments = [
    "無駄遣いしないでね！一緒に貯金がんばろ✨",
    "ちゃんと必要なものだけ買ってる？考えてから使ってね💭",
    "節約も大事だよ！でもたまには自分にご褒美もね🎁",
  ];
  return defaultComments[random.nextInt(defaultComments.length)];
}

String formatAmountForCalendar(final int amount) {
  if (amount == 0) {
    return '0円';
  }

  final absAmount = amount.abs();
  String formatted;

  if (absAmount >= 100000000) {
    formatted = '${(absAmount / 100000000).toStringAsFixed(1)}億';
  } else if (absAmount >= 10000) {
    formatted = '${(absAmount / 10000).toStringAsFixed(1)}万';
  } else {
    formatted = '$absAmount円';
  }
  return amount < 0 ? '-$formatted' : formatted;
}
