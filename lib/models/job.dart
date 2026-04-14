class Job {
  final int? id;
  final String name;
  final String startDate; // YYYY-MM-DD
  final bool isActive;
  final String createdAt; // YYYY-MM-DD

  const Job({
    this.id,
    required this.name,
    required this.startDate,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'startDate': startDate,
        'isActive': isActive ? 1 : 0,
        'createdAt': createdAt,
      };

  factory Job.fromMap(Map<String, dynamic> map) => Job(
        id: map['id'] as int?,
        name: map['name'] as String,
        startDate: map['startDate'] as String,
        isActive: (map['isActive'] as int) == 1,
        createdAt: map['createdAt'] as String,
      );

  Job copyWith({
    int? id,
    String? name,
    String? startDate,
    bool? isActive,
    String? createdAt,
  }) =>
      Job(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() =>
      'Job(id: $id, name: $name, startDate: $startDate, isActive: $isActive)';
}
