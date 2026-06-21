import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'api_exception.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(httpClientProvider)),
);

/// Thin JSON HTTP wrapper: one place for timeouts, headers,
/// status-code handling and JSON decoding.
class ApiClient {
  ApiClient(this._client);

  final http.Client _client;

  Future<dynamic> getJson(Uri uri, {String? token}) =>
      _send('GET', uri, token: token);

  Future<dynamic> postJson(Uri uri, Object body, {String? token}) =>
      _send('POST', uri, token: token, body: body);

  Future<dynamic> putJson(Uri uri, Object body, {String? token}) =>
      _send('PUT', uri, token: token, body: body);

  Future<dynamic> delete(Uri uri, {String? token}) =>
      _send('DELETE', uri, token: token);

  Future<dynamic> deleteJson(Uri uri, Object body, {String? token}) =>
      _send('DELETE', uri, token: token, body: body);

  Future<dynamic> _send(
    String method,
    Uri uri, {
    String? token,
    Object? body,
  }) async {
    final request = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json; charset=UTF-8';
    if (token != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      final streamed =
          await _client.send(request).timeout(AppConstants.httpTimeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(response.body) ??
            'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) return null;
    try {
      final decoded = jsonDecode(response.body);
      // All /api/v1 success responses are wrapped: {success, message, data}.
      // Unwrap so repositories work directly with the payload.
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    } on FormatException {
      throw const ApiException('Unexpected response from server.');
    }
  }

  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return (decoded['message'] ?? decoded['error'] ?? decoded['msg'])
            ?.toString();
      }
    } on FormatException {
      // Non-JSON error body; fall through to generic message.
    }
    return null;
  }
}
