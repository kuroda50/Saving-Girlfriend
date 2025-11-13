/*ストーリー画面*/

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Project imports:
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/story/models/story_model.dart';
import 'package:saving_girlfriend/features/story/repositories/story_repository.dart';

// ★追加: 分割したウィジェットをインポート
import 'package:saving_girlfriend/features/story/widgets/story_chat_widget.dart';
import 'package:saving_girlfriend/features/story/widgets/story_control_button.dart';
import 'package:saving_girlfriend/features/story/widgets/story_error_screen.dart';
import 'package:saving_girlfriend/features/story/widgets/story_log_dialog.dart';

class StoryScreen extends ConsumerWidget {
  final int storyIndex;
  const StoryScreen({super.key, required this.storyIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterIdAsync = ref.watch(currentGirlfriendProvider);

    return characterIdAsync.when(
      data: (characterId) {
        if (characterId == null) {
          // ★修正: const を削除
          return const StoryErrorScreen('キャラクターが選択されていません');
        }
        final storyRepo = ref.read(storyRepositoryProvider);
        final story = storyRepo.getStoryByCharacterId(characterId);
        final character = storyRepo.getCharacterById(characterId);

        if (story == null || character == null) {
          // ★修正: const を削除
          return const StoryErrorScreen('ストーリーデータが見つかりません');
        }
        if (storyIndex < 0 || storyIndex >= story.dialogue.length) {
          // ★修正: const を削除
          return const StoryErrorScreen('エピソードが見つかりません');
        }

        return _StoryPlayer(
          story: story,
          character: character,
          episodeIndex: storyIndex,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // ★修正: _ErrorScreen -> StoryErrorScreen (ここはconst不要)
      error: (e, s) => StoryErrorScreen('エラーが発生しました: $e'),
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

class _StoryPlayerState extends ConsumerState<_StoryPlayer>
    with SingleTickerProviderStateMixin {
  int _lineIndex = 0;
  bool _isProcessing = false;
  bool _isStreaming = false;
  bool _isAutoPlay = false;
  Timer? _autoPlayTimer;

  late StreamController<String> _textStreamController;

  late AnimationController _animationController;
  late Animation<double> _animation;

  List<DialogueLine> get _currentEpisodeDialogue =>
      widget.story.dialogue[widget.episodeIndex];

  DialogueLine get _currentLine => _currentEpisodeDialogue[_lineIndex];

  @override
  void initState() {
    super.initState();
    _textStreamController = StreamController<String>();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 25.0, end: 15.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startStreamingText();
  }

  @override
  void dispose() {
    _textStreamController.close();
    _autoPlayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startStreamingText() async {
    if (_currentEpisodeDialogue.isEmpty) return;

    setState(() {
      _isStreaming = true;
    });

    final String fullText = _currentLine.text;
    String currentText = "";
    _textStreamController.add("");

    for (int i = 0; i < fullText.length; i++) {
      if (!mounted) return;

      if (!_isStreaming) {
        _textStreamController.add(fullText);
        break;
      }
      currentText += fullText[i];
      _textStreamController.add(currentText);
      await Future.delayed(const Duration(milliseconds: 40));
    }

    if (!mounted) return;

    setState(() {
      _isStreaming = false;
    });

    if (_isAutoPlay) {
      _scheduleNextLine();
    }
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

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _goToNextLine() {
    _autoPlayTimer?.cancel();

    if (_lineIndex < _currentEpisodeDialogue.length - 1) {
      setState(() {
        _lineIndex++;
      });
      _startStreamingText();
    } else {
      _endStory();
    }
  }

  void _endStory() async {
    if (_isAutoPlay) {
      setState(() {
        _isAutoPlay = false;
      });
    }

    final localStorage = await ref.read(localStorageServiceProvider.future);
    final hasPlayedEpisode0ForCharacter =
        localStorage.hasPlayedEpisode0(widget.character.id);

    if (mounted) {
      if (widget.episodeIndex == 0 && !hasPlayedEpisode0ForCharacter) {
        context.go('/home');
      } else {
        context.go('/select_story');
      }
    }
    if (widget.episodeIndex == 0) {
      await localStorage.setEpisode0Played(widget.character.id);
    }
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlay = !_isAutoPlay;
    });
    if (_isAutoPlay && !_isStreaming) {
      _goToNextLine();
    } else if (!_isAutoPlay) {
      _autoPlayTimer?.cancel();
    }
  }

  void _scheduleNextLine() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isAutoPlay) {
        _goToNextLine();
      }
    });
  }

  void _skipToEnd() {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isStreaming = false;
      _autoPlayTimer?.cancel();
    });

    _endStory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        automaticallyImplyLeading: false,
        title: Text(
          '第${widget.episodeIndex}話 ${widget.story.episodes[widget.episodeIndex].title}',
          style: const TextStyle(
            color: AppColors.mainIcon,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        widget.character.assetPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      // 1. セリフの吹き出し（最下層）
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: StreamBuilder<String>(
                          stream: _textStreamController.stream,
                          initialData: "",
                          builder: (context, snapshot) {
                            // ★修正: _ChatWidget -> StoryChatWidget
                            return StoryChatWidget(
                              speaker: _currentLine.speaker,
                              text: snapshot.data ?? "",
                              fullText: _currentLine.text,
                            );
                          },
                        ),
                      ),

                      // 2. セリフ送りを示す三角アイコン
                      if (!_isStreaming &&
                          _lineIndex < _currentEpisodeDialogue.length - 1)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              right: 30,
                              bottom: _animation.value,
                              child: child!,
                            );
                          },
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.pink,
                            size: 40,
                            shadows: [
                              Shadow(
                                blurRadius: 6.0,
                                color: Colors.black,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      // 3. 操作ボタン群（オートプレイ、スキップ、ログ）
                      Positioned(
                        top: 0,
                        left: 32,
                        child: Row(
                          children: [
                            // ★修正: _circleButton -> StoryControlButton
                            StoryControlButton(
                              icon:
                                  _isAutoPlay ? Icons.pause : Icons.play_arrow,
                              onPressed: _toggleAutoPlay,
                            ),
                            const SizedBox(width: 8),
                            // ★修正: _circleButton -> StoryControlButton
                            StoryControlButton(
                                icon: Icons.skip_next, onPressed: _skipToEnd),
                            const SizedBox(width: 8),
                            // ★修正: _circleButton -> StoryControlButton
                            StoryControlButton(
                                icon: Icons.list_alt,
                                onPressed: () => _showLogDialog(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. _showLogDialog メソッド (呼び出すメソッド名を変更)
  void _showLogDialog(BuildContext context) {
    final logLines = _currentEpisodeDialogue.sublist(0, _lineIndex + 1);
    final mainCharacterName = widget.character.name;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        // ★修正: _CuteLogDialogContent -> StoryLogDialog
        return StoryLogDialog(
          mainCharacterName: mainCharacterName,
          logLines: logLines,
        );
      },
    );
  }

  // ★削除: _CircleButton, _buildCuteLogDialog, _ChatWidget, _ErrorScreen, _CuteLogDialogContent
}
