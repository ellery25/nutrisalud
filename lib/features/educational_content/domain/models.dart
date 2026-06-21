/// Educational content domain (Phase 4: replaces the legacy "Doctors"
/// section with a scalable knowledge hub).
library;

enum SpecialistKind {
  nutritionist('Nutritionist'),
  gastroenterologist('Gastroenterologist'),
  fitnessCoach('Fitness coach'),
  institution('Health institution'),
  creator('Verified content creator');

  const SpecialistKind(this.label);
  final String label;
}

/// Educational profile — serves both static curated entries and live
/// records from /api/v1/nutritionists.
class SpecialistProfile {
  const SpecialistProfile({
    required this.id,
    required this.name,
    required this.kind,
    required this.headline,
    required this.bio,
    required this.topics,
    this.imageAsset,
    this.photoUrl,
    this.websiteUrl,
    this.verified = false,
  });

  final String id;
  final String name;
  final SpecialistKind kind;
  final String headline;
  final String bio;
  final List<String> topics;

  /// Local asset path (static curated profiles only).
  final String? imageAsset;

  /// Remote photo URL from the backend (takes precedence over [imageAsset]).
  final String? photoUrl;

  final String? websiteUrl;
  final bool verified;

  /// Parses a backend nutritionist record from /api/v1/nutritionists.
  factory SpecialistProfile.fromServerJson(Map<String, dynamic> json) {
    final description = json['description'] as String? ?? '';
    return SpecialistProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Nutritionist',
      kind: SpecialistKind.nutritionist,
      headline: description,
      bio: description,
      topics: (json['skills'] as List? ?? []).cast<String>(),
      photoUrl: json['photo'] as String?,
      websiteUrl: json['website'] as String?,
      verified: false,
    );
  }
}

enum ArticleTopic {
  digestiveHealth('Digestive health'),
  nutritionBasics('Nutrition basics'),
  ibs('IBS-friendly'),
  gutHealth('Gut health'),
  intolerances('Food intolerances'),
  habits('Healthy habits');

  const ArticleTopic(this.label);
  final String label;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.topic,
    required this.summary,
    required this.body,
    required this.readMinutes,
    this.authorId,
  });

  final String id;
  final String title;
  final ArticleTopic topic;
  final String summary;

  /// Markdown-ish plain text body, paragraphs separated by blank lines.
  final String body;
  final int readMinutes;
  final String? authorId;

  List<String> get paragraphs => body
      .split('\n\n')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  /// Parses a backend professional tip from /api/v1/tips.
  factory Article.fromServerJson(Map<String, dynamic> json) {
    final content = json['content'] as String? ?? '';
    final wordCount = content.split(' ').where((w) => w.isNotEmpty).length;
    return Article(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      topic: ArticleTopic.digestiveHealth,
      summary: content.length > 200 ? '${content.substring(0, 200)}…' : content,
      body: content,
      readMinutes: (wordCount / 200).ceil().clamp(1, 60),
      authorId:
          (json['author'] as Map<String, dynamic>?)?['id'] as String?,
    );
  }
}
