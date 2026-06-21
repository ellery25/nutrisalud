/// Nutrition goals & habit tracking (Phase 5: Nutrition Goals).
library;

enum GoalType {
  water('Drink water', 'glasses', 'water'),
  fruitVeg('Fruits & vegetables', 'servings', 'fruit_veg'),
  homeCooked('Home-cooked meals', 'meals', 'home_cooked'),
  mindfulEating('Mindful eating breaks', 'breaks', 'mindful_eating'),
  custom('Custom habit', 'times', 'custom');

  const GoalType(this.label, this.unit, this.apiName);
  final String label;
  final String unit;

  /// Snake-case identifier expected by the backend API.
  final String apiName;

  static GoalType fromApiName(String name) =>
      GoalType.values.firstWhere((t) => t.apiName == name,
          orElse: () => GoalType.custom);
}

class NutritionGoal {
  const NutritionGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.dailyTarget,
    required this.createdAt,
  });

  final String id;
  final GoalType type;
  final String title;
  final int dailyTarget;
  final DateTime createdAt;

  // ── Local persistence (SharedPreferences) ──────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'dailyTarget': dailyTarget,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NutritionGoal.fromJson(Map<String, dynamic> json) => NutritionGoal(
        id: json['id'] as String,
        type: GoalType.values.asNameMap()[json['type']] ?? GoalType.custom,
        title: json['title'] as String,
        dailyTarget: json['dailyTarget'] as int? ?? 1,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  // ── Backend API (v1) ───────────────────────────────────────────────────

  /// Payload for POST /goals.
  Map<String, dynamic> toServerJson() => {
        'goal_type': type.apiName,
        'title': title,
        'daily_target': dailyTarget,
      };

  /// Parses a server response (snake_case field names).
  factory NutritionGoal.fromServerJson(Map<String, dynamic> json) =>
      NutritionGoal(
        id: json['id'] as String,
        type: GoalType.fromApiName(json['goal_type'] as String),
        title: json['title'] as String,
        dailyTarget: json['daily_target'] as int? ?? 1,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// One day of progress against a goal. Key format: `goalId|yyyy-MM-dd`.
class GoalCheckIn {
  const GoalCheckIn({required this.goalId, required this.day, required this.count});

  final String goalId;
  final DateTime day;
  final int count;

  Map<String, dynamic> toJson() => {
        'goalId': goalId,
        'day': day.toIso8601String(),
        'count': count,
      };

  factory GoalCheckIn.fromJson(Map<String, dynamic> json) => GoalCheckIn(
        goalId: json['goalId'] as String,
        day: DateTime.parse(json['day'] as String),
        count: json['count'] as int? ?? 0,
      );
}
