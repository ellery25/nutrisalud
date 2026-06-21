import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models.dart';

final remoteTipsProvider =
    AsyncNotifierProvider<RemoteTipsNotifier, List<Article>>(
  RemoteTipsNotifier.new,
);

class RemoteTipsNotifier extends AsyncNotifier<List<Article>> {
  ApiClient get _api => ref.read(apiClientProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Uri _uri(String path) =>
      Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  @override
  Future<List<Article>> build() async {
    final token = await _auth.readToken();
    if (token == null) return [];
    try {
      final data = await _api.getJson(
        _uri('/tips'),
        token: token,
      ) as Map<String, dynamic>;
      final items =
          (data['items'] as List? ?? []).cast<Map<String, dynamic>>();
      return items.map(Article.fromServerJson).toList();
    } on ApiException {
      return [];
    }
  }
}
