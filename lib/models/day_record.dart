// Sentinel object to detect "not provided" in copyWith
const _unset = Object();

class DayRecord {
  final int? id;
  final int jobId;
  final String date; // YYYY-MM-DD
  final bool isWorked;
  final String? note;

  const DayRecord({
    this.id,
    required this.jobId,
    required this.date,
    required this.isWorked,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'jobId': jobId,
        'date': date,
        'isWorked': isWorked ? 1 : 0,
        'note': note,
      };

  factory DayRecord.fromMap(Map<String, dynamic> map) => DayRecord(
        id: map['id'] as int?,
        jobId: map['jobId'] as int,
        date: map['date'] as String,
        isWorked: (map['isWorked'] as int) == 1,
        note: map['note'] as String?,
      );

  /// Use [note] = null explicitly to clear the note.
  /// If [note] is not provided, the existing note is kept.
  DayRecord copyWith({
    int? id,
    int? jobId,
    String? date,
    bool? isWorked,
    Object? note = _unset,
  }) {
    return DayRecord(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      date: date ?? this.date,
      isWorked: isWorked ?? this.isWorked,
      note: identical(note, _unset) ? this.note : note as String?,
    );
  }

  bool get hasNote => note != null && note!.isNotEmpty;

  @override
  String toString() =>
      'DayRecord(id: $id, jobId: $jobId, date: $date, isWorked: $isWorked, note: $note)';
}
