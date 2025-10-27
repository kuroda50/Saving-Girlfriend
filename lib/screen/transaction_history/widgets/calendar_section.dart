import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

class CalendarSection extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime monthDate;
  final Map<String, int> dailyTransaction;
  final Function(DateTime) onDateSelected;

  const CalendarSection({
    super.key,
    required this.selectedDate,
    required this.monthDate,
    required this.dailyTransaction,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    int getDaysInMonth() =>
        DateTime(monthDate.year, monthDate.month + 1, 0).day;
    int getStartDayOfMonth() {
      final weekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
      return weekday == 7 ? 0 : weekday;
    }

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
              final isSelected = DateUtils.isSameDay(selectedDate, date);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final amount = dailyTransaction[dateKey];

              return GestureDetector(
                onTap: () => onDateSelected(date),
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
}
