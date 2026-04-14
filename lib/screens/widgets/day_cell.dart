import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/day_record.dart';

class DayCell extends StatelessWidget {
  final int day;

  /// True = date is within [startDate, today] — interactive.
  final bool isEnabled;

  /// True = this cell represents today.
  final bool isToday;

  final DayRecord? record;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DayCell({
    super.key,
    required this.day,
    required this.isEnabled,
    required this.isToday,
    this.record,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;

    final isWorked = record?.isWorked ?? false;
    final hasNote = record?.hasNote ?? false;

    // ── colour logic ──
    Color bgColor;
    Color textColor;
    Border? border;

    if (!isEnabled) {
      bgColor = Colors.transparent;
      textColor = colors.subtext.withOpacity(0.25);
    } else if (isWorked) {
      bgColor = colors.worked;
      textColor = colors.workedText;
    } else {
      bgColor = colors.unworked;
      textColor = isToday ? scheme.primary : scheme.onSurface.withOpacity(0.85);
    }

    if (isToday && isEnabled && !isWorked) {
      border = Border.all(color: scheme.primary, width: 1.5);
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      onLongPress: isEnabled ? onLongPress : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight:
                    isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            // Note dot indicator (top-right)
            if (hasNote && isEnabled)
              Positioned(
                top: 3,
                right: 3,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isWorked
                        ? Colors.white.withOpacity(0.85)
                        : colors.noteIndicator,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
