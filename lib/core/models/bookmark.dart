import 'dart:convert';
import 'package:uuid/uuid.dart';

class Bookmark {
  final String id;
  final String bookId;
  final String title;
  final String content;
  final int page;
  final int position;
  final DateTime createdAt;

  Bookmark({
    String? id,
    required this.bookId,
    required this.title,
    required this.content,
    required this.page,
    required this.position,
    required this.createdAt,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'content': content,
      'page': page,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'],
      bookId: map['bookId'],
      title: map['title'],
      content: map['content'],
      page: map['page'],
      position: map['position'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Bookmark.fromJson(String source) => Bookmark.fromMap(json.decode(source));

  Bookmark copyWith({
    String? id,
    String? bookId,
    String? title,
    String? content,
    int? page,
    int? position,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      content: content ?? this.content,
      page: page ?? this.page,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
