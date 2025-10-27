import 'dart:math' as math;

String getGirlfriendComment(String category, int amount, String type) {
  final random = math.Random(category.hashCode + amount);

  if (type == "income") {
    final incomeComments = [
      "お給料入ったね！今月もお疲れ様💕 ちゃんと貯金してね！",
      "やった！収入だ✨ 今月も頑張ったね！",
      "お金入ったね～！でも使いすぎないでよ？💰",
    ];
    return incomeComments[random.nextInt(incomeComments.length)];
  }

  if (category.contains("コンビニ") || category.contains("お菓子")) {
    final convenienceComments = [
      "もう！またコンビニでお菓子買ってる～！ちゃんと貯金してよね💢",
      "コンビニ寄りすぎ！自炊したら節約できるのに...😤",
      "またコンビニ？毎日行ってない？ちゃんと管理してね！",
    ];
    return convenienceComments[random.nextInt(convenienceComments.length)];
  }

  if (category.contains("カフェ") ||
      category.contains("スタバ") ||
      category.contains("喫茶")) {
    final cafeComments = [
      "今日はカフェで勉強かな？お疲れ様！でもスタバは高いよ～💦",
      "カフェ代もバカにならないよ？たまには家で飲もうよ☕",
      "またカフェ？リラックスするのもいいけどほどほどにね！",
    ];
    return cafeComments[random.nextInt(cafeComments.length)];
  }

  if (category.contains("交通費") || category.contains("タクシー")) {
    if (amount > 5000) {
      return "タクシー使ったの？終電逃したなら仕方ないけど...次は気をつけてね！🚕";
    }
    return "交通費かぁ。仕方ないよね、お疲れ様！";
  }

  if (category.contains("書籍") || category.contains("本")) {
    final bookComments = [
      "勉強熱心なところ好き♡ でも図書館も活用してね～📚",
      "本買ったんだ！ちゃんと読んでね！積読禁止だよ？",
      "自己投資は大事だけど、読み切れる分だけにしてね📖",
    ];
    return bookComments[random.nextInt(bookComments.length)];
  }

  if (category.contains("食費") || category.contains("外食")) {
    if (amount > 3000) {
      return "ちょっと贅沢しすぎじゃない？たまにはいいけどね🍽️";
    }
    return "美味しいもの食べた？栄養もちゃんと摂ってね！";
  }

  if (category.contains("娯楽") || category.contains("ゲーム")) {
    return "遊ぶのもいいけど、使いすぎ注意だよ！🎮";
  }

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
