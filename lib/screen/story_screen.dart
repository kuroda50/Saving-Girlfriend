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

  // ★変更点: List<String> から List<DialogueLine> に変更
  List<DialogueLine> get _currentEpisodeDialogue =>
      widget.story.dialogue[widget.episodeIndex];

  // ★変更点: 現在の行のDialogueLineを取得するgetterを追加
  DialogueLine get _currentLine => _currentEpisodeDialogue[_lineIndex];

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

    // ★変更点: _currentLine.text を使用
    final String fullText = _currentLine.text;
    String currentText = "";
    _textStreamController.add("");

    for (int i = 0; i < fullText.length; i++) {
      if (!mounted) return;

      if (!_isStreaming) {
        // ★変更点: fullText をストリームに追加
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

  void _goToNextLine() async {
    _autoPlayTimer?.cancel();

    if (_lineIndex < _currentEpisodeDialogue.length - 1) {
      setState(() {
        _lineIndex++;
      });
      _startStreamingText();
    } else {
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
                        padding: const EdgeInsets.only(top: 25.0),
                        child: StreamBuilder<String>(
                          stream: _textStreamController.stream,
                          initialData: "",
                          builder: (context, snapshot) {
                            // ★変更点: 現在の話者名（_currentLine.speaker）を渡す
                            return _ChatWidget(
                              speaker: _currentLine.speaker,
                              text: snapshot.data ?? "",
                            );
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

  // 1. _showLogDialog メソッド (呼び出すメソッド名を変更)
  void _showLogDialog(BuildContext context) {
    // 現在の行までのセリフリストを取得
    final logLines = _currentEpisodeDialogue.sublist(0, _lineIndex + 1);
    // メインキャラクターの名前を取得（比較用）
    final mainCharacterName = widget.character.name;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6), // 背景の暗さは維持
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // ダイアログの角丸
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          // ★変更点: _buildCuteLogDialog を呼び出すように変更
          child: _buildCuteLogDialog(context, mainCharacterName, logLines),
        );
      },
    );
  }

  // 2. _buildProsekaLogDialog を削除し、こちらの _buildCuteLogDialog に差し替え
  Widget _buildCuteLogDialog(BuildContext context, String mainCharacterName,
      List<DialogueLine> logLines) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        // ★変更点: 背景を AppColors.mainBackground (白系) に
        color: AppColors.mainBackground,
        borderRadius: BorderRadius.circular(16), // 角丸
        border: Border.all(
            color: AppColors.primary.withOpacity(0.5), width: 2), // 枠線をピンクに
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1), // 影もピンク系に
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // 1. ヘッダー ("ログ")
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'ログ',
              style: TextStyle(
                // ★変更点: 文字色をメインテキストカラーに
                color: AppColors.mainText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 区切り線
          Container(
            height: 1,
            // ★変更点: 区切り線をピンク系に
            color: AppColors.primary.withOpacity(0.3),
          ),

          // 2. セリフのリスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: logLines.length,
              itemBuilder: (context, index) {
                final line = logLines[index];
                final bool isMainCharacter = line.speaker == mainCharacterName;

                // ★変更点: メインキャラはピンク、その他はセカンダリカラー（青緑）
                final Color speakerColor = isMainCharacter
                    ? AppColors.primary // ピンク
                    : AppColors.secondary; // 青緑
                final String speakerName = line.speaker;

                // セリフの背景色
                final Color bubbleColor = isMainCharacter
                    ? AppColors.primary.withOpacity(0.05) // 薄いピンク
                    : AppColors.forthBackground; // 薄い青

                // セリフの枠線色
                final Color bubbleBorderColor = isMainCharacter
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.secondary.withOpacity(0.4);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 話者名
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                        child: Text(
                          speakerName,
                          style: TextStyle(
                            color: speakerColor, // 動的な色を適用
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // セリフの吹き出し
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(12.0), // 角丸
                            border: Border.all(
                                color: bubbleBorderColor, width: 1.5)),
                        child: Text(
                          line.text,
                          style: const TextStyle(
                            color: AppColors.mainText, // 文字色を黒系に
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. 閉じるボタン
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // ボタン背景色をピンクに
                  foregroundColor: AppColors.mainIcon, // ボタン文字色を白に
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // 角を丸く
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '閉じる',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ★変更点: _ChatWidget が話者名(speaker)を受け取るように変更
class _ChatWidget extends StatelessWidget {
  final String speaker; // 話者名 (データとしては受け取る)
  final String text; // セリフ
  const _ChatWidget({required this.speaker, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ★変更点: 高さを 100 に戻す
      height: 100,
      margin: const EdgeInsets.all(16),
      // ★変更点: Paddingを8に戻す
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.mainBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.nonActive, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      // ★変更点: Column ではなく Row を使う元のレイアウトに戻す
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          // 話者名ヘッダーを削除し、セリフだけを表示
          Expanded(
            child: SingleChildScrollView(
              // セリフが長い場合に備える
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ),
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
