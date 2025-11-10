// lib/stories/suzunari_oto.dart

import 'package:saving_girlfriend/features/story/models/story_model.dart';

// 鈴鳴おとのセリフデータ本体
// ★変更点: 型を List<List<DialogueLine>> に修正
const List<List<DialogueLine>> suzunariOtoDialogue = [
  // Episode 0: 出会い
  [
    // 元のデータから話者とセリフを分離
    DialogueLine(speaker: '鈴鳴おと', text: 'もしかして､ ○○先輩？ 久しぶり！'),
    DialogueLine(speaker: 'モノローグ', text: '大学の食堂で聞いたその声は､ 懐かしさよりも妙な既視感を連れてきた'),
    DialogueLine(
        speaker: 'モノローグ', text: '声の主は､ 鈴鳴おと｡ 高校の後輩で､ にこにこと笑うその顔は昔のままだった'),
    DialogueLine(speaker: '自分', text: 'おと？ 同じ大学だったのか'),
    DialogueLine(speaker: '鈴鳴おと', text: 'うん 理学部！先輩もでしょ？'),
    DialogueLine(
        speaker: 'モノローグ', text: '再会の偶然に少し浮かれながらも､ ○○の頭の片隅では別の引っかかりが消えなかった'),
    DialogueLine(speaker: 'モノローグ', text: '──この声､ どこかで聞いたことがあるような…'),
    DialogueLine(
        speaker: 'モノローグ',
        text: '夜｡ 研究の合間､ 俺はいつものようにお気に入りのVTuber｢おんぷちゃん｣の配信をつけた'),
    DialogueLine(
        speaker: 'モノローグ', text: '透き通る声､ 明るいトーン､ ちょっと天然な話し方。画面の中の彼女が､ マイク越しに笑う'),
    DialogueLine(
        speaker: 'おんぷ',
        text: '『今日も見てくれてありがとう～！おんぷね､ 実験のレポートが全然終わらなくて泣きそうだよ～！みんな助けて』'),
    DialogueLine(
        speaker: 'モノローグ',
        text: '笑い声を聞いた瞬間､ 心臓が跳ねた。その声は､ まぎれもなく今日食堂で聞いたおとの声だった。'),
    DialogueLine(
        speaker: 'モノローグ',
        text: 'まさかと思いながら､ 何度も聞き返す。イントネーションも､ 語尾の伸ばし方も､ 笑い方さえ同じ'),
    DialogueLine(speaker: 'モノローグ', text: '画面の中で｢おんぷ｣が言葉を続けた'),
    DialogueLine(speaker: 'おんぷ', text: '『でも理系の先輩がちょっと助けてくれたからちゃんと配信は取れそうだよ～』'),
    DialogueLine(speaker: 'モノローグ', text: 'その言葉に俺は息を止めた。理系の先輩──偶然の一致､ なのか？'),
    DialogueLine(
        speaker: 'モノローグ',
        text: '次の日､ 去年の時間割を参考におとが講義を受けているであろう教室の前で､ チャイムが鳴るのをまっていた'),
    DialogueLine(speaker: '自分', text: 'あ！おと､ 昨日夜遅くまで起きてた？'),
    DialogueLine(speaker: '鈴鳴おと', text: 'え？ うん､ ちょっと動画見てて'),
    DialogueLine(speaker: '自分', text: 'どんな動画？'),
    DialogueLine(speaker: '鈴鳴おと', text: 'ないしょ～'),
    DialogueLine(speaker: 'モノローグ', text: 'にこっと笑っておとは歩いていく'),
    DialogueLine(
        speaker: 'モノローグ', text: 'その笑顔が嘘をついてるようには見えないのに､ 俺の胸にはざらりとした違和感が残った'),
    DialogueLine(speaker: 'モノローグ', text: '──やっぱり､ あの声はおとだ'),
    DialogueLine(
        speaker: 'モノローグ', text: 'でも､ 本人が言わない以上､ こちらからは聞けない。もし違ったらただの失礼だ'),
    DialogueLine(speaker: 'モノローグ', text: '数日後､ 再び｢おんぷちゃん｣の配信が始まった'),
    DialogueLine(speaker: 'モノローグ', text: 'イヤホン越しに響く声が､ あの日の笑い方と重なってしまう'),
    DialogueLine(speaker: 'おんぷ', text: '『先輩ってね､ いつも優しくて､ でもちょっと抜けてるの』'),
    DialogueLine(speaker: 'モノローグ', text: 'コメント欄がざわつく'),
    DialogueLine(speaker: 'コメント欄', text: '『え～誰のこと！？』『リアルの話！？』'),
    DialogueLine(speaker: 'モノローグ', text: '俺は息をのんだ｡まさか自分のこと…？'),
    DialogueLine(speaker: 'モノローグ', text: 'でも聞けない｡ 聞いた瞬間､ 今の関係が壊れる気がした｡'),
    DialogueLine(speaker: 'モノローグ', text: '画面の中の彼女が笑う｡'),
    DialogueLine(speaker: 'おんぷ', text: '『みんなにはひみつだよ～』'),
    DialogueLine(speaker: 'モノローグ', text: 'その夜､ 配信を閉じても耳の奥に声が残っていた'),
    DialogueLine(
        speaker: 'モノローグ', text: '鈴鳴おとと｢おんぷ｣。ふたつの名前が､ 俺の中でゆっくり重なり始めていた'),
  ],

  // Episode 1: 初めての会話 (データ未入力)
  [
    DialogueLine(speaker: '鈴鳴おと', text: '｢○○先輩って いつもひとりでお昼食べてるよね'),
    DialogueLine(speaker: '自分', text: 'え､ああ まあ研究室まだ決まってないから'),
    DialogueLine(speaker: '鈴鳴おと', text: 'じゃあ 今日から私と食べてよ だめ？'),
    DialogueLine(speaker: 'モノローグ', text: 'そう言っておとは当然のように隣に腰を下ろした'),
    DialogueLine(speaker: 'モノローグ', text: '学食のざわめきの中 彼女の声は耳にやわらかく響く'),
    DialogueLine(
        speaker: 'モノローグ', text: 'それが夜に聞いている“あの声” と同じだと思うと まともに顔が見られなかった'),
    DialogueLine(speaker: '鈴鳴おと', text: '先輩 どこ見てるの？'),
    DialogueLine(speaker: '自分', text: 'ん､いや なんでも'),
    DialogueLine(speaker: '鈴鳴おと', text: 'そっかー なんでもか～ちゃんと目見て話したいのに'),
    DialogueLine(speaker: 'モノローグ', text: 'おとは笑って 唐揚げを箸でつまみながら言う'),
    DialogueLine(speaker: '鈴鳴おと', text: '私も最近ね 夜ずっと動画見てるんだ'),
    DialogueLine(speaker: '自分', text: 'どんなの？'),
    DialogueLine(speaker: '鈴鳴おと', text: 'ないしょ'),
    DialogueLine(
        speaker: 'モノローグ', text: 'また その言葉。ごまかす時の声のトーンまで 画面の中の“すずねりん” と同じだった'),
    DialogueLine(
        speaker: 'モノローグ', text: '授業が終わった放課後 俺は図書館の窓際でレポートを書いていたそこへおとが顔を出す'),
    DialogueLine(speaker: '鈴鳴おと', text: '先輩～まだいた！よかった！ ねえこれわかんない 教えてください'),
    DialogueLine(
        speaker: 'モノローグ', text: '差し出されたノートには量子力学の数式。おとは眉をしかめてペンをくるくる回す'),
    DialogueLine(speaker: '自分', text: 'こんな感じで証明できる､あとはこれ覚えるだけ'),
    DialogueLine(speaker: '鈴鳴おと', text: 'え～覚えなきゃなの～でもこういうのって確か音にしたら覚えやすいんだよね'),
    DialogueLine(speaker: '自分', text: '音に？'),
    DialogueLine(speaker: '鈴鳴おと', text: 'うん ‘～♪’ って好きな音にして覚えたら忘れないの'),
    DialogueLine(speaker: '自分', text: '……そのメロディどこかで聞いた気がする'),
    DialogueLine(speaker: '鈴鳴おと', text: 'え？'),
    DialogueLine(speaker: 'モノローグ', text: '“すずねりん” が先週の配信で同じ冗談を言っていた'),
    DialogueLine(speaker: 'モノローグ', text: 'まるで録音を再生したみたいに 同じテンポ 同じ笑い方'),
    DialogueLine(
        speaker: 'モノローグ',
        text: '──確信した。鈴鳴おと＝すずねりん。でもそれを言葉にした瞬間､何か大事なものが壊れてしまいそうで'),
    DialogueLine(speaker: '鈴鳴おと', text: '先輩ってさ'),
    DialogueLine(speaker: '自分', text: 'ん？'),
    DialogueLine(speaker: '鈴鳴おと', text: '何か隠してるでしょ'),
    DialogueLine(speaker: '自分', text: 'えっ'),
    DialogueLine(speaker: '鈴鳴おと', text: 'なんか 目が泳いでるもん'),
    DialogueLine(speaker: '自分', text: '……隠してるのはおとのほうだろ'),
    DialogueLine(speaker: '鈴鳴おと', text: 'え？'),
    DialogueLine(speaker: '自分', text: 'いや なんでも'),
    DialogueLine(
        speaker: 'モノローグ',
        text: 'そんな他愛もないやりとりで 一日の終わりが近づく。大学の門を出る頃には 空が薄紫に染まっていた'),
    DialogueLine(speaker: '鈴鳴おと', text: '先輩'),
    DialogueLine(speaker: '自分', text: 'ん？'),
    DialogueLine(speaker: '鈴鳴おと', text: '今日もありがとね、勉強助かった'),
    DialogueLine(speaker: '自分', text: 'いいって'),
    DialogueLine(speaker: '鈴鳴おと', text: '今度､お礼にお菓子作ってあげよっか'),
    DialogueLine(speaker: '自分', text: 'おとが作るの？'),
    DialogueLine(speaker: '鈴鳴おと', text: 'うん！ちょっと自信あるんだよ'),
    DialogueLine(speaker: '自分', text: 'それは楽しみだな'),
    DialogueLine(
        speaker: 'モノローグ',
        text: 'そう言いながら見上げた彼女の顔が ほんの少し照れていて。その笑顔を見た瞬間､○○の中で迷いがふくらんだ'),
    DialogueLine(speaker: 'モノローグ', text: 'このまま知らないふりをしていれば きっと穏やかな日々が続く'),
    DialogueLine(
        speaker: 'モノローグ',
        text: 'でももし､｢すずねりんの正体｣を知っていることを告げたらふたりの距離は一瞬で変わってしまう'),
    DialogueLine(
        speaker: 'モノローグ', text: '夜 帰り道でイヤホンを耳に差し込む画面の中で“すずねりん” が笑っていた'),
    DialogueLine(speaker: 'おんぷ', text: '『今日も大学の先輩が助けてくれたの～！ ほんと優しいんだよ』'),
    DialogueLine(
        speaker: 'モノローグ', text: '俺の胸が一気に熱くなるそれはたぶん 嬉しさと､どうしようもない罪悪感の混ざった温度だった'),
    DialogueLine(
        speaker: 'モノローグ',
        text:
            'その夜､○○は初めてコメントを打つ指を止めた──｢がんばって｣も｢応援してる｣もどんな言葉も､もう他人のふりでは打てなかった｡'),
  ],
  // Episode 2: 公園の散歩 (データ未入力)
  [],
  // Episode 3: 好きな食べ物 (データ未入力)
  [],
  // Episode 4: 休日の過ごし方 (データ未入力)
  [],
  // Episode 5: 趣味の話 (データ未入力)
  [],
  // Episode 6: 小さなプレゼント (データ未入力)
  [],
  // Episode 7: 雨の日の思い出 (データ未入力)
  [],
  // Episode 8: 喧嘩と仲直り (データ未入力)
  [],
  // Episode 9: 伝えたい言葉 (データ未入力)
  [],
  // Episode 10: そして未来へ (データ未入力)
  [],
];
