import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class WebDAVServer {
  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final DateTime addedAt;
  final DateTime lastUsedAt;

  WebDAVServer({
    String? id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.addedAt,
    required this.lastUsedAt,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password': _encryptPassword(password),
      'addedAt': addedAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
    };
  }

  factory WebDAVServer.fromMap(Map<String, dynamic> map) {
    return WebDAVServer(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      username: map['username'],
      password: _decryptPassword(map['password']),
      addedAt: DateTime.parse(map['addedAt']),
      lastUsedAt: DateTime.parse(map['lastUsedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory WebDAVServer.fromJson(String source) => WebDAVServer.fromMap(json.decode(source));

  WebDAVServer copyWith({
    String? id,
    String? name,
    String? url,
    String? username,
    String? password,
    DateTime? addedAt,
    DateTime? lastUsedAt,
  }) {
    return WebDAVServer(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      addedAt: addedAt ?? this.addedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  static String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String _decryptPassword(String encryptedPassword) {
    return encryptedPassword;
  }
}
