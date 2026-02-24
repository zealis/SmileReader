import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  // 使用 SHA-256 加密字符串
  static String sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 使用 MD5 加密字符串
  static String md5(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // 生成随机盐
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // 密码哈希（带盐）
  static String hashPassword(String password, [String? salt]) {
    final saltValue = salt ?? generateSalt();
    final combined = '$password$saltValue';
    final hashed = sha256.convert(utf8.encode(combined)).toString();
    return '$saltValue:$hashed';
  }

  // 验证密码
  static bool verifyPassword(String password, String hashedPassword) {
    final parts = hashedPassword.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final hash = parts[1];
    final combined = '$password$salt';
    final computedHash = sha256.convert(utf8.encode(combined)).toString();
    return computedHash == hash;
  }

  // 生成随机字符串
  static String generateRandomString([int length = 32]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // 编码字符串为 Base64
  static String base64Encode(String input) {
    final bytes = utf8.encode(input);
    return base64Url.encode(bytes);
  }

  // 解码 Base64 字符串
  static String base64Decode(String input) {
    final bytes = base64Url.decode(input);
    return utf8.decode(bytes);
  }
}
