// placeholder
// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'api_response.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = ApiConstants.baseUrl});

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> get(
    String endpoint, {
    String? token,
    Map<String, String>? query,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: query);

      final response = await http
          .get(uri, headers: _headers(token: token))
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      return _processResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .post(
            uri,
            headers: _headers(token: token),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      return _processResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .put(
            uri,
            headers: _headers(token: token),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      return _processResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .delete(uri, headers: _headers(token: token))
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      return _processResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  ApiResponse _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded);
      } else {
        return ApiResponse.error(decoded.toString());
      }
    } catch (e) {
      return ApiResponse.error('Invalid response format');
    }
  }
}