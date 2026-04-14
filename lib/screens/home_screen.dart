import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../utils/date_utils.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Puantaj'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Bitenler'),
            ],
          ),
          actions: [
            // Theme toggle
            Consumer<ThemeProvider>(
              builder: (_, tp, __) => IconButton(
                icon: Icon(tp.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                tooltip: tp.isDark ? 'Açık mod' : 'Koyu mod',
                onPressed: tp.toggleTheme,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<JobProvider>(
          builder: (context, jobProv, _) {
            final activeJobs = jobProv.jobs.where((j) => j.isActive).toList();
            final completedJobs = jobProv.jobs.where((j) => !j.isActive).toList();

            return TabBarView(
              children: [
                _JobList(
                  jobs: activeJobs,
                  jobProv: jobProv,
                  emptyTitle: 'Henüz iş eklenmedi',
                  emptySubtitle: 'Çalışmalarını takip etmek için\naşağıdaki "Yeni İş" butonuna dokun.',
                ),
                _JobList(
                  jobs: completedJobs,
                  jobProv: jobProv,
                  emptyTitle: 'Biten iş yok',
                  emptySubtitle: 'Tamamladığınız işler burada listelenecek.',
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddJobDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Yeni İş'),
        ),
      ),
    );
  }

  Future<void> _showAddJobDialog(BuildContext context) async {
    await showDialog(context: context, builder: (_) => const _AddJobDialog());
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Job List Tab
// ──────────────────────────────────────────────────────────────────────────────

class _JobList extends StatelessWidget {
  final List<Job> jobs;
  final JobProvider jobProv;
  final String emptyTitle;
  final String emptySubtitle;

  const _JobList({
    required this.jobs,
    required this.jobProv,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return _EmptyState(title: emptyTitle, subtitle: emptySubtitle);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: jobs.length,
      itemBuilder: (context, i) {
        final job = jobs[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _JobCard(
            job: job,
            workedCount: jobProv.workedCount(job.id!),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailScreen(job: job),
                ),
              );
              if (context.mounted) {
                context.read<JobProvider>().refreshWorkedCount(job.id!);
              }
            },
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Empty state
// ──────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 72,
              color: colors.subtext.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.subtext,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Job card
// ──────────────────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final Job job;
  final int workedCount;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.workedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: colors.cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left: icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: job.isActive
                      ? scheme.primary.withOpacity(0.12)
                      : colors.subtext.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_center_outlined,
                  size: 22,
                  color: job.isActive ? scheme.primary : colors.subtext,
                ),
              ),

              const SizedBox(width: 14),

              // Center: info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: job.isActive
                                ? colors.worked.withOpacity(0.15)
                                : colors.subtext.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            job.isActive ? 'Aktif' : 'Bitti',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: job.isActive
                                  ? colors.worked
                                  : colors.subtext,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: colors.subtext),
                        const SizedBox(width: 4),
                        Text(
                          formatDateFull(job.startDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.subtext,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.check_circle_outline,
                            size: 12, color: colors.worked),
                        const SizedBox(width: 4),
                        Text(
                          '$workedCount gün',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.subtext,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: chevron
              Icon(Icons.chevron_right, color: colors.subtext),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Add Job Dialog
// ──────────────────────────────────────────────────────────────────────────────

class _AddJobDialog extends StatefulWidget {
  const _AddJobDialog();

  @override
  State<_AddJobDialog> createState() => _AddJobDialogState();
}

class _AddJobDialogState extends State<_AddJobDialog> {
  final _nameCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'İşe başlama tarihi seç',
      cancelText: 'İptal',
      confirmText: 'Seç',
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await context.read<JobProvider>().addJob(name, _startDate);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Yeni İş Ekle',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'İş adı',
              prefixIcon: Icon(Icons.business_center_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          // Date picker tile
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: colors.statCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.separator),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Başlangıç: ${formatDateFull(toDateKey(_startDate))}',
                      style:
                          TextStyle(fontSize: 14, color: scheme.onSurface),
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 16, color: colors.subtext),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text('İptal', style: TextStyle(color: colors.subtext)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ekle'),
        ),
      ],
    );
  }
}
