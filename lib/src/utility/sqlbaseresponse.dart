class SqlBaseResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  final String error;

  /// Returns a user-friendly message based on the status code.
  String get message => _getMessage();

  SqlBaseResponse({
    required this.statusCode,
    this.data = const {},
    this.error = "",
  });

  /// Internal method to map status codes to messages.
  String _getMessage() {
    switch (statusCode) {
      case 200:
        return "Data Available";
      case 201:
        return "Saved";
      case 0:
        return "Error";
      case 400:
        return "Bad Request";
      case 401:
        return "Unauthorized";
      case 404:
        return "Not Found";
      case 500:
        return "Server Error";
      default:
        return "Unknown Status";
    }
  }

  /// Factory method for success response
  factory SqlBaseResponse.success(Map<String, dynamic> data, [int code = 200]) {
    return SqlBaseResponse(statusCode: code, data: data);
  }

  /// Factory method for error response
  factory SqlBaseResponse.failure(String error, [int code = 0]) {
    return SqlBaseResponse(statusCode: code, error: error);
  }

  @override
  String toString() {
    return 'SqlBaseResponse(statusCode: $statusCode, message: $message, data: $data, error: $error)';
  }
}
