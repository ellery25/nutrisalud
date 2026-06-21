import 'dart:typed_data';

/// A community post (legacy API calls these "comments").
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.createdAt,
    this.photoBytes,
  });

  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final DateTime? createdAt;
  final Uint8List? photoBytes;
}
