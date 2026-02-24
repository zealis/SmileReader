import 'dart:convert';
import 'package:uuid/uuid.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String coverPath;
  final String filePath;
  final String format;
  final int size;
  final DateTime addedAt;
  final DateTime lastReadAt;
  final int totalPages;
  final int currentPage;
  final double readingProgress;

  Book({
    String? id,
    required this.title,
    required this.author,
    required this.coverPath,
    required this.filePath,
    required this.format,
    required this.size,
    required this.addedAt,
    required this.lastReadAt,
    required this.totalPages,
    required this.currentPage,
    required this.readingProgress,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverPath': coverPath,
      'filePath': filePath,
      'format': format,
      'size': size,
      'addedAt': addedAt.toIso8601String(),
      'lastReadAt': lastReadAt.toIso8601String(),
      'totalPages': totalPages,
      'currentPage': currentPage,
      'readingProgress': readingProgress,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      coverPath: map['coverPath'],
      filePath: map['filePath'],
      format: map['format'],
      size: map['size'],
      addedAt: DateTime.parse(map['addedAt']),
      lastReadAt: DateTime.parse(map['lastReadAt']),
      totalPages: map['totalPages'],
      currentPage: map['currentPage'],
      readingProgress: map['readingProgress'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverPath,
    String? filePath,
    String? format,
    int? size,
    DateTime? addedAt,
    DateTime? lastReadAt,
    int? totalPages,
    int? currentPage,
    double? readingProgress,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      size: size ?? this.size,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      readingProgress: readingProgress ?? this.readingProgress,
    );
  }
}
