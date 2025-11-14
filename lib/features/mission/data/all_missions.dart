import 'package:saving_girlfriend/features/mission/models/mission.dart';

// アプリで利用可能な全ミッションのリスト
const allMissions = [
  // --- デイリーミッション ---
  Mission(
    id: 'daily_login',
    title: '毎日ログイン',
    description: 'アプリにログインしよう',
    type: MissionType.daily,
    condition: MissionCondition.login,
    goal: 1,
    reward: 5,
  ),
  Mission(
    id: 'daily_input_transaction 1time',
    title: '今日の家計簿',
    description: '今日の収支を\n1回入力しよう',
    type: MissionType.daily,
    condition: MissionCondition.inputTransaction,
    goal: 1,
    reward: 5,
  ),
  Mission(
    id: 'daily_input_transaction 3times',
    title: '今日の家計簿',
    description: '今日の収支を\n3回入力しよう',
    type: MissionType.daily,
    condition: MissionCondition.inputTransaction,
    goal: 3,
    reward: 10,
  ),
  Mission(
    id: 'daily_superchat',
    title: 'スパチャチャレンジ',
    description: 'スーパーチャットを\nしてみよう',
    type: MissionType.daily,
    condition: MissionCondition.sendTribute,
    goal: 1,
    reward: 15,
  ),

  // --- ランダムミッション（ゲリラ） ---
  Mission(
    id: 'random_tribute',
    title: 'たまには貢いで！',
    description: '彼女に貢ごう（スパチャ）',
    type: MissionType.random,
    condition: MissionCondition.sendTribute,
    goal: 1,
    reward: 20,
  ),
  Mission(
    id: 'random_watch_story',
    title: '思い出を振り返ろう',
    description: 'ストーリーを1つ見返そう',
    type: MissionType.random,
    condition: MissionCondition.watchStory,
    goal: 1,
    reward: 15,
  ),

  // ↓↓↓ ★ 修正: 'mission_model.' のプレフィックスを削除 ★ ↓↓↓
  Mission(
    id: 'main_first_transaction',
    title: '初めての家計簿',
    description: '収支を1回入力してみよう',
    type: MissionType.main, // ★ .main に
    condition: MissionCondition.inputTransaction,
    goal: 1,
    reward: 50,
  ),
  Mission(
    id: 'main_first_tribute',
    title: '初めての応援',
    description: '彼女に初めて貢いでみよう（スパチャ）',
    type: MissionType.main,
    condition: MissionCondition.sendTribute,
    goal: 1,
    reward: 50,
  ),
  Mission(
    id: 'main_total_tribute_1000',
    title: '累計応援 1000P',
    description: '彼女への応援（スパチャ）が累計1000円を突破',
    type: MissionType.main,
    condition: MissionCondition.sendTributeAmount,
    goal: 1000,
    reward: 100,
  ),
  // ↑↑↑ ★ 修正ここまで ★ ↑↑↑

  // --- ★ ウィークリーミッション（ここから追加） ---
  Mission(
    id: 'weekly_login_3days',
    title: '今週のログイン',
    description: '今週、3回ログインしよう',
    type: MissionType.weekly, // ★ type を weekly に
    condition: MissionCondition.login,
    goal: 3,
    reward: 50,
  ),
  Mission(
    id: 'weekly_tribute_3times',
    title: '今週の応援',
    description: '今週、3回スパチャをしよう',
    type: MissionType.weekly, // ★ type を weekly に
    condition: MissionCondition.sendTribute,
    goal: 3,
    reward: 50,
  ),
  Mission(
    id: 'weekly_input_transaction_5times',
    title: '今週の家計簿',
    description: '今週、収支を5回入力しよう',
    type: MissionType.weekly,
    condition: MissionCondition.inputTransaction,
    goal: 5,
    reward: 50,
  ),
  // --- ★ ウィークリーミッション（ここまで） ---
];
