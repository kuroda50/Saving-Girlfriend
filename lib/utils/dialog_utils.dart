import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/color.dart';

Future<bool?> showUnsavedChangesDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.mainBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Text(
        "変更を破棄しますか？",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('保存されていない変更があります。このまま画面を移動しますか？'),
      actions: [
        SizedBox(
          width: 100,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("キャンセル"),
          ),
        ),
        SizedBox(
          width: 130,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.subText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("破棄する"),
          ),
        ),
      ],
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );
}
