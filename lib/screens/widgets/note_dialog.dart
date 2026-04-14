import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/day_record.dart';
import '../../providers/record_provider.dart';
import '../../utils/date_utils.dart';

enum _NoteMode { view, add, edit }

class NoteDialog extends StatefulWidget {
  final String dateKey; // YYYY-MM-DD
  final int jobId;
  final DayRecord? record;

  const NoteDialog({
    super.key,
    required this.dateKey,
    required this.jobId,
    this.record,
  });

  /// Helper to show this dialog from anywhere.
  static Future<void> show(
    BuildContext context, {
    required String dateKey,
    required int jobId,
    DayRecord? record,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteDialog(
        dateKey: dateKey,
        jobId: jobId,
        record: record,
      ),
    );
  }

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late _NoteMode _mode;
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final note = widget.record?.note;
    _mode =
        (note != null && note.isNotEmpty) ? _NoteMode.view : _NoteMode.add;
    _ctrl = TextEditingController(text: note ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    await context
        .read<RecordProvider>()
        .saveNote(widget.jobId, widget.dateKey, text);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    await context
        .read<RecordProvider>()
        .deleteNote(widget.jobId, widget.dateKey);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PuantajColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final dateLabel = formatDateFull(widget.dateKey);

    return Container(
      padding:
          EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── header ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mode == _NoteMode.view ? 'Not' : 'Not Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colors.subtext),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── content ──
          if (_mode == _NoteMode.view) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.statCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.separator),
              ),
              child: Text(
                widget.record?.note ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'Sil',
                    icon: Icons.delete_outline,
                    color: scheme.error,
                    onTap: _saving ? null : _delete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilledButton(
                    label: 'Düzenle',
                    icon: Icons.edit_outlined,
                    onTap: _saving
                        ? null
                        : () => setState(() {
                              _mode = _NoteMode.edit;
                              _ctrl.text = widget.record?.note ?? '';
                            }),
                  ),
                ),
              ],
            ),
          ] else ...[
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Bu güne ait notunuzu yazın...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'İptal',
                    icon: Icons.close,
                    color: colors.subtext,
                    onTap: _saving ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilledButton(
                    label: 'Kaydet',
                    icon: Icons.check,
                    loading: _saving,
                    onTap: _saving ? null : _save,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── helper button widgets ──────────────────────────────────────────────────

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  const _FilledButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: scheme.primary,
      ),
      onPressed: onTap,
      icon: loading
          ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: color.withOpacity(0.5)),
        foregroundColor: color,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
