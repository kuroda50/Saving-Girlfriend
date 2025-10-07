import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/models/budget_history.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

part 'budget_history_provider.g.dart';

/// 予算の変更履歴リストを提供するプロバイダー
@Riverpod(keepAlive: true)
Future<List<BudgetHistory>> budgetHistory(Ref ref) async {
  // LocalStorageService のインスタンスが準備できるのを待つ
  final localStorage = await ref.watch(localStorageServiceProvider.future);

  // 予算履歴を取得して返す
  final history = await localStorage.getBudgetHistory();
  return history;
}
