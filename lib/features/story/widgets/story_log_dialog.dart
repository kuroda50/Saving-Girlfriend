// lib/features/story/widgets/story_log_dialog.dart
import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/features/story/models/story_model.dart';

// 以前の _CuteLogDialogContent
class StoryLogDialog extends StatefulWidget {
  final String mainCharacterName;
  final List<DialogueLine> logLines;

  const StoryLogDialog({
    super.key,
    required this.mainCharacterName,
    required this.logLines,
  });

  @override
  State<StoryLogDialog> createState() => _StoryLogDialogState();
}

class _StoryLogDialogState extends State<StoryLogDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.mainBackground,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'ログ',
                style: TextStyle(
                  color: AppColors.mainText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 1,
              color: AppColors.primary.withOpacity(0.3),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.logLines.length,
                itemBuilder: (context, index) {
                  final line = widget.logLines[index];
                  final bool isMainCharacter =
                      line.speaker == widget.mainCharacterName;

                  final bool showSpeaker = index == 0 ||
                      widget.logLines[index - 1].speaker != line.speaker;

                  final Color speakerColor =
                      isMainCharacter ? AppColors.primary : AppColors.secondary;
                  final String speakerName = line.speaker;

                  final Color bubbleColor = isMainCharacter
                      ? AppColors.primary.withOpacity(0.05)
                      : AppColors.forthBackground;
                  final Color bubbleBorderColor = isMainCharacter
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.secondary.withOpacity(0.4);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showSpeaker)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, bottom: 4.0),
                            child: Text(
                              speakerName,
                              style: TextStyle(
                                color: speakerColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                  color: bubbleBorderColor, width: 1.5)),
                          child: Text(
                            line.text,
                            style: const TextStyle(
                              color: AppColors.mainText,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.mainIcon,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
      ),
    );
  }
}
