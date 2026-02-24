import 'dart:convert';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String bookId;
  final String content;
  final int page;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    String? id,
    required this.bookId,
    required this.content,
    required this.page,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'page': page,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      bookId: map['bookId'],
      content: map['content'],
      page: map['page'],
      position: map['position'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  Note copyWith({
    String? id,
    String? bookId,
    String? content,
    int? page,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      page: page ?? this.page,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
