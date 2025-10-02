import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationOn = true;
  double bgmVolume = 30; // 初期値30%

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 通知設定
            const Text(
              '通知',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ToggleButtons(
              isSelected: [!isNotificationOn, isNotificationOn],
              onPressed: (index) {
                setState(() {
                  isNotificationOn = (index == 1);
                });
              },
              selectedColor: Colors.white,
              fillColor: Colors.pink[200],
              color: Colors.pink[200],
              borderRadius: BorderRadius.circular(10),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('OFF'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('ON'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // BGM音量設定
            Row(
              children: [
                const Text(
                  'BGM',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 20),
                Icon(
                  getVolumeIcon(),
                  size: 28,
                  color: Colors.pink[200],
                ),
                Expanded(
                  child: Slider(
                    value: bgmVolume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: Colors.pink[200],
                    onChanged: (value) {
                      setState(() {
                        bgmVolume = value;
                      });
                    },
                  ),
                ),
                // 右の音量アイコンは削除済み
              ],
            ),
          ],
        ),
      ),
    );
  }
}
