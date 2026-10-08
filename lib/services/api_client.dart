import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final base = AppConfig.apiBaseUrl.endsWith('/')
        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
        : AppConfig.apiBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _client.put(
      _uri(path),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _client.patch(
      _uri(path),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.delete(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;

    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'The server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message;

      if (decoded is Map<String, dynamic> && decoded['detail'] is String) {
        message = decoded['detail'] as String;
      } else if (decoded is Map<String, dynamic> &&
          decoded['detail'] is List) {
        message = (decoded['detail'] as List).join(' ');
      } else if (decoded is Map<String, dynamic> &&
          decoded['non_field_errors'] is List) {
        message = (decoded['non_field_errors'] as List).join(' ');
      } else {
        message = 'The server request failed (${response.statusCode}).';
      }

      throw ApiException(message, statusCode: response.statusCode);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const ApiException('The server returned an unexpected response.');
  }

  void dispose() => _client.close();
}