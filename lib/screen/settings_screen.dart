// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/constants/settings_defaults.dart';
import 'package:saving_girlfriend/models/settings_state.dart';
import '../providers/setting_provider.dart'; // hasSettingsChangesProvider をインポート



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

  // ★★★ ローカルの状態をリセットする処理を分離
  void _resetLocalState() {
    setState(() {
      _notificationsEnabled = _initialNotificationsEnabled;
      _bgmVolume = _initialBgmVolume;
      targetSavingsController.text = _initialTargetSavings;
      dailyBudgetController.text = _initialDailyBudget;
    });
    // ★★★ リセットしたので「変更なし」状態に戻す
    ref.read(hasSettingsChangesProvider.notifier).state = false;
  }

  // ヘッダーウィジェットを構築 (buildメソッド外に移動したため、この位置に定義)
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // 設定項目を囲むコンテナを構築 (buildメソッド外に移動したため、この位置に定義)
  Widget _buildSettingsContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
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
                    _buildSectionHeader('アプリ', Icons.tune),
                    _buildSettingsContainer(
                      children: [
                        // --- 通知 ---
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '通知',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ToggleButtons(
                                  isSelected: [
                                    !notificationsEnabled,
                                    notificationsEnabled
                                  ],
                                  onPressed: (index) {
                                    setState(() {
                                      _notificationsEnabled = (index == 1);
                                      ref
                                          .read(settingsProvider.notifier)
                                          .updateNotification(
                                              notificationsEnabled);
                                      _updateChangesProvider(); // 変更チェックを追加
                                    });
                                  },
                                  selectedColor: AppColors.mainBackground,
                                  fillColor: AppColors.primary,
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text('OFF'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text('ON'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // --- BGM音量設定 ---
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'BGM',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: Row(
                                children: [
                                  Icon(
                                    getVolumeIcon(),
                                    size: 28,
                                    color: AppColors.secondary,
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: bgmVolume,
                                      min: 0,
                                      max: 100,
                                      divisions: 50,
                                      activeColor: AppColors.secondary,
                                      onChanged: (value) {
                                        setState(() {
                                          _bgmVolume = value;
                                          _updateChangesProvider(); // 変更チェックを追加
                                        });
                                      },
                                      onChangeEnd: (value) {
                                        ref
                                            .read(settingsProvider.notifier)
                                            .updateBgmVolume(value);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${bgmVolume.toInt()}%',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- 貯金セクション ---
                    _buildSectionHeader('貯金', Icons.savings),
                    _buildSettingsContainer(
                      children: [
                        // --- 目標 ---
                        Row(
                          children: [
                            const Expanded(
                              // ✅ レイアウトを統一
                              child: Text(
                                '目標',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              // ✅ レイアウトを統一
                              width: 220,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 130, // TextField自体の幅はここで調整
                                  child: TextField(
                                    controller: targetSavingsController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right, // 右寄せにする
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.secondary),
                                      ),
                                      suffixText: '万円',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '1日の予算',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 130,
                                  child: TextField(
                                    controller: dailyBudgetController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.secondary),
                                      ),
                                      suffixText: '円',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                    const SizedBox(height: 40),

                    // Centerウィジェットの子にColumnウィジェットを配置する
                    Center(
                      child: Column( // ✨ ここを Column に変更しました！
                        mainAxisSize: MainAxisSize.min, // 余分なスペースを取らないように設定
                        crossAxisAlignment: CrossAxisAlignment.stretch, // 子ウィジェットを横幅いっぱいに広げる
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