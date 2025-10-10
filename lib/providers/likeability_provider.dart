import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/providers/tribute_history_provider.dart';

part 'likeability_provider.g.dart';

@riverpod
Future<int> likeability(Ref ref) async {
  final tributeHistory = await ref.watch(tributeHistoryProvider.future);
  final int totalTribute =
      tributeHistory.fold(0, (sum, item) => sum + item.amount);
  return _calculateLikeability(totalTribute);
}

int _calculateLikeability(final int totalTribute) {
  double likeability;

  if (totalTribute < 10000) {
    likeability = (totalTribute / 10000.0) * 10.0;
  } else if (totalTribute < 30000) {
    likeability = 10.0 + ((totalTribute - 10000) / 20000.0) * 10.0;
  } else if (totalTribute < 60000) {
    likeability = 20.0 + ((totalTribute - 30000) / 30000.0) * 10.0;
  } else {
    likeability = 30.0 + ((totalTribute - 60000) / 10000.0);
  }

  return max(0.0, likeability).floor();
}
