/*ストーリー画面*/
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../stories/suzunari_oto.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'dart:async';

// ↓ StatefulWidget → ConsumerStatefulWidget に変更
class StoryScreen extends ConsumerStatefulWidget {
  final int story_index;
  const StoryScreen({super.key, required this.story_index});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

// ↓ State<StoryScreen> → ConsumerState<StoryScreen> に変更
class _StoryScreenState extends ConsumerState<StoryScreen> {
  late int _storyIndex;
  int _lineIndex = 0;
  bool _isValidIndex = true;
  bool _isProcessing = false;
  bool _isStreaming = false;

  late StreamController<String> _textStreamController;
  String _fullText = "";

  @override
  void initState() {
    super.initState();
    _storyIndex = widget.story_index;
    if (_storyIndex < 0 ||
        _storyIndex >= EpisodeSuzunariOto.suzunariOtoStory.length) {
      _isValidIndex = false;
    }
    _textStreamController = StreamController<String>();
    _startStreamingText();
  }

  @override
  void dispose() {
    _textStreamController.close();
    super.dispose();
  }

  void _startStreamingText() async {
    if (!_isValidIndex) return;

    setState(() {
      _isStreaming = true;
    });

    _fullText = EpisodeSuzunariOto.suzunariOtoStory[_storyIndex][_lineIndex];
    String currentText = "";
    _textStreamController.add(""); // 最初は空

    for (int i = 0; i < _fullText.length; i++) {
      if (!_isStreaming) {
        _textStreamController.add(_fullText);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 40));
      if (!_isStreaming) {
        _textStreamController.add(_fullText);
        return;
      }
      currentText += _fullText[i];
      _textStreamController.add(currentText);
    }

    setState(() {
      _isStreaming = false;
    });
  }

  void _onTap() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    if (_isStreaming) {
      setState(() {
        _isStreaming = false;
      });
    } else {
      _goToNextLine();
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _goToNextLine() async {
    if (!_isValidIndex) return;

    if (_lineIndex <
        EpisodeSuzunariOto.suzunariOtoStory[_storyIndex].length - 1) {
      setState(() {
        _lineIndex++;
      });
      _startStreamingText();
    } else {
      // ストーリー再生フラグを保存
      final localStorage = await ref.read(localStorageServiceProvider.future);
      final hasPlayed = await localStorage.hasPlayedStory();

      final String nextPath = hasPlayed ? '/select_story' : '/home';
      await localStorage.setPlayedStory(); // ストーリー再生済みにする（setメソッド名は実装に合わせて修正）

      if (mounted) {
        context.go(nextPath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidIndex)
      // 範囲外の場合のエラー画面
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'ストーリーが見つかりません',
                style: TextStyle(fontSize: 20, color: AppColors.error),
              ),
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
        ),
        body: GestureDetector(
          onTap: _onTap,
          child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(AppAssets.backgroundClassroom),
                fit: BoxFit.cover,
              )),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        AppAssets.characterSuzunari,
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                      StreamBuilder<String>(
                        stream: _textStreamController.stream,
                        initialData: "",
                        builder: (context, snapshot) {
                          return ChatWidget(text: snapshot.data ?? "");
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleButton(Icons.play_arrow, onPressed: _onTap),
                          const SizedBox(width: 16),
                          _circleButton(Icons.skip_next, onPressed: () {
                            context.pop();
                          }),
                          const SizedBox(width: 16),
                          _circleButton(Icons.list_alt, onPressed: () {
                            _showLogDialog(context);
                          }),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.pink[300],
                      child: Text(
                        '第${_storyIndex + 1}話',
                        style: const TextStyle(
                            color: AppColors.subText, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }

  Widget _circleButton(IconData icon, {required VoidCallback onPressed}) {
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
        onPressed: onPressed,
      ),
    );
  }

  void _showLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final log = EpisodeSuzunariOto.suzunariOtoStory[_storyIndex]
            .sublist(0, _lineIndex + 1)
            .join('\n\n');
        return AlertDialog(
          title: const Text('ログ'),
          content: SingleChildScrollView(
            child: Text(log),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
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
      margin: const EdgeInsets.all(16),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
