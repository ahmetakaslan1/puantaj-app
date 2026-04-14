import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/record_provider.dart';
import '../utils/date_utils.dart';
import 'widgets/stats_bar.dart';
import 'widgets/month_section.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Job _job;
  final _scrollCtrl = ScrollController();
  final Map<String, GlobalKey> _monthKeys = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    await context.read<RecordProvider>().loadRecords(_job.id!);
    if (mounted) {
      setState(() => _isLoading = false);
      // Auto-scroll to current month after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    }
  }

  void _scrollToToday() {
    final today = DateTime.now();
    final key = '${today.year}-${today.month}';
    final monthKey = _monthKeys[key];
    if (monthKey?.currentContext != null) {
      Scrollable.ensureVisible(
        monthKey!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        alignment: 0.0,
      );
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // AppBar actions
  // ──────────────────────────────────────────

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: _job.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(ctrl: ctrl),
    );
    if (result != null && result.isNotEmpty && mounted) {
      await context.read<JobProvider>().updateJobName(_job.id!, result);
      setState(() => _job = _job.copyWith(name: result));
    }
  }

  Future<void> _toggleFinish() async {
    final isActive = _job.isActive;
    final confirm = await _confirm(
      context,
      title: isActive ? 'İşi Bitir' : 'Görevi Yeniden Aç',
      body: isActive
          ? '"${_job.name}" işini tamamlandı olarak işaretleyeceksiniz.'
          : '"${_job.name}" işini tekrar aktif yapacaksınız.',
      confirmLabel: isActive ? 'Bitir' : 'Aç',
    );
    if (!confirm || !mounted) return;
    if (isActive) {
      await context.read<JobProvider>().finishJob(_job.id!);
    } else {
      await context.read<JobProvider>().reactivateJob(_job.id!);
    }
    setState(() => _job = _job.copyWith(isActive: !isActive));
  }

  Future<void> _deleteJob() async {
    final confirm = await _confirm(
      context,
      title: 'İşi Sil',
      body: '"${_job.name}" ve tüm kayıtlar kalıcı olarak silinecek.',
      confirmLabel: 'Sil',
      isDestructive: true,
    );
    if (!confirm || !mounted) return;
    await context.read<JobProvider>().deleteJob(_job.id!);
    if (mounted) Navigator.pop(context);
  }

  // ──────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final months = getMonthRange(_job.startDate);
    final startDate = DateTime.parse(_job.startDate);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.cardBg,
        title: Text(
          _job.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Edit name
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'İsmi düzenle',
            onPressed: _editName,
          ),
          // Finish / reactivate
          IconButton(
            icon: Icon(
              _job.isActive
                  ? Icons.check_circle_outline
                  : Icons.replay_outlined,
            ),
            tooltip: _job.isActive ? 'İşi bitir' : 'Yeniden aç',
            onPressed: _toggleFinish,
          ),
          // Delete
          IconButton(
            icon: Icon(Icons.delete_outline, color: scheme.error),
            tooltip: 'İşi sil',
            onPressed: _deleteJob,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : months.isEmpty
              ? Center(
                  child: Text(
                    'Henüz gösterilecek ay yok.',
                    style: TextStyle(color: colors.subtext),
                  ),
                )
              : CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    // Stats bar
                    SliverToBoxAdapter(
                      child: StatsBar(job: _job),
                    ),

                    // Calendar header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_outlined,
                                size: 16, color: colors.subtext),
                            const SizedBox(width: 6),
                            Text(
                              'Çalışma Takvimi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.subtext,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Month sections
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final m = months[index];
                          final key = '${m.year}-${m.month}';
                          _monthKeys[key] ??= GlobalKey();
                          return KeyedSubtree(
                            key: _monthKeys[key],
                            child: MonthSection(
                              year: m.year,
                              month: m.month,
                              startDate: startDate,
                              today: today,
                              jobId: _job.id!,
                            ),
                          );
                        },
                        childCount: months.length,
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
    );
  }
}

// ──────────────────────────────────────────
// Helper dialogs
// ──────────────────────────────────────────

class _EditNameDialog extends StatelessWidget {
  final TextEditingController ctrl;

  const _EditNameDialog({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    return AlertDialog(
      backgroundColor: colors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('İsmi Düzenle',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'İş adı'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('İptal', style: TextStyle(color: colors.subtext)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, ctrl.text.trim()),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

/// Generic confirm dialog. Returns true if confirmed.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool isDestructive = false,
}) async {
  final colors = Theme.of(context).extension<PuantajColors>()!;
  final scheme = Theme.of(context).colorScheme;

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: colors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      content: Text(body, style: TextStyle(color: colors.subtext, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('İptal', style: TextStyle(color: colors.subtext)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                isDestructive ? scheme.error : scheme.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
