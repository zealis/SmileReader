import 'dart:convert';
import 'package:uuid/uuid.dart';

class ReadingStatistics {
  final String id;
  final String bookId;
  final String userId;
  final int readingTime;
  final DateTime date;
  final int startPage;
  final int endPage;

  ReadingStatistics({
    String? id,
    required this.bookId,
    required this.userId,
    required this.readingTime,
    required this.date,
    required this.startPage,
    required this.endPage,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'readingTime': readingTime,
      'date': date.toIso8601String(),
      'startPage': startPage,
      'endPage': endPage,
    };
  }

  factory ReadingStatistics.fromMap(Map<String, dynamic> map) {
    return ReadingStatistics(
      id: map['id'],
      bookId: map['bookId'],
      userId: map['userId'],
      readingTime: map['readingTime'],
      date: DateTime.parse(map['date']),
      startPage: map['startPage'],
      endPage: map['endPage'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ReadingStatistics.fromJson(String source) => ReadingStatistics.fromMap(json.decode(source));

  ReadingStatistics copyWith({
    String? id,
    String? bookId,
    String? userId,
    int? readingTime,
    DateTime? date,
    int? startPage,
    int? endPage,
  }) {
    return ReadingStatistics(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      readingTime: readingTime ?? this.readingTime,
      date: date ?? this.date,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
    );
  }
}
