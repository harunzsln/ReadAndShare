import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:read_and_share/models/book_model.dart';

class BookService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  final Dio _dio;
  final String apiKey;

  BookService({Dio? dio, String? overrideApiKey})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'ReadAndShareApp/1.0',
              },
            ),
          ),
      apiKey = overrideApiKey ?? dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';

  @visibleForTesting
  String? normalizeIsbn(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9Xx]'), '');
    if (cleaned.length == 10 || cleaned.length == 13) {
      return cleaned;
    }
    return null;
  }

  Future<BookModel?> fetchByIsbn(String rawIsbn) async {
    final isbn = normalizeIsbn(rawIsbn);
    if (isbn == null) {
      throw Exception('Invalid ISBN. Please provide 10 or 13 digit ISBN.');
    }

    final query = <String, dynamic>{'q': 'isbn:$isbn'};
    if (apiKey.isNotEmpty) {
      query['key'] = apiKey;
    }

    try {
      final res = await _dio.get('', queryParameters: query);
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;
        if (items == null || items.isEmpty) return null;
        final first = items.first as Map<String, dynamic>;
        return BookModel.fromGoogleItem(first, isbn);
      }

      if (res.statusCode == 403) {
        throw Exception('API quota exceeded or access forbidden.');
      }
      if (res.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      }
      throw Exception('Network error HTTP ${res.statusCode}');
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = e.response?.statusMessage ?? e.message;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timed out. Please try again.');
      }

      if (code == 403) {
        throw Exception('API quota exceeded or access forbidden.');
      }
      if (code == 429) {
        throw Exception('Too many requests. Please try again later.');
      }
      throw Exception('Request failed: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
