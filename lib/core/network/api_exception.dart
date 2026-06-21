/// Single exception type surfaced by the network layer.
/// Repositories convert this into [Result.Err] with a user-readable message.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 422;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
