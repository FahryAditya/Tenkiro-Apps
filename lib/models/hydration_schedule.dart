/// Hydration schedule model
class HydrationSchedule {
  final List<int> hours; // Default hours to drink water
  final double targetLiters; // Daily target in liters

  const HydrationSchedule({
    required this.hours,
    required this.targetLiters,
  });

  /// Default schedule: 07:00, 09:00, 11:00, 13:00, 15:00, 17:00, 19:00
  static HydrationSchedule get defaultSchedule => const HydrationSchedule(
        hours: [7, 9, 11, 13, 15, 17, 19],
        targetLiters: 2.0,
      );

  /// Check if hour is in valid range (not 21:00-05:59)
  static bool isValidHour(int hour) {
    return hour >= 6 && hour < 21;
  }

  /// Get next scheduled hour from current time
  int? getNextScheduledHour(int currentHour) {
    for (final hour in hours) {
      if (hour > currentHour && isValidHour(hour)) {
        return hour;
      }
    }
    return null; // No more today
  }
}

/// Daily hydration progress
class HydrationProgress {
  final DateTime date;
  final double litersConsumed;
  final double targetLiters;
  final List<int> completedHours;

  HydrationProgress({
    required this.date,
    this.litersConsumed = 0.0,
    this.targetLiters = 2.0,
    this.completedHours = const [],
  });

  /// Progress percentage
  double get percentage => targetLiters > 0
      ? (litersConsumed / targetLiters * 100).clamp(0, 100)
      : 0;

  /// Is goal achieved
  bool get isGoalAchieved => litersConsumed >= targetLiters;

  /// Remaining liters
  double get remainingLiters =>
      (targetLiters - litersConsumed).clamp(0, targetLiters);

  /// To JSON for storage
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'litersConsumed': litersConsumed,
        'targetLiters': targetLiters,
        'completedHours': completedHours,
      };

  /// From JSON
  factory HydrationProgress.fromJson(Map<String, dynamic> json) =>
      HydrationProgress(
        date: DateTime.parse(json['date'] as String),
        litersConsumed: (json['litersConsumed'] as num?)?.toDouble() ?? 0.0,
        targetLiters: (json['targetLiters'] as num?)?.toDouble() ?? 2.0,
        completedHours:
            (json['completedHours'] as List<dynamic>?)?.cast<int>() ?? [],
      );

  /// Copy with
  HydrationProgress copyWith({
    DateTime? date,
    double? litersConsumed,
    double? targetLiters,
    List<int>? completedHours,
  }) =>
      HydrationProgress(
        date: date ?? this.date,
        litersConsumed: litersConsumed ?? this.litersConsumed,
        targetLiters: targetLiters ?? this.targetLiters,
        completedHours: completedHours ?? this.completedHours,
      );
}
