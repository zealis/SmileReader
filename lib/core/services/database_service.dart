import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static bool _initialized = false;

  factory DatabaseService() {
    if (!_initialized) {
      _initialize();
    }
    return _instance;
  }

  DatabaseService._internal();

  static void _initialize() {
    // 初始化 sqflite_common_ffi 以支持 Windows 平台
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'smile_reader.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建书籍表
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        coverPath TEXT,
        filePath TEXT NOT NULL,
        format TEXT NOT NULL,
        size INTEGER NOT NULL,
        addedAt TEXT NOT NULL,
        lastReadAt TEXT NOT NULL,
        totalPages INTEGER NOT NULL,
        currentPage INTEGER NOT NULL,
        readingProgress REAL NOT NULL
      )
    ''');

    // 创建书签表
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        page INTEGER NOT NULL,
        position INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // 创建笔记表
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        content TEXT NOT NULL,
        page INTEGER NOT NULL,
        position INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // 创建阅读统计表
    await db.execute('''
      CREATE TABLE reading_statistics (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        userId TEXT NOT NULL,
        readingTime INTEGER NOT NULL,
        date TEXT NOT NULL,
        startPage INTEGER NOT NULL,
        endPage INTEGER NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // 创建设置表
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 创建书籍分类关联表
    await db.execute('''
      CREATE TABLE book_categories (
        bookId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        PRIMARY KEY (bookId, categoryId),
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // 创建 WebDAV 服务器表
    await db.execute('''
      CREATE TABLE webdav_servers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        addedAt TEXT NOT NULL,
        lastUsedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
  }

  // 通用的插入方法
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  // 通用的查询方法
  Future<List<Map<String, dynamic>>> query(String table, {Map<String, dynamic>? where}) async {
    final db = await database;
    return await db.query(table, where: where != null ? where.keys.map((k) => '$k = ?').join(' AND ') : null, whereArgs: where?.values.toList());
  }

  // 通用的更新方法
  Future<int> update(String table, Map<String, dynamic> data, {Map<String, dynamic>? where}) async {
    final db = await database;
    return await db.update(table, data, where: where != null ? where.keys.map((k) => '$k = ?').join(' AND ') : null, whereArgs: where?.values.toList());
  }

  // 通用的删除方法
  Future<int> delete(String table, {Map<String, dynamic>? where}) async {
    final db = await database;
    return await db.delete(table, where: where != null ? where.keys.map((k) => '$k = ?').join(' AND ') : null, whereArgs: where?.values.toList());
  }

  // 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
