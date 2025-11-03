import 'dart:math';

import 'package:saving_girlfriend/models/transaction_category.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

// ルールの評価に必要なコンテキスト情報
class EvaluationContext {
  final TransactionCategory category;
  final int amount;
  final int oneYenCount;
  final int overOneMillionCount;
  final int lastInputAmount;

  EvaluationContext({
    required this.category,
    required this.amount,
    required this.oneYenCount,
    required this.overOneMillionCount,
    required this.lastInputAmount,
  });
}

enum InputType {
  oneYen,
  tiny,
  cheap,
  normal,
  expensive,
  overMillion,
}

// evaluateメソッドの最後で記録
InputType determineInputType(int amount) {
  if (amount == 1) return InputType.oneYen;
  if (amount <= 20) return InputType.tiny;
  if (amount < 300) return InputType.cheap;
  if (amount <= 5000) return InputType.normal;
  if (amount < 1000000) return InputType.expensive;
  return InputType.overMillion;
}

// リアクションのセリフとIDを保持するクラス
class ReactionPhrase {
  final String id;
  final List<String> lines;

  ReactionPhrase({required this.id, required this.lines});
}

// リアクションのルールを定義するクラス
class ReactionRule {
  final String id; // 追加
  final bool Function(EvaluationContext) condition;
  final ReactionPhrase Function(EvaluationContext, List<String> playedIds)
      reaction;
  final int priority;
  final bool isTerminal;

  ReactionRule({
    required this.id, // 追加
    required this.condition,
    required this.reaction,
    this.priority = 0,
    this.isTerminal = true,
  });
}

// リアクションを決定するサービス
class ReactionService {
  final LocalStorageService _localStorageService;
  final List<ReactionRule> _rules = [];
  final Random _random = Random();

  ReactionService(this._localStorageService) {
    _buildRules();
  }

  // 複数の選択肢から未再生のものを優先してランダムに1つを選ぶヘルパー
  ReactionPhrase _pickReaction(
    String ruleId,
    List<ReactionPhrase> options,
    List<String> playedIds,
  ) {
    if (options.isEmpty) {
      return ReactionPhrase(id: 'default_empty', lines: ['...']);
    }

    final unplayedOptions =
        options.where((opt) => !playedIds.contains(opt.id)).toList();

    if (unplayedOptions.isNotEmpty) {
      return unplayedOptions[_random.nextInt(unplayedOptions.length)];
    } else {
      // 全て再生済みの場合は、一旦再生履歴をリセットして再度選択する
      _localStorageService.clearPlayedReactionIdsForRule(ruleId);
      return options[_random.nextInt(options.length)];
    }
  }

  void _buildRules() {
    // --- セリフの定義 ---
    final allFoodCheap = [
      ReactionPhrase(
          id: 'food_cheap_0', lines: ['お昼、安く済ませたんですねっ！', 'ちゃんと考えててえらいですよ。']),
      ReactionPhrase(
          id: 'food_cheap_1', lines: ['わぁ、自炊かな？ 先輩のごはん、今度私にも作ってほしいですっ。']),
      ReactionPhrase(
          id: 'food_cheap_2',
          lines: ['これだけ…？ちゃんと食べてます？', '無理して節約してたら、私、怒っちゃいますよ？']),
      ReactionPhrase(
          id: 'food_cheap_3', lines: ['節約ランチ、いいですねぇ。', '未来の私たちのための一歩、ですっ。']),
      ReactionPhrase(
          id: 'food_cheap_4', lines: ['コスパ最高ですね！', 'やっぱり先輩、かっこいいなぁ。']),
    ];

    final allFoodNormal = [
      ReactionPhrase(
          id: 'food_normal_0', lines: ['ランチですね！', 'ちゃんと食べてて安心しましたっ。']),
      ReactionPhrase(
          id: 'food_normal_1',
          lines: ['お昼ごはん、いい感じですね。', '午後もがんばれるようにパワーチャージですよ。']),
      ReactionPhrase(
          id: 'food_normal_2', lines: ['おつかれさまです、先輩。', 'ごはんは心のリセット、ですよ。']),
      ReactionPhrase(
          id: 'food_normal_3',
          lines: ['今日のランチ、どんなの食べたんですか？', '美味しかったなら、それが一番ですっ。']),
      ReactionPhrase(
          id: 'food_normal_4', lines: ['食費、入力しましたっ！', 'ちゃんと食べてくれてうれしいです。']),
    ];

    final allFoodExpensive = [
      ReactionPhrase(
          id: 'food_expensive_0',
          lines: ['あれっ、ちょっと豪華めですね！？', '…デートの練習ですか？ふふっ。']),
      ReactionPhrase(
          id: 'food_expensive_1',
          lines: ['2000円超え…お祝いですか？', '先輩、今月の予算、大丈夫です？']),
      ReactionPhrase(
          id: 'food_expensive_2', lines: ['わぁ、高めのごはん！', 'でも、美味しい時間も大事ですもんね。']),
      ReactionPhrase(
          id: 'food_expensive_3',
          lines: ['ご褒美ランチですか？', '頑張った日には、そういうのもありですよっ。']),
      ReactionPhrase(
          id: 'food_expensive_4',
          lines: ['ちょっと贅沢しましたねぇ。', '今度は私と、おうちごはんにしましょ？']),
    ];

    final allEntertainment = [
      ReactionPhrase(
          id: 'entertainment_0', lines: ['趣味の時間ですね！', '先輩が楽しんでるの、私もうれしいですっ。']),
      ReactionPhrase(
          id: 'entertainment_1', lines: ['ゲームかな？', 'うぅ…また私の記録抜いちゃいました？']),
      ReactionPhrase(
          id: 'entertainment_2',
          lines: ['リフレッシュ、大事ですよね！', 'でも、つい課金しすぎないようにですよっ。']),
      ReactionPhrase(
          id: 'entertainment_3', lines: ['お休みの日ですか？', 'のんびり過ごせたなら、それで100点です。']),
      ReactionPhrase(
          id: 'entertainment_4',
          lines: ['先輩の好きなこと、ちゃんと覚えてますよ？', '今度一緒にやってみたいですっ。']),
    ];

    final allSocial = [
      ReactionPhrase(id: 'social_0', lines: ['交際費ですね。', 'お友達と仲良くしてる先輩、素敵です。']),
      ReactionPhrase(id: 'social_1', lines: ['飲み会ですか？', '…あんまり飲みすぎないでくださいね？']),
      ReactionPhrase(
          id: 'social_2', lines: ['楽しかったですか？', '笑顔の時間は、貯金より大事かもです。']),
      ReactionPhrase(
          id: 'social_3',
          lines: ['お付き合いも必要ですよね。', 'でも…ちょっとだけ、私のことも思い出してくださいね？']),
      ReactionPhrase(
          id: 'social_4', lines: ['人との繋がり、大事ですもんね！', 'でも帰ったら、ちゃんと連絡くださいね。']),
    ];

    final allTransport = [
      ReactionPhrase(id: 'transport_0', lines: ['交通費ですね。', '今日も移動おつかれさまですっ。']),
      ReactionPhrase(
          id: 'transport_1', lines: ['電車代、入力しました！', 'ちゃんと安全に帰ってきてくださいね。']),
      ReactionPhrase(
          id: 'transport_2', lines: ['お出かけでした？', 'たまには遠くに行くのもいいですよね。']),
      ReactionPhrase(
          id: 'transport_3', lines: ['ガソリン代ですか？', '運転、無理しないでくださいよ？']),
      ReactionPhrase(
          id: 'transport_4', lines: ['出費メモ完了！', '行き先、今度私にも教えてくださいね。']),
    ];

    final allDaily = [
      ReactionPhrase(id: 'daily_0', lines: ['日用品ですね。', '生活って、こういう積み重ねですよね。']),
      ReactionPhrase(
          id: 'daily_1', lines: ['お買い物おつかれさまです。', 'ちゃんと必要なもの買っててえらいですっ。']),
      ReactionPhrase(
          id: 'daily_2', lines: ['シャンプーとかですか？', '先輩の香り、きっといい匂いなんだろうな…。']),
      ReactionPhrase(
          id: 'daily_3', lines: ['日用品って、地味に大事ですよね。', 'お金の使い方、ほんと上手になってきましたね。']),
      ReactionPhrase(
          id: 'daily_4', lines: ['ティッシュとか？', '…私もそろそろ買わなきゃ。おそろいですねっ。']),
    ];

    final allOther = [
      ReactionPhrase(
          id: 'other_0', lines: ['「その他」ですね？', 'ちょっと気になるなぁ、何に使ったんです？']),
      ReactionPhrase(
          id: 'other_1', lines: ['分類難しいやつですね？', 'わかりますっ、そういうのありますよねぇ。']),
      ReactionPhrase(
          id: 'other_2',
          lines: ['その他…ふむふむ。', 'えへへ、秘密でもいいですよ？ でも教えてくれたら嬉しいかも。']),
      ReactionPhrase(
          id: 'other_3', lines: ['その他ですね！', 'あんまり多くならないように、一緒に整理していきましょ。']),
      ReactionPhrase(
          id: 'other_4', lines: ['ん？その他？', '…怪しい出費じゃないですよね、先輩？（じーっ）']),
    ];

    final allAmountOneYen = [
      ReactionPhrase(
          id: 'amount_one_yen_0',
          lines: ['先輩、それって本気の数字ですか？', 'まさか、ボケてるんですよね？']),
      ReactionPhrase(
          id: 'amount_one_yen_1',
          lines: ['……もしかして、「おとに笑ってほしい」って狙いました？', 'ずるいなぁ、もう。']),
      ReactionPhrase(
          id: 'amount_one_yen_2',
          lines: ['そんなに可愛い金額、聞いたことないです。', 'でも、からかうのはナシですよ？ぷんっ。']),
      ReactionPhrase(
          id: 'amount_one_yen_3',
          lines: ['……先輩。', 'それ、落とした小銭のほうが多いかもしれません。', 'ほんとにもう、可愛い人。']),
      ReactionPhrase(
          id: 'amount_one_yen_4',
          lines: ['もしかして話したかっただけですか？', '……ふふ、じゃあ許します。']),
    ];

    final allAmountOverOneMillion = [
      ReactionPhrase(
          id: 'amount_million_0',
          lines: ['せ、先輩、桁、間違えてないですよね…？', 'ちょっと心臓に悪いです…！']),
      ReactionPhrase(
          id: 'amount_million_1', lines: ['もしかして車でも買ったんですか！？', '私、聞いてませんよ〜！']),
      ReactionPhrase(
          id: 'amount_million_2',
          lines: ['あの、先輩…？ 私たち、貯金するんですよね…？', '（ちょっと不安になっちゃいました…）']),
      ReactionPhrase(id: 'amount_million_3', lines: [
        '（…ごくり）',
        '先輩、もしかして石油王だったりします…？',
        'スケールが大きすぎて、おと、ちょっと怖いです…。'
      ]),
      ReactionPhrase(
          id: 'amount_million_4',
          lines: ['…あ、もしかして、数字をいっぱい押しちゃった、とか…？', 'ですよね？ そう言ってください！']),
    ];

    final allAmountTiny = [
      ReactionPhrase(id: 'amount_tiny_1', lines: ['え、えっ…これだけ？', '節約しすぎですよ、先輩']),
      ReactionPhrase(
          id: 'amount_tiny_2',
          lines: ['うそでしょ！？', '駄菓子でも買ったんですか？', '…かわいいけど、次はちゃんと使ってくださいね。']),
      ReactionPhrase(
          id: 'amount_tiny_3', lines: ['この金額...', 'もしかして、もやし生活してます？']),
      ReactionPhrase(
          id: 'amount_tiny_4',
          lines: ['先輩、それ…冗談ですか？', 'でも、ちゃんと報告してくれてうれしいです。']),
      ReactionPhrase(
          id: 'amount_tiny_7',
          lines: ['えっ、それで買い物したって言えるんですか？', 'もぉ〜〜、からかわないでください。']),
      ReactionPhrase(
          id: 'amount_tiny_8',
          lines: ['……先輩、節約しすぎは体に悪いですよ？', 'そのお金じゃ…おとにアイスも買えません！']),
    ];

    final allAmountCheap = [
      ReactionPhrase(
          id: 'amount_cheap_0', lines: ['ちょこっと出費ですね！', 'そういう小さな管理、ほんとに大事ですよ。']),
      ReactionPhrase(
          id: 'amount_cheap_1',
          lines: ['わぁ、細かく入力してくれてえらいですっ。', '私、そういうのちゃんと見てますからね。']),
      ReactionPhrase(
          id: 'amount_cheap_2',
          lines: ['飲み物かな？', '水分補給は大事です！でも、無理して我慢はナシですよ。']),
      ReactionPhrase(
          id: 'amount_cheap_3', lines: ['その調子です！', 'ちょっとずつでも積み上げが未来になりますね。']),
      ReactionPhrase(
          id: 'amount_cheap_4', lines: ['おっ、節約上手！', 'おと、ちゃんと褒めてあげたいです。']),
    ];

    final allAmountExpensive = [
      ReactionPhrase(
          id: 'amount_expensive_0',
          lines: ['わっ…！結構大きな出費ですね！？', '何買ったのか、ちょっと気になりますっ。']),
      ReactionPhrase(
          id: 'amount_expensive_1',
          lines: ['5000円超え…！', 'でも、先輩が考えて使ったならきっと大丈夫です。']),
      ReactionPhrase(
          id: 'amount_expensive_2', lines: ['びっくりしました…！', 'お財布、無理してないですよね？']),
      ReactionPhrase(
          id: 'amount_expensive_3',
          lines: ['これは大きいですねぇ。', 'でも、後悔してないならOKですっ。次は一緒に考えましょ？']),
      ReactionPhrase(
          id: 'amount_expensive_4',
          lines: ['どきどきする金額ですね…', 'でも、信じてます。先輩ならちゃんと計画してるはず。']),
    ];

    // --- ルールの定義 ---
    // 1円→100万円以上のリアクション
    _rules.add(ReactionRule(
      id: 'combo_one_yen_to_million', // 追加
      priority: 95,
      condition: (ctx) =>
          determineInputType(ctx.amount) == InputType.overMillion &&
          determineInputType(ctx.lastInputAmount) == InputType.oneYen,
      reaction: (ctx, playedIds) => ReactionPhrase(
          id: 'combo_one_yen_to_million',
          lines: [
            '1円の次に${ctx.amount}円…？',
            '先輩、私のこと完全におもちゃにしてますよね！？',
            'もう！ちゃんと真面目に入力してくださいっ！'
          ]),
    ));
    // 100万円以上→1円のリアクション
    _rules.add(ReactionRule(
      id: 'combo_million_to_one_yen', // 追加
      priority: 95,
      condition: (ctx) =>
          determineInputType(ctx.amount) == InputType.oneYen &&
          determineInputType(ctx.lastInputAmount) == InputType.overMillion,
      reaction: (ctx, playedIds) => ReactionPhrase(
          id: 'combo_million_to_one_yen',
          lines: ['1円って…', '先輩、振り幅大きすぎません！？', '私の心臓が持ちませんよ…']),
    ));

    // 1円リアクション
    _rules.add(ReactionRule(
      id: 'reaction_one_yen',
      priority: 90,
      condition: (ctx) => determineInputType(ctx.amount) == InputType.oneYen,
      reaction: (ctx, playedIds) {
        switch (ctx.oneYenCount) {
          case 1:
            final selected =
                _pickReaction('reaction_one_yen', allAmountOneYen, playedIds);
            return ReactionPhrase(
                id: selected.id, lines: ['1円...?', ...selected.lines]);
          case 2:
          case 3:
            return _pickReaction(
                'reaction_one_yen', allAmountOneYen, playedIds);
          case 4:
            return ReactionPhrase(
                id: 'amount_one_yen_angry_4',
                lines: ['も〜、わざとやってますよね？', '……おと、怒れないからずるいです。']);
          case 5:
            return ReactionPhrase(id: 'amount_one_yen_angry_5', lines: [
              '……先輩。もう5回目ですけど？',
              'おと、ちょっと本気で怒りますよ。',
              '……って言いながら、ちょっと笑ってますけど。'
            ]);
          // 6回目以降
          default:
            return ReactionPhrase(
                id: 'amount_one_yen_angry_final', lines: ['……先輩、本気で怒りますよ？']);
        }
      },
    ));

    // 100万円以上のときのリアクション
    _rules.add(ReactionRule(
      id: 'reaction_over_million',
      priority: 90,
      condition: (ctx) =>
          determineInputType(ctx.amount) == InputType.overMillion,
      reaction: (ctx, playedIds) {
        switch (ctx.overOneMillionCount) {
          case 1:
            final selected = _pickReaction(
                'reaction_over_million', allAmountOverOneMillion, playedIds);
            return ReactionPhrase(
                id: selected.id,
                lines: ['${ctx.amount}円..!?', ...selected.lines]);
          case 2:
          case 3:
            return _pickReaction(
                'reaction_over_million', allAmountOverOneMillion, playedIds);
          case 4:
            return ReactionPhrase(
                id: 'amount_million_angry_4',
                lines: ['もしかして、おとのことからかってます？', 'おとは騙されませんよ']);
          case 5:
            return ReactionPhrase(id: 'amount_million_angry_5', lines: [
              '……先輩。ちょっとしつこいですよ',
              '今なら大目に見てあげます',
              'こんなこと、言ってあげるの先輩だけですからね'
            ]);
          case 6:
            return ReactionPhrase(
                id: 'amount_million_angry_6', lines: ['しつこいですよ、先輩']);
          case 7:
            return ReactionPhrase(
                id: 'amount_million_angry_7', lines: ['はいはい、そうですか']);
          default:
            return ReactionPhrase(
                id: 'amount_million_angry_final', lines: ['へー']);
        }
      },
    ));

    _rules.add(ReactionRule(
      id: 'reaction_tiny_amount',
      priority: 75,
      condition: (ctx) => determineInputType(ctx.amount) == InputType.tiny,
      reaction: (ctx, playedIds) {
        return _pickReaction('reaction_tiny_amount', allAmountTiny, playedIds);
      },
    ));
    _rules.add(ReactionRule(
      id: 'reaction_cheap_amount',
      priority: 75,
      condition: (ctx) => determineInputType(ctx.amount) == InputType.cheap,
      reaction: (ctx, playedIds) =>
          _pickReaction('reaction_cheap_amount', allAmountCheap, playedIds),
    ));

    _rules.add(ReactionRule(
      id: 'reaction_expensive_amount',
      priority: 75,
      condition: (ctx) => determineInputType(ctx.amount) == InputType.expensive,
      reaction: (ctx, playedIds) => _pickReaction(
          'reaction_expensive_amount', allAmountExpensive, playedIds),
    ));

    _rules.add(ReactionRule(
      id: 'reaction_food',
      priority: 50,
      condition: (ctx) => ctx.category.id == 'food',
      reaction: (ctx, playedIds) {
        if (ctx.amount < 800) {
          return _pickReaction('reaction_food', allFoodCheap, playedIds);
        }
        if (ctx.amount < 2000) {
          return _pickReaction('reaction_food', allFoodNormal, playedIds);
        }
        return _pickReaction('reaction_food', allFoodExpensive, playedIds);
      },
    ));

    _rules.add(ReactionRule(
      id: 'reaction_transport',
      priority: 50,
      condition: (ctx) => ctx.category.id == 'transport',
      reaction: (ctx, playedIds) =>
          _pickReaction('reaction_transport', allTransport, playedIds),
    ));

    _rules.add(ReactionRule(
      id: 'reaction_entertainment',
      priority: 50,
      condition: (ctx) => ctx.category.id == 'entertainment',
      reaction: (ctx, playedIds) =>
          _pickReaction('reaction_entertainment', allEntertainment, playedIds),
    ));

    _rules.add(ReactionRule(
      id: 'reaction_social',
      priority: 50,
      condition: (ctx) => ctx.category.id == 'social',
      reaction: (ctx, playedIds) =>
          _pickReaction('reaction_social', allSocial, playedIds),
    ));

    _rules.add(ReactionRule(
      id: 'reaction_daily',
      priority: 50,
      condition: (ctx) => ctx.category.id == 'daily',
      reaction: (ctx, playedIds) =>
          _pickReaction('reaction_daily', allDaily, playedIds),
    ));

    _rules.add(ReactionRule(
      id: 'reaction_other',
      priority: 50,
      condition: (ctx) => ctx.category.id == 'other',
      reaction: (ctx, playedIds) =>
          _pickReaction('reaction_other', allOther, playedIds),
    ));
  }

  List<String> evaluate(EvaluationContext context) {
    final applicableRules =
        _rules.where((rule) => rule.condition(context)).toList();

    final ReactionPhrase reactionPhrase;

    if (applicableRules.isEmpty) {
      reactionPhrase = _pickReaction(
          "defalut",
          [
            ReactionPhrase(
                id: 'default_0', lines: ['入力しましたっ！', '今日もおつかれさまです、先輩。']),
            ReactionPhrase(
                id: 'default_1',
                lines: ['ふむふむ…OKですっ。', 'お金の記録って、ちゃんと向き合うの大事ですよね。']),
            ReactionPhrase(
                id: 'default_2',
                lines: ['はい、登録完了！', 'これでまた一歩、二人の未来貯金に近づきましたね。']),
            ReactionPhrase(
                id: 'default_3', lines: ['りょーかいです！', 'いつもちゃんと報告してくれてありがとうです。']),
            ReactionPhrase(
                id: 'default_4',
                lines: ['オッケーです！', 'えへへ、先輩と貯金するの、なんだか楽しいですね。']),
          ],
          _localStorageService.getPlayedReactionIdsForRule("defalut"));
    } else {
      applicableRules.sort((a, b) => b.priority.compareTo(a.priority));
      final topRule = applicableRules.first;
      final playedIds =
          _localStorageService.getPlayedReactionIdsForRule(topRule.id);
      reactionPhrase = topRule.reaction(context, playedIds);
      _localStorageService.addPlayedReactionIdForRule(
          topRule.id, reactionPhrase.id);
    }

    return reactionPhrase.lines;
  }
}
