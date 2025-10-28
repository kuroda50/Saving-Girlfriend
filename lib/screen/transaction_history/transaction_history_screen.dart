import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';

import 'package:saving_girlfriend/providers/transaction_history_provider.dart';
import 'package:saving_girlfriend/screen/transaction_history/widgets/bookmark_widget.dart';
import 'package:saving_girlfriend/screen/transaction_history/widgets/calendar_section.dart';
import 'package:saving_girlfriend/screen/transaction_history/widgets/notebook_header.dart';
import 'package:saving_girlfriend/screen/transaction_history/widgets/painters.dart';
import 'package:saving_girlfriend/screen/transaction_history/widgets/transaction_list_section.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonthDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _currentMonthDate = DateTime(now.year, now.month, 1);
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonthDate = DateTime(
        _currentMonthDate.year,
        _currentMonthDate.month + direction,
        1,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: Stack(
        children: [
          BookmarkWidget(isToday: isToday),
          transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('エラー: $err')),
            data: (allTransactions) {
              return _buildMonthContent(allTransactions);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthContent(List<TransactionState> allTransactions) {
    final selectedTransactions = allTransactions.where((t) {
      return DateUtils.isSameDay(t.date, _selectedDate);
    }).toList();

    Map<String, int> calculateDailyTransactions() {
      final dailyTransaction = <String, int>{};
      for (var transaction in allTransactions) {
        final date = transaction.date;
        final amount = transaction.amount;
        if (date.month == _currentMonthDate.month &&
            date.year == _currentMonthDate.year) {
          final formattedDate = DateFormat('yyyy-MM-dd').format(date);
          dailyTransaction[formattedDate] =
              ((dailyTransaction[formattedDate] ?? 0) +
                  (transaction.type == "income" ? amount : -amount));
        }
      }
      return dailyTransaction;
    }

    final dailyTransaction = calculateDailyTransactions();

    return SingleChildScrollView(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PaperTexturePainter(),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: NotebookLinesPainter(),
            ),
          ),
          Column(
            children: [
              NotebookHeader(
                monthDate: _currentMonthDate,
                onPreviousMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
              ),
              CalendarSection(
                selectedDate: _selectedDate,
                monthDate: _currentMonthDate,
                dailyTransaction: dailyTransaction,
                onDateSelected: _selectDate,
              ),
              TransactionListSection(
                selectedDate: _selectedDate,
                selectedTransactions: selectedTransactions,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
