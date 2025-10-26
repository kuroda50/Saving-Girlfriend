import 'dart:math' as math;
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:saving_girlfriend/widgets/transaction_modal.dart';
import '../providers/transaction_history_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _currentMonthDate;
  late DateTime _nextMonthDate;
  late AnimationController _pageFlipController;
  late Animation<double> _pageFlipAnimation;
  bool _isFlippingForward = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _currentMonthDate = DateTime(now.year, now.month, 1);
    _nextMonthDate = _currentMonthDate;

    // ページめくりアニメーション
    _pageFlipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pageFlipAnimation = CurvedAnimation(
      parent: _pageFlipController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageFlipController.dispose();
    super.dispose();
  }

  void _changeMonth(int direction) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _isFlippingForward = direction > 0;
      _nextMonthDate = DateTime(
        _currentMonthDate.year,
        _currentMonthDate.month + direction,
        1,
      );
    });

    _pageFlipController.forward(from: 0).then((_) {
      setState(() {
        _currentMonthDate = _nextMonthDate;
        _isAnimating = false;
      });
      _pageFlipController.reset();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  String _getGirlfriendComment(String category, int amount, String type) {
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

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: Stack(
        children: [
          // しおり（リボン）- スクロールしない固定要素
          _buildBookmark(),
          // メインコンテンツ（背景も含めてスクロール）
          transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('エラー: $err')),
            data: (allTransactions) {
              if (!_isAnimating) {
                // アニメーション中ではない時：現在の月だけを描画
                return _buildMonthContent(_currentMonthDate, allTransactions);
              }

              // アニメーション中の時：
              // ページ（重いWidget）をここで「1回だけ」構築する
              final Widget currentPageWidget =
                  _buildMonthContent(_currentMonthDate, allTransactions);
              final Widget nextPageWidget =
                  _buildMonthContent(_nextMonthDate, allTransactions);

              final Widget bottomWidget =
                  _isFlippingForward ? currentPageWidget : nextPageWidget;
              final Widget topWidget =
                  _isFlippingForward ? nextPageWidget : currentPageWidget;

              // Stackに構築済みのWidgetを渡す
              return Stack(
                children: [
                  // 下のページ（次のページ）
                  bottomWidget,

                  // めくれるページ（現在のページ）
                  RepaintBoundary(
                    child: PageTurnTransition(
                      animation: _pageFlipAnimation,
                      isForward: _isFlippingForward,
                      child: topWidget, // 構築済みのWidgetを渡す
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthContent(DateTime monthDate, List<dynamic> allTransactions) {
    final selectedTransactions = allTransactions.where((t) {
      return DateUtils.isSameDay(t.date, _selectedDate);
    }).toList();

    Map<String, int> calculateDailyTransactions() {
      final dailyTransaction = <String, int>{};
      for (var transaction in allTransactions) {
        final date = transaction.date;
        final amount = transaction.amount;
        if (date.month == monthDate.month && date.year == monthDate.year) {
          final formattedDate = DateFormat('yyyy-MM-dd').format(date);
          dailyTransaction[formattedDate] =
              ((dailyTransaction[formattedDate] ?? 0) +
                  (transaction.type == "income" ? amount : -amount)) as int;
        }
      }
      return dailyTransaction;
    }

    int getDaysInMonth() =>
        DateTime(monthDate.year, monthDate.month + 1, 0).day;

    int getStartDayOfMonth() {
      final weekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
      return weekday == 7 ? 0 : weekday;
    }

    final dailyTransaction = calculateDailyTransactions();

    return SingleChildScrollView(
      child: Stack(
        children: [
          // 紙のテクスチャ背景（スクロールに追従）
          Positioned.fill(
            child: CustomPaint(
              painter: PaperTexturePainter(),
            ),
          ),
          // 罫線背景（スクロールに追従）
          Positioned.fill(
            child: CustomPaint(
              painter: NotebookLinesPainter(),
            ),
          ),
          // コンテンツ
          Column(
            children: [
              // ヘッダー部分
              _buildNotebookHeader(monthDate),

              // カレンダー部分
              _buildCalendarSection(
                dailyTransaction,
                getDaysInMonth,
                getStartDayOfMonth,
                monthDate,
              ),

              // 履歴タイトル
              _buildSectionTitle(),

              // 履歴リスト
              selectedTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionList(
                      selectedTransactions,
                      NumberFormat.currency(locale: 'ja_JP', symbol: '¥'),
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  // しおり（リボン）
  Widget _buildBookmark() {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Positioned(
      top: 0,
      right: 60,
      child: AnimatedOpacity(
        opacity: isToday ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 30,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF69B4),
                Color(0xFFFF1493),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // リボンの光沢
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // リボンの切れ込み
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(30, 20),
                  painter: RibbonCutPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookHeader(DateTime monthDate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 70, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF5F5), Color(0xFFFFFEF9)],
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFFB6C1), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMonthNavButton(Icons.chevron_left, () => _changeMonth(-1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB6C1), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('💕', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '${monthDate.year}年${monthDate.month}月',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF69B4),
                    fontFamily: 'Klee One',
                    shadows: [
                      Shadow(
                        color: Color(0xFFFFE4E1),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('💕', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          _buildMonthNavButton(Icons.chevron_right, () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    Map<String, int> dailyTransaction,
    int Function() getDaysInMonth,
    int Function() getStartDayOfMonth,
    DateTime monthDate,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE4E1), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF69B4).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 曜日ヘッダー
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: ['日', '月', '火', '水', '木', '金', '土']
                  .asMap()
                  .entries
                  .map((entry) => Expanded(
                        child: Center(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: entry.key == 0
                                  ? const Color(0xFFFF1493)
                                  : entry.key == 6
                                      ? const Color(0xFF4169E1)
                                      : const Color(0xFFFF69B4),
                              fontFamily: 'Klee One',
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // カレンダーグリッド
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: getDaysInMonth() + getStartDayOfMonth(),
            itemBuilder: (context, index) {
              final startDay = getStartDayOfMonth();
              final day = index - startDay + 1;
              final isCurrentMonthDay = day > 0 && day <= getDaysInMonth();

              if (!isCurrentMonthDay) {
                return const SizedBox.shrink();
              }

              final date = DateTime(monthDate.year, monthDate.month, day);
              final isSelected = DateUtils.isSameDay(_selectedDate, date);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final amount = dailyTransaction[dateKey];

              return GestureDetector(
                onTap: () => _selectDate(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFFE4E1), Color(0xFFFFF0F5)],
                          )
                        : isToday
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFFFFFFE0).withOpacity(0.6),
                                  const Color(0xFFFFFFF0).withOpacity(0.6),
                                ],
                              )
                            : null,
                    color: !isSelected && !isToday
                        ? const Color(0xFFFFFEF9)
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF69B4)
                          : isToday
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFFFE4E1),
                      width: isSelected ? 2 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF69B4).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isToday
                              ? const Color(0xFFFF1493)
                              : const Color(0xFFFF69B4),
                          fontFamily: 'Klee One',
                        ),
                      ),
                      if (amount != null)
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(top: 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            decoration: BoxDecoration(
                              color: amount > 0
                                  ? const Color(0xFFE0FFE0)
                                  : const Color(0xFFFFE0E0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatAmountForCalendar(amount),
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: amount > 0
                                      ? const Color(0xFF228B22)
                                      : const Color(0xFFFF1493),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: const Border(
            left: BorderSide(color: Color(0xFFFF69B4), width: 5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF69B4).withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${DateFormat('MM月dd日').format(_selectedDate)}の出来事',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF69B4),
                  fontFamily: 'Klee One',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Text('📝', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB6C1), Color(0xFFFFC0CB)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF69B4).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💕', style: TextStyle(fontSize: 60)),
          SizedBox(height: 15),
          Text(
            'この日の記録はまだないよ\n新しい思い出を作ろう！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFFFB6C1),
              fontFamily: 'Klee One',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<dynamic> selectedTransactions,
    NumberFormat currencyFormatter,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE4E1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: selectedTransactions.map((transaction) {
          final isToday = DateUtils.isSameDay(transaction.date, DateTime.now());
          final type = transaction.type;
          final amount = transaction.amount;
          final category = transaction.category as String? ?? 'カテゴリなし';
          final comment = _getGirlfriendComment(category, amount, type);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: selectedTransactions.indexOf(transaction) <
                      selectedTransactions.length - 1
                  ? const Border(
                      bottom: BorderSide(
                        color: Color(0xFFFFE4E1),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // トランザクション情報
                Row(
                  children: [
                    // アイコン
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: type == "income"
                              ? [
                                  const Color(0xFF98FB98),
                                  const Color(0xFF90EE90)
                                ]
                              : [
                                  const Color(0xFFFFB6C1),
                                  const Color(0xFFFFC0CB)
                                ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: type == "income"
                              ? const Color(0xFF32CD32)
                              : const Color(0xFFFF69B4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (type == "income"
                                    ? const Color(0xFF32CD32)
                                    : const Color(0xFFFF69B4))
                                .withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          type == "income" ? "↑" : "↓",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: type == "income"
                                ? const Color(0xFF228B22)
                                : const Color(0xFFFF1493),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // カテゴリと金額（蛍光ペン風ハイライト）
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                              fontFamily: 'Klee One',
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 金額に蛍光ペン風のハイライト
                          Stack(
                            children: [
                              // ハイライト背景
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 2,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: (type == "income"
                                            ? const Color(0xFFFFFF00)
                                            : const Color(0xFFFFB6C1))
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // 金額テキスト
                              Text(
                                currencyFormatter.format(amount),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: type == "income"
                                      ? const Color(0xFF228B22)
                                      : const Color(0xFFFF1493),
                                  fontFamily: 'Klee One',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 編集・削除ボタン
                    if (isToday) ...[
                      _buildActionButton(
                        Icons.edit,
                        () {
                          showTransactionModal(
                            context,
                            onSave: (updatedData) {
                              final transactionId = updatedData.id;
                              ref
                                  .read(transactionsProvider.notifier)
                                  .updateTransaction(
                                      transactionId, updatedData);
                            },
                            initialTransaction: transaction,
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildActionButton(
                        Icons.delete,
                        () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFFFFF9F0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: const BorderSide(
                                    color: Color(0xFFFFB6C1),
                                    width: 2,
                                  ),
                                ),
                                title: const Text(
                                  "確認",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Klee One',
                                    color: Color(0xFFFF69B4),
                                  ),
                                ),
                                content: const Text(
                                  'この履歴を削除するのね？',
                                  style: TextStyle(fontFamily: 'Klee One'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    child: const Text(
                                      "キャンセル",
                                      style: TextStyle(
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF69B4),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 3,
                                    ),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      ref
                                          .read(transactionsProvider.notifier)
                                          .removeTransaction(transaction.id);
                                    },
                                    child: const Text("削除"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // 彼女のコメント（付箋風）
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFACD),
                        Color(0xFFFFFFE0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border:
                        Border.all(color: const Color(0xFFFFD700), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 付箋のテープ風装飾
                      Positioned(
                        top: -6,
                        left: 8,
                        child: Container(
                          width: 30,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // コメントテキスト
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          comment,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFF1493),
                            fontFamily: 'Klee One',
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFE4E1), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB6C1).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Icon(icon, size: 18, color: const Color(0xFFFF69B4)),
        ),
      ),
    );
  }
}

// ページめくりトランジション
class PageTurnTransition extends StatelessWidget {
  const PageTurnTransition({
    super.key,
    required this.animation,
    required this.child,
    required this.isForward,
  });

  final Animation<double> animation;
  final Widget child;
  final bool isForward;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _OverleafPainter(
            animation: animation,
            color: const Color(0xFFE8E8E8),
            isForward: isForward,
          ),
          child: ClipPath(
            clipper: _PageTurnClipper(
              animation: animation,
              isForward: isForward,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ページの表示領域を切り取るClipper
class _PageTurnClipper extends CustomClipper<Path> {
  const _PageTurnClipper({
    required this.animation,
    required this.isForward,
  });

  final Animation<double> animation;
  final bool isForward;

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final t = animation.value;

    if (isForward) {
      // 次の月： 0 (空) -> 1 (全体)
      if (t < 0.001) {
        return Path(); // アニメーション開始時は何も表示しない
      }
      if (t > 0.999) {
        // アニメーション終了時は全体を表示
        return Path()..addRect(Rect.fromLTWH(0, 0, width, height));
      }
    } else {
      // 前の月（逆再生）： 0 (全体) -> 1 (空)
      if (t < 0.001) {
        // アニメーション開始時は全体を表示
        return Path()..addRect(Rect.fromLTWH(0, 0, width, height));
      }
      if (t > 0.999) {
        return Path(); // アニメーション終了時は何も表示しない
      }
    }

    final tEff = isForward ? t : 1.0 - t;

    const te = 0.5;

    late Offset foldUpperCorner;
    late Offset foldLowerCorner;

    foldUpperCorner = Offset(width * (1 - tEff), 0);
    if (tEff <= te) {
      final tPhase1 = tEff / te;
      foldLowerCorner = Offset(width, height * tPhase1);
    } else {
      final tPhase2 = (tEff - te) / (1 - te);
      foldLowerCorner = Offset(width * (1 - tPhase2), height);
    }

    return Path()
      ..moveTo(foldUpperCorner.dx, foldUpperCorner.dy)
      ..lineTo(width, 0)
      ..lineTo(width, height)
      ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
      ..close();
  }

  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    return true;
  }
}

// めくられたページの裏側を描画するPainter
class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.isForward,
  });

  final Animation<double> animation;
  final Color color;
  final bool isForward;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final t = animation.value;

    final tEff = isForward ? t : 1.0 - t;

    if (tEff < 0.001 || tEff > 0.999) return;

    const te = 0.5;

    late Offset topCorner;
    late Offset foldUpperCorner;
    late Offset foldLowerCorner;

    // 次の月：左にめくる
    topCorner = Offset(width, 0);
    foldUpperCorner = Offset(width * (1 - tEff), 0);
    if (tEff <= te) {
      foldLowerCorner = Offset(width, height * tEff / te);
    } else {
      final tPhase2 = (tEff - te) / (1 - te);
      foldLowerCorner = Offset(width * (1 - tPhase2), height);
    }

    // 折り目に対して線対称な点を計算
    final foldMidpoint = Offset(
      (foldUpperCorner.dx + foldLowerCorner.dx) / 2,
      (foldUpperCorner.dy + foldLowerCorner.dy) / 2,
    );

    // 折り目の傾き
    final foldDx = foldLowerCorner.dx - foldUpperCorner.dx;
    final foldDy = foldLowerCorner.dy - foldUpperCorner.dy;

    // 角から折り目に垂線を下ろし、その反対側の点を求める
    final toCorner = Offset(
      topCorner.dx - foldMidpoint.dx,
      topCorner.dy - foldMidpoint.dy,
    );
    final foldLength = (foldDx * foldDx + foldDy * foldDy);

    if (foldLength > 0) {
      final projection =
          (toCorner.dx * foldDx + toCorner.dy * foldDy) / foldLength;
      final projectionPoint = Offset(
        foldMidpoint.dx + projection * foldDx,
        foldMidpoint.dy + projection * foldDy,
      );

      final mirroredCorner = Offset(
        2 * projectionPoint.dx - topCorner.dx,
        2 * projectionPoint.dy - topCorner.dy,
      );

      // めくられた部分を描画
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(foldUpperCorner.dx, foldUpperCorner.dy)
        ..lineTo(mirroredCorner.dx, mirroredCorner.dy)
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
        ..close();

      canvas.drawPath(path, paint);

      // 影を追加
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(_OverleafPainter oldDelegate) {
    return true;
  }
}

// 紙のテクスチャを描画するCustomPainter
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF9F0)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 紙の質感を表現する微細なノイズ
    final random = math.Random(42);
    final noisePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * 0.03;

      noisePaint.color = const Color(0xFFD2B48C).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 罫線背景を描画するCustomPainter
class NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 横罫線
    final linePaint = Paint()
      ..color = const Color(0xFFE8DCC8).withOpacity(0.5)
      ..strokeWidth = 1.5;

    const lineSpacing = 28.0;

    for (double y = 60; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // 左マージン線（より目立つように）
    final marginPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withOpacity(0.5)
      ..strokeWidth = 2.5;

    canvas.drawLine(
      const Offset(40, 0),
      Offset(40, size.height),
      marginPaint,
    );

    // マージン線に沿った装飾的なステッチ風のライン
    final stitchPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withOpacity(0.3)
      ..strokeWidth = 1;

    for (double y = 10; y < size.height; y += 15) {
      canvas.drawLine(
        const Offset(38, 0).translate(0, y),
        const Offset(38, 0).translate(0, y + 8),
        stitchPaint,
      );
      canvas.drawLine(
        const Offset(42, 0).translate(0, y),
        const Offset(42, 0).translate(0, y + 8),
        stitchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// リボンの切れ込みを描画するCustomPainter
class RibbonCutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF1493)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
