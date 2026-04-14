import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../core/db/database_helper.dart';

class RecordProvider extends ChangeNotifier {
  /// date string (YYYY-MM-DD) → DayRecord
  final Map<String, DayRecord> _records = {};
  int? _currentJobId;

  Map<String, DayRecord> get records => _records;
  int? get currentJobId => _currentJobId;

  DayRecord? getRecord(String date) => _records[date];

  /// Total days explicitly marked as worked.
  int get totalWorked =>
      _records.values.where((r) => r.isWorked).length;

  /// Unworked = total days in range minus worked.
  int totalUnworked(String startDateKey) {
    final start = DateTime.parse(startDateKey);
    final today = DateTime.now();
    final s = DateTime(start.year, start.month, start.day);
    final t = DateTime(today.year, today.month, today.day);
    final totalDays = t.difference(s).inDays + 1;
    if (totalDays <= 0) return 0;
    return (totalDays - totalWorked).clamp(0, totalDays);
  }

  Future<void> loadRecords(int jobId) async {
    _currentJobId = jobId;
    final list = await DatabaseHelper.getRecordsForJob(jobId);
    _records.clear();
    for (final r in list) {
      _records[r.date] = r;
    }
    notifyListeners();
  }

  void clearRecords() {
    _records.clear();
    _currentJobId = null;
    notifyListeners();
  }

  /// Optimistic toggle — updates UI immediately, then persists to DB.
  Future<void> toggleDay(int jobId, String date) async {
    final existing = _records[date];
    final newWorked = !(existing?.isWorked ?? false);

    // Optimistic update
    final optimistic = existing != null
        ? existing.copyWith(isWorked: newWorked)
        : DayRecord(jobId: jobId, date: date, isWorked: newWorked);
    _records[date] = optimistic;
    notifyListeners();

    // Persist
    await DatabaseHelper.upsertRecord(optimistic);

    // Reload to capture DB-generated ID (only if id was null)
    if (optimistic.id == null) {
      final saved = await DatabaseHelper.getRecord(jobId, date);
      if (saved != null) {
        _records[date] = saved;
        notifyListeners();
      }
    }
  }

  Future<void> saveNote(int jobId, String date, String note) async {
    final existing = _records[date];
    final updated = existing != null
        ? existing.copyWith(note: note)
        : DayRecord(jobId: jobId, date: date, isWorked: false, note: note);
    await DatabaseHelper.upsertRecord(updated);
    final saved = await DatabaseHelper.getRecord(jobId, date);
    _records[date] = saved ?? updated;
    notifyListeners();
  }

  Future<void> deleteNote(int jobId, String date) async {
    final existing = _records[date];
    if (existing == null) return;
    // Clear note (keep isWorked state)
    final updated = existing.copyWith(note: null);
    await DatabaseHelper.upsertRecord(updated);
    final saved = await DatabaseHelper.getRecord(jobId, date);
    _records[date] = saved ?? updated;
    notifyListeners();
  }
}
