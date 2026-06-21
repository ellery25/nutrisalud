import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/result.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/post.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepository(
    api: ref.watch(apiClientProvider),
    auth: ref.watch(authRepositoryProvider),
  ),
);

/// Feed provider; invalidate to refresh.
final communityFeedProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) async {
  final result = await ref.watch(communityRepositoryProvider).fetchPosts();
  return result.when(ok: (posts) => posts, err: (m) => throw Exception(m));
});

class CommunityRepository {
  CommunityRepository({required ApiClient api, required AuthRepository auth})
      : _api = api,
        _auth = auth;

  final ApiClient _api;
  final AuthRepository _auth;

  Uri _uri(String path) => Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  Future<Result<List<CommunityPost>>> fetchPosts() async {
    final token = await _auth.readToken();
    if (token == null) return const Err('You need to sign in.');
    try {
      // ApiClient unwraps the envelope; data = {items: [...], meta: {...}}
      final data = await _api.getJson(_uri('/community/posts'), token: token)
          as Map<String, dynamic>;

      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      final posts = items.map((c) {
        final author = c['author'] as Map<String, dynamic>?;
        return CommunityPost(
          id: c['id'].toString(),
          content: c['content'] as String? ?? '',
          authorId: c['user_id'].toString(),
          authorName: author?['name'] as String? ?? 'Member',
          authorUsername: author?['username'] as String? ?? 'member',
          createdAt: DateTime.tryParse(c['timestamp'] as String? ?? ''),
          photoBytes: _decodePhoto(c['photo'] as String?),
        );
      }).toList();

      // Newest first; the API already orders by timestamp desc but sort locally
      // as a safety net.
      posts.sort((a, b) {
        final at = a.createdAt, bt = b.createdAt;
        if (at == null || bt == null) return 0;
        return bt.compareTo(at);
      });
      return Ok(posts);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  /// [userId] is no longer sent in the body — the server derives it from the JWT.
  Future<Result<void>> createPost({
    required String content,
    Uint8List? photoBytes,
  }) async {
    final token = await _auth.readToken();
    if (token == null) return const Err('You need to sign in.');
    try {
      await _api.postJson(
        _uri('/community/posts'),
        {
          'content': content,
          if (photoBytes != null) 'photo': base64Encode(photoBytes),
        },
        token: token,
      );
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  Future<Result<void>> deletePost(String postId) async {
    final token = await _auth.readToken();
    if (token == null) return const Err('You need to sign in.');
    try {
      await _api.delete(_uri('/community/posts/$postId'), token: token);
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  static Uint8List? _decodePhoto(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } on FormatException {
      return null;
    }
  }
}
