import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/job.dart';
import '../../providers/record_provider.dart';
import '../../utils/date_utils.dart';

class StatsBar extends StatelessWidget {
  final Job job;

  const StatsBar({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Consumer<RecordProvider>(
      builder: (context, records, _) {
        final worked = records.totalWorked;
        final unworked = records.totalUnworked(job.startDate);
        final startLabel = formatDateFull(job.startDate);
        final isActive = job.isActive;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.separator),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.worked.withOpacity(0.15)
                          : scheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive
                              ? Icons.radio_button_checked
                              : Icons.check_circle_outline,
                          size: 12,
                          color: isActive ? colors.worked : scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Aktif' : 'Tamamlandı',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? colors.worked : scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Three stat cards
              Row(
                children: [
                  _StatCard(
                    label: 'Başlangıç',
                    value: startLabel,
                    icon: Icons.calendar_today_outlined,
                    color: scheme.primary,
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    label: 'Çalışılan',
                    value: '$worked gün',
                    icon: Icons.check_circle_outline,
                    color: colors.worked,
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    label: 'İzin / Tatil',
                    value: '$unworked gün',
                    icon: Icons.free_breakfast_outlined,
                    color: const Color(0xFFFF8A65),
                    colors: colors,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final PuantajColors colors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.statCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: colors.subtext,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
