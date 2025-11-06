// Dart imports:
import 'package:saving_girlfriend/constants/assets.dart';
// Project imports:
// (home_screen_provider.dartから移動)

// ---------------------------------------------------------------
// ★★★↓ home_screen_provider.dart から移動 ↓★★★
// ---------------------------------------------------------------

// シナリオのイベント（セリフかコメントか）を定義
enum ScenarioEventType {
  dialogue,
  comment,
}

// シナリオの各イベントを管理するクラス
class ScenarioEvent {
  final ScenarioEventType type;
  final String text;
  final String? userName; // コメントの場合のみ使用
  final String? iconAsset; // コメントの場合のみ使用

  ScenarioEvent({
    required this.type,
    required this.text,
    this.userName,
    this.iconAsset,
  });
}

// ---------------------------------------------------------------
// ★★★↓ 視聴者プロフィールデータ ↓★★★
// ---------------------------------------------------------------
final Map<String, String> kViewerProfiles = {
  'ドラえもん': AppAssets.iconUser2,
  '出木杉': AppAssets.iconUser3,
  'たけし': AppAssets.iconUser4,
  'のびた': AppAssets.iconUser5,
  'しずか': AppAssets.iconUser7,
  'カツオ': '',
  'サザエ': '',
  'ジャイ子': AppAssets.iconUser6,
  'ワカメ': '',
  'マスオ': AppAssets.iconUser2, // iconUser1 -> 2 に修正済みのもの
};

// ---------------------------------------------------------------
// ★★★↓ 全シナリオデータ ↓★★★
// ---------------------------------------------------------------
final Map<int, Map<int, List<ScenarioEvent>>> kAllScenarios = {
  // ---------------------------------
  // ★★★ レベル1のシナリオ (コメント"激"増量・高密度版) ★★★
  // ---------------------------------
  1: {
    // --- 導入：挨拶 (0〜29秒) ---
    0: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'みんな、こんばんはー！鈴鳴おとです！今日も来てくれてありがとう！'),
    ],
    1: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わこー',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    2: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'こんばんは！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    3: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きたー！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    4: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'こんばんは！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    5: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '88888',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    6: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おとちゃん！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    7: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいい',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    8: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わこつです！',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おとちゃんこんばんは！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    10: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '待ってた！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    11: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいい',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    13: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '今日も見るぞー',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    15: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'わー！コメントいっぱいありがとう！ちゃんと見てるからねー！'),
    ],
    16: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    17: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いえーい',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    18: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（！）',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    19: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '見てるよー！',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    21: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいい',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    23: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'えーっと、今日はね、みんなにちょっと聞いてもらいたいことがあって…'),
    ],
    24: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ん？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    25: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'なになに？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    27: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    28: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'どしたん？',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],

    // --- 話題1：レポートと先輩 (30〜170秒) ---
    30: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'あのね、私、大学の実験レポートが全然終わらなくて…！もう泣きそうだったんだよ〜！'),
    ],
    32: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あー',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    33: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わかる',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    34: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'がんばれ！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    35: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    36: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えらい',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    38: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えー！大丈夫？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '理学部だもんね、大変だ…',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    40: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ファイト！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    42: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'レポートかぁ…',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    44: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わかる',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    46: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'それがね！今日、大学のすっごく優しい先輩が助けてくれたの！'),
    ],
    48: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ん？',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    49: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（！）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    50: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    51: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    53: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '図書館で『わかんない〜！』って頭抱えてたら、声かけてくれて…'),
    ],
    55: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '優しい',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    57: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（先輩…？）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    58: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いい話',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    60: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おお！？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'リアルの話！？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'イケメンでしたか？',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    62: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'まさか',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    64: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'kwsk',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    66: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいなー',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    68: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'え〜？だれかは『ないしょ』！'),
    ],
    69: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '草',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    70: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    71: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えー！教えてよ！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    72: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ちぇー',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    73: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ないしょかｗ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    75: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'でもね、その先輩、いつも優しくて、でもちょっと抜けてるところもあって…ふふっ'),
    ],
    77: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ふふっｗ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    78: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ん？ｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    80: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '惚気か？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    81: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    83: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あ、それ絶対好きなやつだ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おとちゃん楽しそうｗ',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    85: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ニヤニヤ）',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    86: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいね',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    88: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    90: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'それでね！その先輩、教えてくれるのはいいんだけど、説明しながら自分が『あれ？』とか言ってて（笑）'),
    ],
    92: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    94: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    95: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '草',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    96: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいいｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    98: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'でも、最後はちゃんとわかるまですっごく丁寧に教えてくれたんだ。本当に助かった〜…'),
    ],
    100: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '優しい',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    102: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'よかったね',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    104: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '優しい先輩だ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    106: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'だから今度、お礼にお菓子でも作っていこうかなって思ってるんだよね'),
    ],
    108: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    110: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '手作り！',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    112: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいなー',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    114: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '手作り！？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'それは喜ぶわ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    116: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'すごい',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    118: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '女子力！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    120: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '俺にもくれ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    122: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'もう！みんなの分はないですよ！これは特別なの！私、お菓子作りちょっと自信あるんだから！'),
    ],
    124: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    126: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えー',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    128: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '食べたい',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    130: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '自信あるのいいね',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],

    // --- ★★★ 拡張ここから ★★★ ---
    // --- 話題2：学食での話 (171〜300秒) ---
    171: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'そういえばね、その先輩、いつもお昼ごはん一人で食べてるんだよね。'),
    ],
    173: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ほう',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    175: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ぼっち飯か…',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    177: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あら',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    178: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わかる',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    180: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '俺もだ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    182: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'だからね、「じゃあ今日から私と食べてよ！」って言って、隣に座っちゃった！'),
    ],
    184: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    185: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（！）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    186: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'やるぅ！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    188: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '強いｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    190: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '積極的～',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    192: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいね！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    194: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'そしたら先輩、なんかすごいキョドってて（笑）'),
    ],
    196: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    198: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    200: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '照れてるｗ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    203: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「どこ見てるの？」って聞いたら、「ん、いやなんでも」だって！'),
    ],
    205: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '草',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    207: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいいかよ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    209: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あやしいｗ',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    210: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '目が泳いでるのが見えるｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    214: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '「ちゃんと目見て話したいのに〜」って言っちゃった！'),
    ],
    216: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '言うねえｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    218: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    220: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    221: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ぐいぐい行くじゃん',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    225: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '…でも、本当は私も緊張してて、あんまり顔見れなかったんだけどね。'),
    ],
    227: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'なんだｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    229: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいいｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    230: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お互い様かｗ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    233: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（尊い）',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],

    // --- 話題3：図書館での勉強 (301〜450秒) ---
    301: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'あ、そうそう！勉強といえば！'),
    ],
    303: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    305: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '勉強えらい',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    308: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'この前も図書館で勉強教えてもらったんだけど、量子力学？が難しすぎて！'),
    ],
    310: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    312: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'りょーしりきがく',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    314: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '？？？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    315: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '難しそう…',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    318: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '理学部だなぁ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    320: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '無理ｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    322: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「こんなの覚えられない〜」って言ってたら、先輩が証明？してくれて。'),
    ],
    325: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    328: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「あとはこれ覚えるだけ」とか言うんだよ！ひどくない！？'),
    ],
    330: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    332: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    334: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'まぁ暗記は必要だよね',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    336: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '草',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    337: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '鬼！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    340: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'だから「こういうのって音にしたら覚えやすいんだよね〜♪」って冗談で言ったら…'),
    ],
    343: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '♪',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    345: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '音に？',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    348: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'なんか先輩、「そのメロディどこかで聞いた気がする」みたいな顔してて。'),
    ],
    351: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ん？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    353: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（！）',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    355: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'まさか…',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    358: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '…あれ？私、この話どっかでしちゃったっけ？'),
    ],
    360: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    362: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（先週の配信だ…！）',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    364: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '聞いたことあるｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    365: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'デジャブ？ｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    368: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'ま、いっか！とにかく、先輩のおかげで勉強なんとかなってるって話でした！'),
    ],
    370: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'よかったねｗ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    372: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],

    // --- 結び：ゲームの話 (451〜600秒) ---
    451: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'あ、そうだ！みんな、スモブラってやる？'),
    ],
    453: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    455: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'やるー！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    457: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'たまにやる',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    458: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '大好き！',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    460: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '実は今度、その先輩とスモブラで勝負することになったの！'),
    ],
    462: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    464: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'また先輩かｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    466: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '仲良いなｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    469: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '私、絶対負けないように練習しなきゃ！先輩、意外とゲーム強いんだよね…'),
    ],
    472: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'がんばれ！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    474: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おとちゃん頑張れ！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    476: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'どっち応援しようｗ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    477: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ゲーム配信して！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    479: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '配信！配信！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    481: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'よし！じゃあ、今日はこのあとレポートの続きやって、スモブラの練習もするぞー！'),
    ],
    483: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    485: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えらい！',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    486: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えらい！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    488: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'がんばれ～',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    490: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ファイト！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    492: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'みんなも応援ありがとう！それじゃあ、またね！おつおと〜！'),
    ],
    494: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつー',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    496: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつおとー！',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    498: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつかれー',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    500: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'またねー',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    502: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'レポートがんば',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    600: [
      // ループポイント
      ScenarioEvent(type: ScenarioEventType.dialogue, text: '...'),
    ]
  },

  // ---------------------------------
  // ★★★ レベル2のシナリオ (コメント"激"増量・高密度版) ★★★
  // ---------------------------------
  2: {
    // --- 導入：挨拶 (0〜24秒) ---
    0: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'みんな、こんばんはー！おとです！'),
    ],
    1: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きたー！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    2: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わこー',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    3: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '8888',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    5: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '聞いて聞いて！今日すっごく嬉しいことがあったの！'),
    ],
    7: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    8: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ん？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    9: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'こんばんは！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    10: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'どした？',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    12: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'なになに？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'どうしたの？',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    15: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'wktk',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    17: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（？）',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    18: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'えへへ、あのね…じゃーん！'),
    ],
    20: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    22: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ｺﾞｸﾘ...）',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],

    // --- 話題1：ネックレス (25〜180秒) ---
    25: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'このネックレス、かわいくない！？'),
    ],
    27: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！？',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    28: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    29: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいい！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    30: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいね',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    32: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お！かわいい！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '似合ってる！',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    34: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おしゃれ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    35: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいね',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    38: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'でしょー！実はこれね、先輩に買ってもらっちゃった…！'),
    ],
    40: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'え',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    42: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'は！？',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    43: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（またか…）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    44: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ファッ！？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    46: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'また先輩！？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    48: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うらやま',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    50: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '先輩…！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    52: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'そうなの！「今月ピンチで…」って言ったら、「じゃあ買おうか？」って…'),
    ],
    54: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'イケメンか',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    56: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おねだり上手ｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    58: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'やるなｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    60: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'もう世界一優しすぎない！？'),
    ],
    62: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    63: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '熱いねえ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    64: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '惚気か！ｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    66: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ニヤニヤ）',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    68: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '優しいな〜',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'それ脈アリじゃん',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    71: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'アツアツ',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    73: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '間違いない',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    75: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'えっ！？そ、そうかなぁ…？'),
    ],
    77: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'そうだよ！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    79: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '草',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    80: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '間違いない',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    82: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'でも「彼女できたら絶対尽くすタイプだよね」って言ったら、「どうだろ」って顔赤くなってた！'),
    ],
    85: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    86: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいいｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    88: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    90: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'wwwww',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいいかよ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    93: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいぞー',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    97: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'あ〜もう！なんか色々思い出してドキドキしてきた…！'),
    ],
    99: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    100: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'こっちがドキドキするわ',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    102: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'がんばれｗ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    103: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ごちそうさまです',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],

    // --- ★★★ 拡張ここから ★★★ ---
    // --- 話題2：しりとり (181〜360秒) ---
    181: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'あ、そうだ、帰り道にしりとりしたんだ！'),
    ],
    183: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'しりとり？',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    185: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'なぜｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    187: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '唐突ｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    190: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '先輩が「めだか」って言ったから、「カラス」って返して…'),
    ],
    192: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    195: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「水泳」→「イス」→「するめ」って来たから、「メス」って返したの！'),
    ],
    197: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    199: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ひどいｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    200: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'メスｗｗｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    202: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '”す”攻めｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    205: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'そしたら先輩、「”す”攻めずるい！」とか言って「スイス」って！'),
    ],
    207: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    210: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    212: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '平和だｗ',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    213: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '仲良いなｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    216: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'だから…「すき」って返した。'),
    ],
    218: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    220: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！？',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    222: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えっ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    224: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きゃー！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    225: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'まじか',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    227: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'そしたら先輩、黙っちゃって（笑）'),
    ],
    229: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    231: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あちゃーｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    233: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '固まるわｗ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    235: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'そりゃそうだｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    238: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'そのあと、腕組んじゃった！えへへ。'),
    ],
    240: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うわー！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    242: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    244: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'やるじゃん！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    246: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ニヤニヤ）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    247: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「恋人みたいですね」って言ったら、「からかってるだろ」って言われちゃった。'),
    ],
    250: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    252: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ニヤニヤ）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    255: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '「からかってないです。本気ですよ？」って言っといた！'),
    ],
    257: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    259: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいぞ！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    260: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いけいけ！',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    262: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '押していくねえ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    265: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'なんか、ただの後輩じゃなくて、ちゃんと意識してほしいなって。'),
    ],
    268: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    270: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '応援する！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    272: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'がんばれ！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    273: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '頑張れおとちゃん',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],

    // --- 結び (500〜600秒) ---
    500: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'あ、もうこんな時間！'),
    ],
    502: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'えー',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    504: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あっという間',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    507: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '今日も聞いてくれてありがとう！なんか、惚気配信みたいになっちゃったけど…'),
    ],
    510: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    512: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '楽しかったよｗ',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    514: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ごちそうさまでした！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    515: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ごち！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    517: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'えへへ。それじゃあ、またね！おつおと〜！'),
    ],
    519: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつー',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    521: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつおとー',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    523: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつかれー',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    525: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ばいばーい',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    600: [
      // ループポイント
      ScenarioEvent(type: ScenarioEventType.dialogue, text: '...'),
    ]
  },

  // ---------------------------------
  // ★★★ レベル3のシナリオ (コメント"激"増量・高密度版) ★★★
  // ---------------------------------
  3: {
    // --- 導入：挨拶 (0〜33秒) ---
    0: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'こ、こんばんは…おとです…。'),
    ],
    2: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    3: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'わこ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    4: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'こんばんは',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    6: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    7: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ん？どうした？',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '元気ない？',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    9: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'どしたどした？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    11: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'なんか草',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    14: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'ち、違うの…元気ないとかじゃなくて…'),
    ],
    16: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '？？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    18: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ｺﾞｸﾘ）',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    21: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '今日…ついに…先輩と、手、繋いじゃった…'),
    ],
    23: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'え',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    25: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    27: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'は！？',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    29: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！？！？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'まじ！？',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きゃー！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    31: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うおお',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    33: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｷﾀ――(ﾟ∀ﾟ)――!!',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],

    // --- 話題1：カフェでの話 (36〜180秒) ---
    36: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'カフェで「あーん」とかしちゃって、その帰り道で…！'),
    ],
    38: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あーん！？',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    40: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あーん！？',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    42: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おいおい',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    44: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '私が選んだケーキですよ？って言って…！'),
    ],
    46: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'やるなｗ',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    48: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ぐいぐいじゃん',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    50: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（！）',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    53: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'そしたら先輩、顔赤くしながら食べてくれて…'),
    ],
    55: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいいｗ',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    57: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    60: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うらやま…',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    63: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'そのあと、私が同じスプーンで食べちゃった！'),
    ],
    65: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    67: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'キャー！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    69: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '間接キス…！',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    71: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '積極的ｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    72: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「間接キスですね」って言ったら「それを言うな」って（笑）'),
    ],
    74: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    76: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '草',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    79: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '照れてる照れてるｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    82: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「嫌じゃなさそうですけど？」って聞いたら「…嫌じゃない」って！'),
    ],
    85: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    87: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（！）',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    89: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'もう両思いじゃん',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    90: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    92: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '付き合え！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],

    // --- 話題2：手つなぎ (181〜360秒) ---
    181: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'それでね！それでね！その帰り道！'),
    ],
    183: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'まだあるのかｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    185: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ニヤニヤ）',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    187: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'wktk',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    190: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: 'ちょっと風が冷たかったんだけど、私が「寒い」って言ったら…'),
    ],
    193: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ｺﾞｸﾘ）',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    195: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '先輩が「ほら」「手、出せ」って…！'),
    ],
    197: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きゃー！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    199: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（尊死）',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    200: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きゃー！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    202: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うおお',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    205: [
      ScenarioEvent(type: ScenarioEventType.dialogue, text: 'それで…手、繋いじゃった…。'),
    ],
    207: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '！！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    210: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うわー！',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    212: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '少女漫画か！',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かっこよすぎ…',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    214: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（尊い）',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    216: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'やるな先輩',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    218: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいね',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    220: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '先輩の手、すっごくあったかかった…'),
    ],
    222: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'いいなー',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    224: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ごちそうさまです',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    227: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '「こういうとき自然なんですね」って言ったら…'),
    ],
    230: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'うんうん',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    232: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '「自然じゃない、めちゃくちゃドキドキしてる」って！'),
    ],
    235: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ぐはっ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    237: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きゃー！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    239: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'てぇてぇ…',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    241: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    242: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '「よかった、私だけじゃなかった」って言っちゃった。'),
    ],
    245: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'かわいい',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    247: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'もう告白しろよｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    249: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '（ニヤニヤ）',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    250: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'がんばれ！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],

    // --- 結び (500〜600秒) ---
    500: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'あーーーーもう！思い出しただけで顔熱い！'),
    ],
    502: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'ドラえもん',
          iconAsset: kViewerProfiles['ドラえもん']),
    ],
    504: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '顔真っ赤ｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    506: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'こっちも熱いわ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    509: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「もし私が“好き”って言ったら、困ります？」って聞いちゃった。'),
    ],
    511: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おー！',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    513: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '言った！',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    516: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'で、なんて？',
          userName: 'ワカメ',
          iconAsset: kViewerProfiles['ワカメ']),
    ],
    519: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue,
          text: '「困るかも」って。「たぶん、俺も同じ気持ちだから」って…！'),
    ],
    522: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '言った！！',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    524: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'きゃー！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    526: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'もう付き合ってるじゃん！',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    528: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おめでとう！',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    530: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: '…でも、まだちゃんとは言われてないから！'),
    ],
    532: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'ｗｗｗ',
          userName: 'マスオ',
          iconAsset: kViewerProfiles['マスオ']),
    ],
    534: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'じれったいなーｗ',
          userName: 'カツオ',
          iconAsset: kViewerProfiles['カツオ']),
    ],
    537: [
      ScenarioEvent(
          type: ScenarioEventType.dialogue, text: 'も、もう今日は終わり！恥ずかしい！おつおとー！'),
    ],
    539: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'あｗ',
          userName: 'のびた',
          iconAsset: kViewerProfiles['のびた']),
    ],
    541: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: '逃げたｗｗｗ',
          userName: 'たけし',
          iconAsset: kViewerProfiles['たけし']),
    ],
    542: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつおとーｗ',
          userName: 'ジャイ子',
          iconAsset: kViewerProfiles['ジャイ子']),
    ],
    543: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'おつかれーｗ',
          userName: '出木杉',
          iconAsset: kViewerProfiles['出木杉']),
    ],
    545: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'またねー！',
          userName: 'しずか',
          iconAsset: kViewerProfiles['しずか']),
    ],
    547: [
      ScenarioEvent(
          type: ScenarioEventType.comment,
          text: 'お幸せにｗ',
          userName: 'サザエ',
          iconAsset: kViewerProfiles['サザエ']),
    ],
    600: [
      // ループポイント
      ScenarioEvent(type: ScenarioEventType.dialogue, text: '...'),
    ]
  },
};

// ---------------------------------------------------------------
// ★★★↓ 好感度レベル別 配信タイトルデータ ↓★★★
// ---------------------------------------------------------------

final Map<int, String> kScenarioTitles = {
  1: '【理学部配信】先輩に助けられた話...！レポートの危機を脱出！', // Lv1: レポート・学食の話
  2: '【雑談】デート...じゃなくてお買い物報告！新しい〇〇見せたげる！', // Lv2: ネックレス・しりとりの話
  3: '【ヤバい】今日...ついに手、繋いじゃいました...///', // Lv3: カフェ・手つなぎの話
  // (レベル4以降を追加する際は、ここに追加してください)
};
