// placeholder
// lib/core/network/api_response.dart

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data, message: null);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(success: false, data: null, message: message);
  }

  bool get isSuccess => success;

  bool get hasError => !success;

  @override
  String toString() {
    return "ApiResponse(success: $success, data: $data, message: $message)";
  }
}
