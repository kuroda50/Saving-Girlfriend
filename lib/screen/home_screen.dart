import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_screen_provider.dart';

// ChatInputWidgetが別のファイルにある場合は、そのimport文をここに追加してください
// import '.../chat_input_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeScreenProvider);
    final girlfriendText = homeState.girlfriendText;

    void handleSendMessage(String message) {
      ref
          .read(homeScreenProvider.notifier)
          .aiChat(message, 0); // 💡 `amount`を固定値に変更
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 1. 背景画像 (教室)
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.backgroundClassroom,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.errorBackground,
                        child: const Center(
                          child: Text(
                            '背景画像をロードできませんでした。\nパス: ${AppAssets.backgroundClassroom}',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.error, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 2. キャラクター画像 (画面下部中央に調整)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      AppAssets.characterSuzunari,
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.5,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.errorBackground,
                          child: const Center(
                            child: Text(
                              'キャラクター画像をロードできませんでした。\nパス: ${AppAssets.characterSuzunari}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 3. 上部の情報バー
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings,
                              color: AppColors.subIcon),
                          onPressed: () {
                            context.push('/home/settings');
                          },
                        ),
                        const Text(
                          '5回目継続中!!',
                          style: TextStyle(
                              color: AppColors.mainText, fontSize: 12),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: LinearProgressIndicator(
                              value: 0.5,
                              backgroundColor: AppColors.nonActive,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                        const Icon(Icons.favorite,
                            color: AppColors.primary, size: 18),
                        const Text('50',
                            style: TextStyle(
                                color: AppColors.mainText, fontSize: 14)),
                        const Text('/100',
                            style: TextStyle(
                                color: AppColors.mainText, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // 4. 吹き出し
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      girlfriendText,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.mainText),
                    ),
                  ),
                ),
                // 5. チャット入力欄
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.02,
                  right: 20,
                  child: SizedBox(
                    height: 70,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ChatInputWidget(
                      onSendMessage: (message) {
                        handleSendMessage(message);
                        print('送信されたメッセージ: $message');
                      },
                      hintText: '彼女と会話しましょう！',
                      backgroundColor: AppColors.secondary,
                      sendButtonColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 ここから下は変更・削除した部分

// ChatInputWidget クラスは元のまま
class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final String? hintText;
  final Color? backgroundColor;
  final Color? sendButtonColor;
  final IconData? sendIcon;
  final int maxLines;
  final bool enabled;

  const ChatInputWidget({
    Key? key,
    required this.onSendMessage,
    this.hintText = 'メッセージを入力...',
    this.backgroundColor,
    this.sendButtonColor,
    this.sendIcon = Icons.send,
    this.maxLines = 5,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    widget.onSendMessage(text.trim());
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                    color: theme.colorScheme.background,
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: _handleSubmitted,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                  icon: Icon(
                    widget.sendIcon,
                    color: AppColors.mainIcon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
