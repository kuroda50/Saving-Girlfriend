/*ストーリー画面*/
import 'package:go_router/go_router.dart';

import '../stories/suzunari_oto.dart';
import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int _currentIndex = 0;

  void nextLine() {
    if (_currentIndex < EpisodeSuzunariOto.suzunariOtoStory.length - 1)
      setState(() {
        _currentIndex++;
      });
    // 最後のセリフなら戻る
    else if (_currentIndex >= EpisodeSuzunariOto.suzunariOtoStory.length - 1)
      context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
        ),
        body: GestureDetector(
          onTap: () => nextLine(),
          child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(AppAssets.backgroundClassroom),
                fit: BoxFit.cover,
              )),
              child: Center(
                child: Stack(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            AppAssets.characterSuzunari,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height * 0.5,
                          ),
                          ChatWidget(
                              text: EpisodeSuzunariOto
                                  .suzunariOtoStory[_currentIndex]),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _circleButton(Icons.play_arrow),
                              const SizedBox(width: 16),
                              _circleButton(Icons.skip_next),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: Colors.pink[300],
                        child: const Text(
                          '第１話',
                          style:
                              TextStyle(color: AppColors.subText, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _circleButton(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 40,
        color: AppColors.mainIcon,
        onPressed: () {},
      ),
    );
  }
}

class ChatWidget extends StatelessWidget {
  final String text;
  const ChatWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.mainBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.nonActive,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
