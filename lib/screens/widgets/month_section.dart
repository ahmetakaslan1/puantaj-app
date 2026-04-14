import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/record_provider.dart';
import '../../utils/date_utils.dart';
import 'day_cell.dart';
import 'note_dialog.dart';

class MonthSection extends StatelessWidget {
  final int year;
  final int month;
  final DateTime startDate; // job start date
  final DateTime today;
  final int jobId;

  const MonthSection({
    super.key,
    required this.year,
    required this.month,
    required this.startDate,
    required this.today,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Consumer<RecordProvider>(
      builder: (context, records, _) {
        final rows = _buildGrid(context, records, colors, scheme);

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  monthYearLabel(year, month),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Weekday header
              Row(
                children: trDaysShort.map((d) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.subtext,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 4),

              // Week rows
              ...rows,

              // Separator line
              const SizedBox(height: 10),
              Divider(color: colors.separator, height: 1),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildGrid(
    BuildContext context,
    RecordProvider records,
    PuantajColors colors,
    ColorScheme scheme,
  ) {
    final firstDay = DateTime(year, month, 1);
    final numDays = daysInMonth(year, month);

    // Monday = 0, ..., Sunday = 6
    final offset = (firstDay.weekday - 1) % 7;

    // Build flat list of cells
    final cells = <Widget>[];

    // Leading empty cells
    for (int i = 0; i < offset; i++) {
      cells.add(const Expanded(child: AspectRatio(aspectRatio: 1)));
    }

    // Day cells
    for (int day = 1; day <= numDays; day++) {
      final cellDate = DateTime(year, month, day);
      final dateKey = toDateKey(cellDate);
      final record = records.getRecord(dateKey);

      // A day is enabled if it's >= job startDate and <= today
      final startDay = DateTime(startDate.year, startDate.month, startDate.day);
      final todayDay = DateTime(today.year, today.month, today.day);
      final isEnabled =
          !cellDate.isBefore(startDay) && !cellDate.isAfter(todayDay);
      final isToday = cellDate.year == todayDay.year &&
          cellDate.month == todayDay.month &&
          cellDate.day == todayDay.day;

      cells.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 1,
              child: DayCell(
                day: day,
                isEnabled: isEnabled,
                isToday: isToday,
                record: record,
                onTap: () => records.toggleDay(jobId, dateKey),
                onLongPress: () => NoteDialog.show(
                  context,
                  dateKey: dateKey,
                  jobId: jobId,
                  record: record,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Pad to multiple of 7
    while (cells.length % 7 != 0) {
      cells.add(const Expanded(child: AspectRatio(aspectRatio: 1)));
    }

    // Split into rows of 7
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(Row(children: cells.sublist(i, i + 7)));
    }

    return rows;
  }
}
