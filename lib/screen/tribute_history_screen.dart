import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'package:intl/intl.dart';

class TributeHistoryScreen extends StatelessWidget {
  const TributeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BudgetScreen();
  }
}

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  List<Map<String, dynamic>> _tributeHistory = [];
  Map<String, int> _dailyTributes = {};
  int _targetSavingAmount = 0;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tributeHistory = await _localStorageService.getTributeHistory();
    final targetSavingAmount =
        await _localStorageService.getTargetSavingAmount() ?? 0;
    setState(() {
      _tributeHistory = tributeHistory;
      _targetSavingAmount = targetSavingAmount;
      _calculateDailyTributes();
    });
  }

  void _calculateDailyTributes() {
    _dailyTributes.clear();
    for (var tribute in _tributeHistory) {
      final date = tribute['date'];
      final int amount = tribute['amount'] as int;
      if (date != null && amount != null) {
        final DateTime tributeDate = DateTime.parse(date);
        if (tributeDate.month == currentMonth &&
            tributeDate.year == currentYear) {
          final String formattedDate =
              '${tributeDate.year}-${tributeDate.month.toString().padLeft(2, '0')}-${tributeDate.day.toString().padLeft(2, '0')}';
          _dailyTributes[formattedDate] =
              (_dailyTributes[formattedDate] ?? 0) + amount;
        }
      }
    }
  }

  int _getDaysInMonth(int month) {
    return DateTime(currentYear, month + 1, 0).day;
  }

  int _getStartDayOfMonth() {
    return DateTime(currentYear, currentMonth, 1).weekday == 7
        ? 0
        : DateTime(currentYear, currentMonth, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          // カレンダー部分
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
                // 月表示と矢印
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          if (currentMonth == 1) {
                            currentMonth = 12;
                            currentYear--;
                          } else {
                            currentMonth--;
                          }
                          _calculateDailyTributes();
                        });
                      },
                    ),
                    Text(
                      '$currentMonth月',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          if (currentMonth == 12) {
                            currentMonth = 1;
                            currentYear++;
                          } else {
                            currentMonth++;
                          }
                          _calculateDailyTributes();
                        });
                      },
                    ),
                  ],
                ),

                // 曜日ヘッダー
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

                // カレンダーグリッド
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount:
                      _getDaysInMonth(currentMonth) + _getStartDayOfMonth(),
                  itemBuilder: (context, index) {
                    final int day = index - _getStartDayOfMonth() + 1;
                    final bool isCurrentMonthDay =
                        day > 0 && day <= _getDaysInMonth(currentMonth);
                    final String dateString =
                        '$currentYear-${currentMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                    final int dailyTribute = _dailyTributes[dateString] ?? 0;

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
                                        fontSize: 10, color: AppColors.primary),
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

          // 支出履歴部分
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
                ..._tributeHistory.map((expense) => Padding(
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
                                  border: Border.all(color: AppColors.border),
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

          // 目標設定部分
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      '合計金額  $_targetSavingAmount円',
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
        ])));
  }
}

class ExpenseItem {
  final String date;
  final int amount;

  const ExpenseItem({required this.date, required this.amount});
}
