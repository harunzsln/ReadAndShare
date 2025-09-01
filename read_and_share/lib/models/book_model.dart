//import 'package:flutter/material.dart';
//import 'dart:math';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class BookModel {
  @HiveField(0)
  final String isbn;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> authors;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? thumbnail;

  @HiveField(5)
  final String? publishedDate;

  @HiveField(6)
  final List<String> categories;

  @HiveField(7)
  final bool isFavorite;

  @HiveField(8)
  final DateTime createdAt;

  BookModel({
    required this.isbn,
    required this.title,
    required this.authors,
    this.description,
    this.thumbnail,
    this.publishedDate,
    this.categories = const [],
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookModelToJson(this);

  factory BookModel.fromGoogleItem(Map<String, dynamic> item, String isbn) {
    final vi = item['volumeInfo'] as Map<String, dynamic>? ?? const {};
    final imageLinks = vi['imageLinks'] as Map<String, dynamic>? ?? const {};
    final thumb = imageLinks['thumbnail'] as String?;
    return BookModel(
      isbn: isbn,
      title: (vi['title'] as String?)?.trim().isNotEmpty == true
          ? vi['title'] as String
          : 'Bilinmeyen Başlık',
      authors: ((vi['authors'] as List?)?.cast<String>() ?? const ['Unknown'])
          .map((e) => e.toString())
          .toList(),
      description: vi['description'] as String?,
      thumbnail: thumb,
      publishedDate: vi['publishedDate'] as String?,
      categories: (vi['categories'] as List?)?.cast<String>() ?? const [],
    );
  }

  BookModel copyWith({
    String? title,
    List<String>? authors,
    String? description,
    String? thumbnail,
    String? publishedDate,
    List<String>? categories,
    bool? isFavorite,
  }) {
    return BookModel(
      isbn: isbn,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      publishedDate: publishedDate ?? this.publishedDate,
      categories: categories ?? this.categories,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
