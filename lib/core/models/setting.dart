import 'dart:convert';
import 'package:uuid/uuid.dart';

class Setting {
  final String id;
  final String userId;
  final String key;
  final dynamic value;

  Setting({
    String? id,
    required this.userId,
    required this.key,
    required this.value,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'key': key,
      'value': _encodeValue(value),
    };
  }

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'],
      userId: map['userId'],
      key: map['key'],
      value: _decodeValue(map['value']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Setting.fromJson(String source) => Setting.fromMap(json.decode(source));

  Setting copyWith({
    String? id,
    String? userId,
    String? key,
    dynamic value,
  }) {
    return Setting(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  static dynamic _encodeValue(dynamic value) {
    if (value is Map || value is List) {
      return json.encode(value);
    }
    return value;
  }

  static dynamic _decodeValue(dynamic value) {
    if (value is String) {
      try {
        return json.decode(value);
      } catch (e) {
        return value;
      }
    }
    return value;
  }
}
