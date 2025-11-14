// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/constants/settings_defaults.dart';
import 'package:saving_girlfriend/features/settings/models/settings_state.dart';
import 'package:saving_girlfriend/features/settings/providers/setting_provider.dart';

import '../widgets/bgm_volume_row.dart';
import '../widgets/daily_budget_row.dart';
import '../widgets/notification_toggle_row.dart';
// Project imports:
import '../widgets/section_header.dart';
import '../widgets/settings_container.dart';
import '../widgets/target_saving_row.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;
  late double _bgmVolume;
  final TextEditingController targetSavingsController = TextEditingController();
  final TextEditingController dailyBudgetController = TextEditingController();

  late bool _initialNotificationsEnabled;
  late double _initialBgmVolume;
  late String _initialTargetSavings;
  late String _initialDailyBudget;

  @override
  void initState() {
    super.initState();
    final initialSettings = ref.read(settingsProvider).value;
    if (initialSettings != null) {
      _notificationsEnabled = initialSettings.notificationsEnabled;
      _bgmVolume = initialSettings.bgmVolume;
      targetSavingsController.text =
          (initialSettings.targetSavingAmount / 10000).toInt().toString();
      dailyBudgetController.text = initialSettings.dailyBudget.toString();
    } else {
      _notificationsEnabled = SettingsDefaults.notificationsEnabled;
      _bgmVolume = SettingsDefaults.bgmVolume;
      targetSavingsController.text =
          (SettingsDefaults.targetSavingAmount / 10000).toInt().toString();
      dailyBudgetController.text = SettingsDefaults.dailyBudget.toString();
    }
    _initialNotificationsEnabled = _notificationsEnabled;
    _initialBgmVolume = _bgmVolume;
    _initialTargetSavings = targetSavingsController.text;
    _initialDailyBudget = dailyBudgetController.text;

    // TextController の変更を監視して Provider を更新
    targetSavingsController.addListener(_updateChangesProvider);
    dailyBudgetController.addListener(_updateChangesProvider);
  }

  // 変更をチェックして Provider を更新する関数
  void _updateChangesProvider() {
    final hasChanges = _hasAnyChanges();
    // Provider の状態を更新
    ref.read(hasSettingsChangesProvider.notifier).state = hasChanges;
  }

  @override
  void dispose() {
    targetSavingsController.dispose();
    dailyBudgetController.dispose();
    super.dispose();
  }

  // 音量に応じたアイコンを返す
  IconData getVolumeIcon() {
    if (_bgmVolume == 0) {
      return Icons.volume_off;
    } else if (_bgmVolume <= 70) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  // 設定項目に変更があったかチェックする
  bool _hasAnyChanges() {
    return _initialNotificationsEnabled != _notificationsEnabled ||
        _initialBgmVolume != _bgmVolume ||
        _initialTargetSavings != targetSavingsController.text ||
        _initialDailyBudget != dailyBudgetController.text;
  }

  // 設定を保存する処理
  void _onSaveButtonPressed() async {
    final targetSavingAmount = (int.tryParse(targetSavingsController.text) ??
            (SettingsDefaults.targetSavingAmount / 10000).toInt()) *
        10000;
    final dailyBudget = int.tryParse(dailyBudgetController.text) ??
        SettingsDefaults.dailyBudget;

    await ref.read(settingsProvider.notifier).saveSettings(SettingsState(
          notificationsEnabled: _notificationsEnabled,
          bgmVolume: _bgmVolume,
          targetSavingAmount: targetSavingAmount,
          dailyBudget: dailyBudget,
        ));

    // 保存後、初期値を更新し、変更フラグをリセット
    _initialNotificationsEnabled = _notificationsEnabled;
    _initialBgmVolume = _bgmVolume;
    _initialTargetSavings = targetSavingsController.text;
    _initialDailyBudget = dailyBudgetController.text;
    // 保存したので変更なし状態にも戻す
    ref.read(hasSettingsChangesProvider.notifier).state = false;
    if (mounted) {
      context.pop(); // 保存後に画面を閉じる
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingAsyncValue = ref.watch(settingsProvider);
    final notificationsEnabled = _notificationsEnabled; // ローカル変数として定義
    final bgmVolume = _bgmVolume; // ローカル変数として定義

    return settingAsyncValue.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.forthBackground,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.forthBackground,
        body: Center(child: Text('エラーが発生しました: $error')),
      ),
      data: (settings) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic _) {
            //  万が一popが成功した時は何もしない
            if (didPop) return;
          },
          child: Scaffold(
            backgroundColor: AppColors.forthBackground,
            appBar: AppBar(
              title: const Text('設定'),
              backgroundColor: AppColors.secondary,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- アプリセクション ---
                    const SectionHeader(title: 'アプリ', icon: Icons.tune),
                    SettingsContainer(
                      children: [
                        NotificationToggleRow(
                          notificationsEnabled: notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateNotification(value);
                              _updateChangesProvider();
                            });
                          },
                        ),
                        const Divider(),
                        BgmVolumeRow(
                          bgmVolume: bgmVolume,
                          getVolumeIcon: getVolumeIcon,
                          onChanged: (value) {
                            setState(() {
                              _bgmVolume = value;
                              _updateChangesProvider();
                            });
                            ref
                                .read(settingsProvider.notifier)
                                .updateBgmVolume(value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- 貯金セクション ---
                    const SectionHeader(title: '貯金', icon: Icons.savings),
                    SettingsContainer(
                      children: [
                        TargetSavingRow(controller: targetSavingsController),
                        const Divider(),
                        DailyBudgetRow(controller: dailyBudgetController),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Centerウィジェットの子にColumnウィジェットを配置する
                    Center(
                      child: Column(
                        // ✨ ここを Column に変更しました！
                        mainAxisSize: MainAxisSize.min, // 余分なスペースを取らないように設定
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch, // 子ウィジェットを横幅いっぱいに広げる
                        children: [
                          // 1. OKボタン (SizedBoxで幅と高さを指定)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _onSaveButtonPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.subText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),

                          // 2. OKボタンと彼女選択ボタンの間の間隔
                          const SizedBox(height: 40),

                          // 3. 彼女選択画面遷移ボタン
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/select_girlfriend');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.mainBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                '彼女を選びなおす？',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
