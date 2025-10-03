import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/constants/settings_defaults.dart';
import 'package:saving_girlfriend/models/settings_state.dart';
import '../providers/setting_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool notificationsEnabled;
  late double bgmVolume;
  final TextEditingController targetSavingsController = TextEditingController();
  final TextEditingController dailyBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialSettings = ref.read(settingsProvider).value;
    if (initialSettings != null) {
      notificationsEnabled = initialSettings.notificationsEnabled;
      bgmVolume = initialSettings.bgmVolume;
      targetSavingsController.text =
          (initialSettings.targetSavingAmount / 10000).toInt().toString();
      dailyBudgetController.text = initialSettings.dailyBudget.toString();
    } else {
      notificationsEnabled = SettingsDefaults.notificationsEnabled;
      bgmVolume = SettingsDefaults.bgmVolume;
      targetSavingsController.text =
          (SettingsDefaults.targetSavingAmount / 10000).toInt().toString();
      dailyBudgetController.text = SettingsDefaults.dailyBudget.toString();
    }
  }

  @override
  void dispose() {
    targetSavingsController.dispose();
    dailyBudgetController.dispose();
    super.dispose();
  }

  // 音量に応じたアイコンを返す
  IconData getVolumeIcon() {
    if (bgmVolume == 0) {
      return Icons.volume_off; // 0%
    } else if (bgmVolume <= 70) {
      return Icons.volume_down; // 1~70%
    } else {
      return Icons.volume_up; // 71~100%
    }
  }

  // 設定を保存する処理
  void saveSettings() async {
    final newSettings = SettingsState(
      notificationsEnabled: notificationsEnabled,
      bgmVolume: bgmVolume,
      targetSavingAmount: (int.tryParse(targetSavingsController.text) ??
              (SettingsDefaults.targetSavingAmount / 10000).toInt()) *
          10000,
      dailyBudget: int.tryParse(dailyBudgetController.text) ??
          SettingsDefaults.dailyBudget,
    );
    await ref.read(settingsProvider.notifier).saveSettings(newSettings);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingAsyncValue = ref.watch(settingsProvider);
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
          return Scaffold(
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
                                      notificationsEnabled = (index == 1);
                                    });
                                  },
                                  selectedColor: AppColors.mainBackground,
                                  fillColor: AppColors.primary,
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  children: const [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text('OFF'),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
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
                                          bgmVolume = value;
                                        });
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
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
                        // --- 一日に使える金額 ---
                        Row(
                          children: [
                            const Expanded(
                              // ✅ レイアウトを統一
                              child: Text(
                                '一日に使える金額',
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
                                              horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ( OKボタンなどはこの下に続く... )
                    const SizedBox(height: 40),
                    // OKボタン
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.subText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

Widget _buildSectionHeader(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0), // 下のpaddingを調整
    child: Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18, // 少し大きく
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSettingsContainer({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.mainBackground, // 背景色を白に
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        // ほんのり影をつけて立体感を出す
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
