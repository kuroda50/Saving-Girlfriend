// lib/features/story/widgets/story_control_button.dart
import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';

// 以前の _circleButton メソッド
class StoryControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const StoryControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: AppColors.secondary,
        child: InkWell(
          splashColor: AppColors.primary.withOpacity(0.5),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 24,
              color: AppColors.mainIcon,
            ),
          ),
        ),
      ),
    );
  }
}
