/// Food & symptom journal entry (Phase 5: Food Journal).
library;

enum MealType { breakfast, lunch, dinner, snack }

enum DigestiveSymptom {
  none('No symptoms'),
  bloating('Bloating'),
  heartburn('Heartburn'),
  nausea('Nausea'),
  cramps('Cramps'),
  constipation('Constipation'),
  diarrhea('Diarrhea');

  const DigestiveSymptom(this.label);
  final String label;
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.timestamp,
    required this.mealType,
    required this.description,
    this.symptoms = const [],
    this.severity = 0,
    this.notes = '',
  });

  final String id;
  final DateTime timestamp;
  final MealType mealType;
  final String description;
  final List<DigestiveSymptom> symptoms;

  /// 0 (none) .. 3 (severe) — overall digestive discomfort after the meal.
  final int severity;
  final String notes;

  bool get hadSymptoms =>
      symptoms.any((s) => s != DigestiveSymptom.none) && severity > 0;

  // ── Local persistence (SharedPreferences) ──────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'mealType': mealType.name,
        'description': description,
        'symptoms': symptoms.map((s) => s.name).toList(),
        'severity': severity,
        'notes': notes,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        mealType: MealType.values.asNameMap()[json['mealType']] ??
            MealType.snack,
        description: json['description'] as String? ?? '',
        symptoms: (json['symptoms'] as List? ?? [])
            .map((s) =>
                DigestiveSymptom.values.asNameMap()[s] ??
                DigestiveSymptom.none)
            .toList(),
        severity: json['severity'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
      );

  // ── Backend API (v1) ───────────────────────────────────────────────────

  /// Payload for POST /journal/entries.
  Map<String, dynamic> toServerJson() => {
        'meal_type': mealType.name,
        'description': description,
        'symptoms': symptoms
            .where((s) => s != DigestiveSymptom.none)
            .map((s) => s.name)
            .toList(),
        'severity': severity,
        'notes': notes,
        'logged_at': timestamp.toUtc().toIso8601String(),
      };

  /// Parses a server response (snake_case field names, `logged_at` timestamp).
  factory JournalEntry.fromServerJson(Map<String, dynamic> json) =>
      JournalEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['logged_at'] as String),
        mealType: MealType.values.asNameMap()[json['meal_type']] ??
            MealType.snack,
        description: json['description'] as String? ?? '',
        symptoms: (json['symptoms'] as List? ?? [])
            .map((s) =>
                DigestiveSymptom.values.asNameMap()[s as String] ??
                DigestiveSymptom.none)
            .toList(),
        severity: json['severity'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}
