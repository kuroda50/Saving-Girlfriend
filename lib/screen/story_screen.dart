/*ストーリー画面*/

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:saving_girlfriend/constants/assets.dart';
import 'package:saving_girlfriend/models/story_model.dart';
import 'package:saving_girlfriend/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'package:saving_girlfriend/stories/story_repository.dart';
import '../constants/color.dart';
import '../stories/suzunari_oto.dart';

class StoryScreen extends ConsumerWidget {
  final int storyIndex;
  const StoryScreen({super.key, required this.storyIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterIdAsync = ref.watch(currentGirlfriendProvider);

    return characterIdAsync.when(
      data: (characterId) {
        if (characterId == null) {
          return _ErrorScreen('キャラクターが選択されていません');
        }
        final storyRepo = ref.read(storyRepositoryProvider);
        final story = storyRepo.getStoryByCharacterId(characterId);
        final character = storyRepo.getCharacterById(characterId);

        if (story == null || character == null) {
          return _ErrorScreen('ストーリーデータが見つかりません');
        }
        if (storyIndex < 0 || storyIndex >= story.dialogue.length) {
          return _ErrorScreen('エピソードが見つかりません');
        }

        return _StoryPlayer(
          story: story,
          character: character,
          episodeIndex: storyIndex,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => _ErrorScreen('エラーが発生しました: $e'),
    );
  }
}

class _StoryPlayer extends ConsumerStatefulWidget {
  final Story story;
  final StoryCharacter character;
  final int episodeIndex;

  const _StoryPlayer({
    required this.story,
    required this.character,
    required this.episodeIndex,
  });

  @override
  ConsumerState<_StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends ConsumerState<_StoryPlayer> {
  int _lineIndex = 0;
  bool _isProcessing = false;
  bool _isStreaming = false;

  late StreamController<String> _textStreamController;
  String _fullText = "";
  List<String> get _currentEpisodeDialogue =>
      widget.story.dialogue[widget.episodeIndex];

  @override
  void initState() {
    super.initState();
    _textStreamController = StreamController<String>();
    _startStreamingText();
  }

  @override
  void dispose() {
    _textStreamController.close();
    super.dispose();
  }

  void _startStreamingText() async {
    if (_currentEpisodeDialogue.isEmpty) return;

    setState(() {
      _isStreaming = true;
    });

    _fullText = _currentEpisodeDialogue[_lineIndex];
    String currentText = "";
    _textStreamController.add("");

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

  void _onTap() {
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
    if (_lineIndex < _currentEpisodeDialogue.length - 1) {
      setState(() {
        _lineIndex++;
      });
      _startStreamingText();
    } else {
      final localStorage = await ref.read(localStorageServiceProvider.future);

      // 0話が過去に再生されたことがあるかを判断して次の遷移画面を変える
      final hasPlayedEpisode0ForCharacter =
          localStorage.hasPlayedEpisode0(widget.character.id);

      if (mounted) {
        if (widget.episodeIndex == 0 && !hasPlayedEpisode0ForCharacter) {
          // 初めて0話を再生するならホーム画面へ
          context.go('/home');
        } else {
          context.go('/select_story');
        }
      }
      // エピソード0が終了した場合のみ、再生済みフラグを立てる
      if (widget.episodeIndex == 0) {
        await localStorage.setEpisode0Played(widget.character.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: _onTap,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundClassroom),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    widget.character.assetPath,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                  StreamBuilder<String>(
                    stream: _textStreamController.stream,
                    initialData: "",
                    builder: (context, snapshot) {
                      return _ChatWidget(text: snapshot.data ?? "");
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleButton(Icons.play_arrow, onPressed: _onTap),
                      const SizedBox(width: 16),
                      _CircleButton(Icons.skip_next,
                          onPressed: () => context.pop()),
                      const SizedBox(width: 16),
                      _CircleButton(Icons.list_alt,
                          onPressed: () => _showLogDialog(context)),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.pink[300],
                  child: Text(
                    '第${widget.episodeIndex + 1}話',
                    style:
                        const TextStyle(color: AppColors.subText, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _CircleButton(IconData icon, {required VoidCallback onPressed}) {
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
        final log =
            _currentEpisodeDialogue.sublist(0, _lineIndex + 1).join('\n\n');
        return AlertDialog(
          title: const Text('ログ'),
          content: SingleChildScrollView(child: Text(log)),
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

class _ChatWidget extends StatelessWidget {
  final String text;
  const _ChatWidget({required this.text});

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
              color: AppColors.nonActive, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen(this.message);

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
