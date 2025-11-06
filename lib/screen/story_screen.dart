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

class StoryScreen extends ConsumerWidget {
  final int storyIndex;
  const StoryScreen({super.key, required this.storyIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterIdAsync = ref.watch(currentGirlfriendProvider);

    return characterIdAsync.when(
      data: (characterId) {
        if (characterId == null) {
          return const _ErrorScreen('キャラクターが選択されていません');
        }
        final storyRepo = ref.read(storyRepositoryProvider);
        final story = storyRepo.getStoryByCharacterId(characterId);
        final character = storyRepo.getCharacterById(characterId);

        if (story == null || character == null) {
          return const _ErrorScreen('ストーリーデータが見つかりません');
        }
        if (storyIndex < 0 || storyIndex >= story.dialogue.length) {
          return const _ErrorScreen('エピソードが見つかりません');
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
  bool _isAutoPlay = false;
  Timer? _autoPlayTimer;

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
    _autoPlayTimer?.cancel();
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
      if (!mounted) return; // Check on each iteration

      if (!_isStreaming) {
        _textStreamController.add(_fullText);
        break;
      }
      currentText += _fullText[i];
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
      // If streaming, just finish the animation.
      // Auto-play remains active if it was on.
      setState(() {
        _isStreaming = false;
      });
    } else {
      // If not streaming, tapping advances to the next line.
      // If auto-play is on, we just skip the wait and go to the next line.
      _goToNextLine();
    }

    // Using a short delay to prevent rapid state changes
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _goToNextLine() async {
    _autoPlayTimer?.cancel();

    if (_lineIndex < _currentEpisodeDialogue.length - 1) {
      setState(() {
        _lineIndex++;
      });
      _startStreamingText();
    } else {
      // Story finished, turn off auto-play
      if (_isAutoPlay) {
        setState(() {
          _isAutoPlay = false;
        });
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Image.asset(
                    widget.character.assetPath,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                  Stack(
                    children: [
                      Padding(
                        // Add padding to the top of the chat widget to make space for the buttons
                        padding: const EdgeInsets.only(top: 25.0),
                        child: StreamBuilder<String>(
                          stream: _textStreamController.stream,
                          initialData: "",
                          builder: (context, snapshot) {
                            return _ChatWidget(text: snapshot.data ?? "");
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 32,
                        child: Row(
                          children: [
                            _CircleButton(
                              _isAutoPlay ? Icons.pause : Icons.play_arrow,
                              onPressed: _toggleAutoPlay,
                            ),
                            const SizedBox(width: 8),
                            _CircleButton(Icons.skip_next,
                                onPressed: () => context.pop()),
                            const SizedBox(width: 8),
                            _CircleButton(Icons.list_alt,
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

  Widget _CircleButton(IconData icon, {required VoidCallback onPressed}) {
    return ClipOval(
      // Ensures the ripple effect is also circular
      child: Material(
        color: AppColors.secondary, // Button color
        child: InkWell(
          splashColor: AppColors.primary.withOpacity(0.5), // Ripple color
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

  void _showLogDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final log =
            _currentEpisodeDialogue.sublist(0, _lineIndex + 1).join('\n\n');
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildCuteDialog(context, log),
        );
      },
    );
  }

  Widget _buildCuteDialog(BuildContext context, String log) {
    return Container(
      padding: const EdgeInsets.all(24), // More padding
      decoration: BoxDecoration(
        color: AppColors.mainBackground, // White background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ログ',
            style: TextStyle(
              color: AppColors.mainText, // Black text
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forthBackground, // Light grey-blue
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Text(
                log,
                style: const TextStyle(
                  color: AppColors.mainText,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Using an OutlinedButton for a more modern feel
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary, // Pink text/border
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              '閉じる',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
