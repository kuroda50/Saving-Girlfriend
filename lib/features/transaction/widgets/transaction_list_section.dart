import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_type.dart';
import 'package:saving_girlfriend/features/transaction/providers/transaction_history_provider.dart';
import 'package:saving_girlfriend/features/transaction/utils/utils.dart';
import 'package:saving_girlfriend/features/transaction/widgets/transaction_modal.dart';

class TransactionListSection extends ConsumerWidget {
  final DateTime selectedDate;
  final List<TransactionState> selectedTransactions;

  const TransactionListSection({
    super.key,
    required this.selectedDate,
    required this.selectedTransactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SectionTitle(selectedDate: selectedDate),
        selectedTransactions.isEmpty
            ? const _EmptyState()
            : _TransactionList(
                selectedTransactions: selectedTransactions,
              ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final DateTime selectedDate;

  const _SectionTitle({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
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
                '${DateFormat('MM月dd日').format(selectedDate)}の出来事',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF69B4),
                  fontFamily: 'Klee One',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
}

class _TransactionList extends StatelessWidget {
  final List<TransactionState> selectedTransactions;

  const _TransactionList({required this.selectedTransactions});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
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
          return _TransactionListItem(
            transaction: transaction,
            currencyFormatter: currencyFormatter,
            isLastItem: selectedTransactions.indexOf(transaction) ==
                selectedTransactions.length - 1,
          );
        }).toList(),
      ),
    );
  }
}

class _TransactionListItem extends ConsumerWidget {
  final TransactionState transaction;
  final NumberFormat currencyFormatter;
  final bool isLastItem;

  const _TransactionListItem({
    required this.transaction,
    required this.currencyFormatter,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = DateUtils.isSameDay(transaction.date, DateTime.now());
    final type = transaction.type;
    final amount = transaction.amount;
    final category = transaction.category;
    // [注意] この 'getGirlfriendComment' 関数も enum を受け取るように修正が必要です
    final comment = getGirlfriendComment(category, amount, type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLastItem
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFFFE4E1),
                  width: 1,
                ),
              ),
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
                    // [修正] type == "income" を enum 比較に変更
                    colors: type == TransactionType.income
                        ? [const Color(0xFF98FB98), const Color(0xFF90EE90)]
                        : [const Color(0xFFFFB6C1), const Color(0xFFFFC0CB)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    // [修正] type == "income" を enum 比較に変更
                    color: type == TransactionType.income
                        ? const Color(0xFF32CD32)
                        : const Color(0xFFFF69B4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // [修正] type == "income" を enum 比較に変更
                      color: (type == TransactionType.income
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
                    // [修正] type == "income" を enum 比較に変更
                    type == TransactionType.income ? "↑" : "↓",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // [修正] type == "income" を enum 比較に変更
                      color: type == TransactionType.income
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
                      // [修正] category (enum) を .displayName (String) に変更
                      category.displayName,
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
                              // [修正] type == "income" を enum 比較に変更
                              color: (type == TransactionType.income
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
                            // [修正] type == "income" を enum 比較に変更
                            color: type == TransactionType.income
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
                _ActionButton(
                  icon: Icons.edit,
                  onPressed: () {
                    showTransactionModal(
                      context,
                      onSave: (updatedData) {
                        final transactionId = updatedData.id;
                        ref
                            .read(transactionsProvider.notifier)
                            .updateTransaction(transactionId, updatedData);
                      },
                      initialTransaction: transaction,
                    );
                  },
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.delete,
                  onPressed: () {
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
              border: Border.all(color: const Color(0xFFFFD700), width: 1),
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
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
