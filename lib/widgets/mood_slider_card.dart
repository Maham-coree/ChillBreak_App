import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'gradient_button.dart';

class MoodSliderCard extends StatefulWidget {
  final ValueChanged<double>? onLogMood;

  const MoodSliderCard({super.key, this.onLogMood});

  @override
  State<MoodSliderCard> createState() => _MoodSliderCardState();
}

class _MoodSliderCardState extends State<MoodSliderCard> {
  double _value = 2; // 0..4 -> "Okay" is the middle default

  static const _labels = ['Drained', 'Tired', 'Okay', 'Good', 'Energized'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you feel after studying?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('😴', style: TextStyle(fontSize: 18)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.purple,
                    inactiveTrackColor: AppColors.textMuted.withOpacity(0.3),
                    thumbColor: Colors.white,
                    overlayColor: AppColors.purple.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _value,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    onChanged: (v) => setState(() => _value = v),
                  ),
                ),
              ),
              const Text('⚡', style: TextStyle(fontSize: 18)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_labels.length, (i) {
              final selected = i == _value.round();
              return Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? AppColors.purple : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Log my mood',
            onTap: () => widget.onLogMood?.call(_value),
          ),
        ],
      ),
    );
  }
}
