import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';

class NotificationToggleRow extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onChanged;

  const NotificationToggleRow({
    super.key,
    required this.notificationsEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
              isSelected: [!notificationsEnabled, notificationsEnabled],
              onPressed: (index) => onChanged(index == 1),
              selectedColor: AppColors.mainBackground,
              fillColor: AppColors.primary,
              color: AppColors.secondary,
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
          ),
        ),
      ],
    );
  }
}
