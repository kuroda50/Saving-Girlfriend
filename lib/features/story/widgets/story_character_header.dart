import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/features/story/models/story_model.dart';

class StoryCharacterHeader extends StatelessWidget {
  final StoryCharacter character;

  const StoryCharacterHeader({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mainBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  character.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.errorBackground,
                      child: Icon(Icons.person,
                          color: AppColors.secondary, size: 50),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                character.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainLogo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
