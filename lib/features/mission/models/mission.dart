enum MissionType {
  daily, // 毎日更新
  random, // 不定期
  main, //「メイン」を追加
  weekly, //「ウィークリー」を追加
  // weekly, // 週次 など
}

enum MissionCondition {
  login, // ログインする
  inputTransaction, // 収支を入力する
  sendTribute, // 貢ぐ（スパチャ）する
  watchStory, // ストーリーを見る
  sendTributeAmount, // ★ 貢いだ「金額」 [金額用として追加]
  // ... その他、アプリの機能に応じた条件
}

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.condition,
    required this.goal, // 例: 3回入力する、など
    required this.reward, // 報酬（例: 好感度+10）
  });

  final String id;
  final String title;
  final String description;
  final MissionType type;
  final MissionCondition condition;
  final int goal;
  final int reward; // 報酬はアプリ内の通貨や好感度など
}
