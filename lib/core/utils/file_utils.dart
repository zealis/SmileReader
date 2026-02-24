import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  // 获取应用文档目录
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // 获取应用缓存目录
  static Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  // 获取应用数据目录
  static Future<Directory> getAppDataDirectory() async {
    Directory documentsDir = await getDocumentsDirectory();
    Directory appDataDir = Directory('${documentsDir.path}/app_data');
    if (!await appDataDir.exists()) {
      await appDataDir.create(recursive: true);
    }
    return appDataDir;
  }

  // 获取书籍目录
  static Future<Directory> getBooksDirectory() async {
    Directory documentsDir = await getDocumentsDirectory();
    Directory booksDir = Directory('${documentsDir.path}/books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir;
  }

  // 获取封面目录
  static Future<Directory> getCoversDirectory() async {
    Directory documentsDir = await getDocumentsDirectory();
    Directory coversDir = Directory('${documentsDir.path}/covers');
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  // 计算文件大小的可读形式
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // 获取文件扩展名
  static String getFileExtension(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  // 获取文件名（不含扩展名）
  static String getFileNameWithoutExtension(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return fileName;
    return fileName.substring(0, dotIndex);
  }

  // 检查文件是否存在
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  // 删除文件
  static Future<bool> deleteFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  // 清空目录
  static Future<void> clearDirectory(String directoryPath) async {
    Directory directory = Directory(directoryPath);
    if (await directory.exists()) {
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await clearDirectory(entity.path);
          await entity.delete();
        }
      }
    }
  }

  // 获取目录大小
  static Future<int> getDirectorySize(String directoryPath) async {
    Directory directory = Directory(directoryPath);
    if (!await directory.exists()) return 0;

    int size = 0;
    try {
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            size += await entity.length();
          } catch (e) {
            // 忽略无法访问的文件
            print('Error getting file size: $e');
          }
        }
      }
    } catch (e) {
      // 忽略无法访问的目录
      print('Error listing directory: $e');
    }
    return size;
  }
}
