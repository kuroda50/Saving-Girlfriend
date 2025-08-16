import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saving_girlfriend/constants/color.dart';
import '../providers/tribute_history_provider.dart';

// StatelessWidgetをConsumerWidgetに変更します
class TributeHistoryScreen extends ConsumerWidget {
  const TributeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watchでProviderを監視し、データの状態を取得します
    final tributeHistoryAsync = ref.watch(tributeHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      // .whenを使って、データの状態（読込中/エラー/成功）に応じて表示を切り替えます
      body: tributeHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
        data: (state) {
          // データ取得成功時に、state（TributeHistoryState）を使ってUIを構築します

          Map<String, int> calculateDailyTributes() {
            final dailyTributes = <String, int>{};
            for (var tribute in state.tributeHistory) {
              final date = tribute['date'];
              final int amount = tribute['amount'] as int;
              final DateTime tributeDate = DateTime.parse(date);

              if (tributeDate.month == state.currentMonth &&
                  tributeDate.year == state.currentYear) {
                final String formattedDate =
                    '${tributeDate.year}-${tributeDate.month.toString().padLeft(2, '0')}-${tributeDate.day.toString().padLeft(2, '0')}';
                dailyTributes[formattedDate] =
                    (dailyTributes[formattedDate] ?? 0) + amount;
              }
            }
            return dailyTributes;
          }

          int getDaysInMonth() {
            return DateTime(state.currentYear, state.currentMonth + 1, 0).day;
          }

          int getStartDayOfMonth() {
            final weekday =
                DateTime(state.currentYear, state.currentMonth, 1).weekday;
            return weekday == 7 ? 0 : weekday;
          }
          // --- ここまで計算ロジック ---

          final dailyTributes = calculateDailyTributes();

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border,
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: AppColors.primary),
                            onPressed: () => ref
                                .read(tributeHistoryProvider.notifier)
                                .changeMonth(-1),
                          ),
                          Text(
                            '${state.currentYear}年 ${state.currentMonth}月',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: AppColors.primary),
                            onPressed: () => ref
                                .read(tributeHistoryProvider.notifier)
                                .changeMonth(1),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: ['日', '月', '火', '水', '木', '金', '土']
                              .map((day) => Expanded(
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: day == '日' || day == '土'
                                            ? AppColors.thirdBackground
                                            : AppColors.subBackground,
                                      ),
                                      child: Center(
                                        child: Text(
                                          day,
                                          style: const TextStyle(
                                            color: AppColors.subText,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: getDaysInMonth() + getStartDayOfMonth(),
                        itemBuilder: (context, index) {
                          final startDay = getStartDayOfMonth();
                          final day = index - startDay + 1;
                          final isCurrentMonthDay =
                              day > 0 && day <= getDaysInMonth();
                          final dateString =
                              '${state.currentYear}-${state.currentMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          final dailyTribute = dailyTributes[dateString] ?? 0;

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              color: AppColors.mainBackground,
                            ),
                            child: isCurrentMonthDay
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        day.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      if (dailyTribute != 0)
                                        Text(
                                          '${dailyTribute}円',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primary),
                                        ),
                                    ],
                                  )
                                : Container(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '貢ぎ履歴',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.tributeHistory.map((expense) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(expense['date']))),
                                Row(
                                  children: [
                                    Text('${expense['amount']}円'),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: AppColors.border),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '変更',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.subBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '目標設定',
                          style: TextStyle(
                            color: AppColors.subText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '合計金額  ${state.targetSavingAmount}円',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Text(
                            '目標の    80%',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
