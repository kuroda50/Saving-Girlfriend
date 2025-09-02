import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/local_storage_service.dart';

void main() async {
  return;

  // 後で実装する
  // group('ローカルストレージのテスト', () {
  //   setUp(() async {
  //     SharedPreferences.setMockInitialValues({});
  //     await LocalStorageService.init();
  //   });
  //   test('データの保存と読み込みが成功するかのテスト', () {
  //     final task = Task(title: 'new task'); // タスクを作成
  //     print('タスク作成: ${task.title}, 完了状態: ${task.isCompleted}');

  //     expect(task.title, 'new task');
  //     expect(task.isCompleted, false);
  //   });

  //   test('存在しないデータを読み込もうとした時のテスト', () {
  //     final task = Task(title: 'new task'); // タスクを作成

  //     print('タスク作成前: 完了状態: ${task.isCompleted}');
  //     task.toggleComplete(); // ここでタスク完了のtrueにする
  //     print('タスク完了後: 完了状態: ${task.isCompleted}');

  //     expect(task.isCompleted, true);
  //   });
  //   test('データを更新できるかのテスト', () {
  //     final task = Task(title: 'new task'); // タスクを作成

  //     print('タスク作成前: 完了状態: ${task.isCompleted}');
  //     task.toggleComplete(); // ここでタスク完了のtrueにする
  //     print('タスク完了後: 完了状態: ${task.isCompleted}');

  //     expect(task.isCompleted, true);
  //   });
  // });
}
