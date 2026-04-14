import 'package:flutter/material.dart';
import '../models/job.dart';
import '../core/db/database_helper.dart';
import '../utils/date_utils.dart';

class JobProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  final Map<int, int> _workedCounts = {};

  List<Job> get jobs => _jobs;

  int workedCount(int jobId) => _workedCounts[jobId] ?? 0;

  Future<void> loadJobs() async {
    _jobs = await DatabaseHelper.getJobs();
    // Load worked counts in parallel
    await Future.wait(
      _jobs.where((j) => j.id != null).map((j) async {
        _workedCounts[j.id!] = await DatabaseHelper.getWorkedCount(j.id!);
      }),
    );
    notifyListeners();
  }

  Future<void> refreshWorkedCount(int jobId) async {
    _workedCounts[jobId] = await DatabaseHelper.getWorkedCount(jobId);
    notifyListeners();
  }

  Future<Job> addJob(String name, DateTime startDate) async {
    final dateStr = toDateKey(startDate);
    final nowStr = toDateKey(DateTime.now());
    final job = Job(name: name, startDate: dateStr, createdAt: nowStr);
    final id = await DatabaseHelper.insertJob(job);
    final newJob = job.copyWith(id: id);
    _jobs.insert(0, newJob);
    _workedCounts[id] = 0;
    notifyListeners();
    return newJob;
  }

  Future<void> updateJobName(int id, String name) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    final updated = _jobs[idx].copyWith(name: name);
    await DatabaseHelper.updateJob(updated);
    _jobs[idx] = updated;
    notifyListeners();
  }

  Future<void> finishJob(int id) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    final updated = _jobs[idx].copyWith(isActive: false);
    await DatabaseHelper.updateJob(updated);
    _jobs[idx] = updated;
    notifyListeners();
  }

  Future<void> reactivateJob(int id) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    final updated = _jobs[idx].copyWith(isActive: true);
    await DatabaseHelper.updateJob(updated);
    _jobs[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteJob(int id) async {
    await DatabaseHelper.deleteJob(id);
    _jobs.removeWhere((j) => j.id == id);
    _workedCounts.remove(id);
    notifyListeners();
  }
}
