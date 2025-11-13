import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/color.dart';

class BgmVolumeRow extends StatelessWidget {
  final double bgmVolume;
  final ValueChanged<double> onChanged;
  final IconData Function() getVolumeIcon;

  const BgmVolumeRow({
    super.key,
    required this.bgmVolume,
    required this.onChanged,
    required this.getVolumeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'BGM',
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(
          width: 220,
          child: Row(
            children: [
              Icon(
                getVolumeIcon(),
                size: 28,
                color: AppColors.secondary,
              ),
              Expanded(
                child: Slider(
                  value: bgmVolume,
                  min: 0,
                  max: 100,
                  divisions: 50,
                  activeColor: AppColors.secondary,
                  onChanged: onChanged,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${bgmVolume.toInt()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
