// Dart imports:
import 'dart:math';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:saving_girlfriend/features/tribute/providers/tribute_history_provider.dart';

part 'likeability_provider.g.dart';

@riverpod
Future<int> likeability(LikeabilityRef ref) async {
  final tributeHistory = await ref.watch(tributeHistoryProvider.future);
  final int totalTribute =
      tributeHistory.fold(0, (sum, item) => sum + item.amount);
  return _calculateLikeability(totalTribute);
}

/// 貢いだ総額に基づいて好感度を計算します。
int _calculateLikeability(final int totalTribute) {
  // 好感度計算用の定数
  const level1Threshold = 10000;
  const level2Threshold = 30000;
  const level3Threshold = 60000;

  const level1Likeability = 10.0;
  const level2Likeability = 20.0;
  const level3Likeability = 30.0;

  const endlessRate = 10000.0;

  double likeability;

  // レベル1：10,000円までのフェーズ
  // 1,000円貢ぐごとに好感度が1増加します。
  if (totalTribute < level1Threshold) {
    likeability = (totalTribute / level1Threshold) * level1Likeability;
  }
  // レベル2：30,000円までのフェーズ
  // 10,000円を超えてから2,000円貢ぐごとに好感度が1増加します。
  else if (totalTribute < level2Threshold) {
    likeability = level1Likeability +
        ((totalTribute - level1Threshold) /
                (level2Threshold - level1Threshold)) *
            (level2Likeability - level1Likeability);
  }
  // レベル3：60,000円までのフェーズ
  // 30,000円を超えてから3,000円貢ぐごとに好感度が1増加します。
  else if (totalTribute < level3Threshold) {
    likeability = level2Likeability +
        ((totalTribute - level2Threshold) /
                (level3Threshold - level2Threshold)) *
            (level3Likeability - level2Likeability);
  }
  // エンドレスレベル：60,000円以降
  // 10,000円貢ぐごとに好感度が1増加します。
  else {
    likeability =
        level3Likeability + ((totalTribute - level3Threshold) / endlessRate);
  }

  // 好感度がマイナスにならないようにします。
  return max(0.0, likeability).floor();
}
