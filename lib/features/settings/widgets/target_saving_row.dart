import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';

class TargetSavingRow extends StatelessWidget {
  final TextEditingController controller;

  const TargetSavingRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '目標',
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(
          width: 220,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 130,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  suffixText: '万円',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
