// lib/features/story/widgets/story_error_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/common/constants/color.dart';

// 以前の _ErrorScreen
class StoryErrorScreen extends StatelessWidget {
  final String message;
  const StoryErrorScreen(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.secondary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 20, color: AppColors.error)),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.mainIcon,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('戻る'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
