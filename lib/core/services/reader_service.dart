import 'dart:io';
import 'package:smile_reader/core/models/book.dart';
import 'package:smile_reader/core/services/database_service.dart';

class ReaderService {
  static final ReaderService _instance = ReaderService._internal();
  final DatabaseService _dbService = DatabaseService();

  factory ReaderService() {
    return _instance;
  }

  ReaderService._internal();

  // 打开书籍
  Future<Book> openBook(String bookId) async {
    List<Map<String, dynamic>> maps = await _dbService.query('books', where: {'id': bookId});
    if (maps.isEmpty) {
      throw Exception('Book not found');
    }
    return Book.fromMap(maps.first);
  }

  // 保存阅读进度
  Future<void> saveProgress(String bookId, int currentPage, double readingProgress) async {
    await _dbService.update('books', {
      'currentPage': currentPage,
      'readingProgress': readingProgress,
      'lastReadAt': DateTime.now().toIso8601String(),
    }, where: {'id': bookId});
  }

  // 获取阅读进度
  Future<Map<String, dynamic>> getProgress(String bookId) async {
    List<Map<String, dynamic>> maps = await _dbService.query('books', where: {'id': bookId});
    if (maps.isEmpty) throw Exception('Book not found');
    return {
      'currentPage': maps.first['currentPage'],
      'readingProgress': maps.first['readingProgress'],
      'totalPages': maps.first['totalPages'],
    };
  }

  // 获取书籍内容（支持分页）
  Future<String> getContent(String bookId, int page) async {
    try {
      List<Map<String, dynamic>> maps = await _dbService.query('books', where: {'id': bookId});
      if (maps.isEmpty) return '错误：书籍不存在';
      
      Book book = Book.fromMap(maps.first);
      print('Loading content from: ${book.filePath}, page: $page');
      
      File file = File(book.filePath);
      
      if (!await file.exists()) {
        print('File not found: ${book.filePath}');
        return '错误：文件不存在，请重新导入书籍';
      }
      
      // 检查文件格式
      String format = book.format.toLowerCase();
      if (['pdf', 'mobi', 'docx'].contains(format)) {
        return '错误：不支持的文件格式。请使用专门的阅读应用打开 $format 文件。';
      }
      
      // 读取文件内容
      String content = await file.readAsString();
      print('File read successfully, length: ${content.length}');
      
      // 实现简单的分页逻辑（每页5000字符）
      const int pageSize = 5000;
      int startIndex = page * pageSize;
      
      if (startIndex >= content.length) {
        return '已到达文件末尾';
      }
      
      int endIndex = (startIndex + pageSize).clamp(0, content.length);
      String pageContent = content.substring(startIndex, endIndex);
      
      // 更新总页数
      int totalPages = (content.length / pageSize).ceil();
      await _dbService.update('books', {
        'totalPages': totalPages,
      }, where: {'id': bookId});
      
      return pageContent;
    } catch (e) {
      print('Error getting content: $e');
      return '错误：$e';
    }
  }

  // 获取目录
  Future<List<Map<String, dynamic>>> getTableOfContents(String bookId) async {
    // 实际需要根据不同格式解析目录
    // 暂时返回空列表
    return [];
  }

  // 搜索内容
  Future<List<Map<String, dynamic>>> searchContent(String bookId, String query) async {
    List<Map<String, dynamic>> maps = await _dbService.query('books', where: {'id': bookId});
    if (maps.isEmpty) throw Exception('Book not found');
    
    Book book = Book.fromMap(maps.first);
    File file = File(book.filePath);
    
    if (!await file.exists()) throw Exception('File not found');
    
    List<Map<String, dynamic>> results = [];
    
    // 检查文件格式
    String format = book.format.toLowerCase();
    if (format == 'epub') {
      // EPUB文件需要特殊处理，这里返回空结果
      // 实际项目中需要使用EPUB解析库来搜索内容
      return results;
    }
    
    try {
      String content = await file.readAsString();
      
      // 简单的文本搜索
      List<String> lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'line': i + 1,
            'content': lines[i],
            'page': (i / 50).floor() + 1, // 假设每页50行
          });
        }
      }
    } catch (e) {
      print('Error reading file for search: $e');
      // 返回空结果
    }
    
    return results;
  }

  // 全局阅读设置
  Map<String, dynamic>? _globalSettings;

  // 设置阅读设置（全局）
  Future<void> setReadingSettings(String bookId, Map<String, dynamic> settings) async {
    // 保存为全局设置
    _globalSettings = settings;
    print('Global settings saved: $settings');
  }

  // 获取阅读设置（优先使用全局设置）
  Future<Map<String, dynamic>> getReadingSettings(String bookId) async {
    // 如果有全局设置，返回全局设置
    if (_globalSettings != null) {
      print('Using global settings: $_globalSettings');
      return _globalSettings!;
    }
    
    // 否则返回默认设置
    print('Using default settings');
    return {
      'fontSize': 16.0,
      'fontFamily': 'System',
      'lineSpacing': 1.5,
      'margin': 24.0,
      'theme': 'light',
      'pageLayout': 'scroll',
    };
  }
}
