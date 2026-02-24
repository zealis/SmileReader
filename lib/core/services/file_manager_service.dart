import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smile_reader/core/models/book.dart';
import 'package:smile_reader/core/models/webdav_server.dart';
import 'package:smile_reader/core/services/database_service.dart';

class FileManagerService {
  static final FileManagerService _instance = FileManagerService._internal();
  final DatabaseService _dbService = DatabaseService();

  factory FileManagerService() {
    return _instance;
  }

  FileManagerService._internal();

  // 导入文件
  Future<List<Book>> importFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'epub', 'pdf', 'mobi', 'docx'],
    );

    if (result == null) return [];

    List<Book> importedBooks = [];
    Directory booksDirectory = await _getBooksDirectory();

    for (PlatformFile file in result.files) {
      if (file.path == null) continue;

      File sourceFile = File(file.path!);
      File destFile = File('${booksDirectory.path}/${file.name}');

      // 复制文件到应用目录
      await sourceFile.copy(destFile.path);

      // 创建书籍对象
      Book book = Book(
        title: _extractTitle(file.name),
        author: '未知作者',
        coverPath: '',
        filePath: destFile.path,
        format: _extractFormat(file.name),
        size: file.size,
        addedAt: DateTime.now(),
        lastReadAt: DateTime.now(),
        totalPages: 0,
        currentPage: 0,
        readingProgress: 0.0,
      );

      // 保存到数据库
      await _dbService.insert('books', book.toMap());
      importedBooks.add(book);
    }

    return importedBooks;
  }

  // 浏览本地文件
  Future<List<Book>> browseFiles() async {
    List<Map<String, dynamic>> maps = await _dbService.query('books');
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  // 删除文件
  Future<void> deleteFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // 从数据库中删除
    await _dbService.delete('books', where: {'filePath': filePath});
  }

  // 移动文件
  Future<void> moveFile(String oldPath, String newPath) async {
    File oldFile = File(oldPath);
    File newFile = File(newPath);

    if (await oldFile.exists()) {
      await oldFile.rename(newFile.path);

      // 更新数据库中的文件路径
      await _dbService.update('books', {'filePath': newPath}, where: {'filePath': oldPath});
    }
  }

  // 重命名文件
  Future<void> renameFile(String oldPath, String newName) async {
    File oldFile = File(oldPath);
    String directory = oldFile.parent.path;
    String newPath = '$directory/$newName';
    File newFile = File(newPath);

    if (await oldFile.exists()) {
      await oldFile.rename(newFile.path);

      // 更新数据库中的文件路径和标题
      await _dbService.update('books', {
        'filePath': newPath,
        'title': _extractTitle(newName),
      }, where: {'filePath': oldPath});
    }
  }

  // 添加 WebDAV 服务器
  Future<void> addWebDAVServer(String name, String url, String username, String password) async {
    WebDAVServer server = WebDAVServer(
      name: name,
      url: url,
      username: username,
      password: password,
      addedAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
    );

    await _dbService.insert('webdav_servers', server.toMap());
  }

  // 删除 WebDAV 服务器
  Future<void> removeWebDAVServer(String serverId) async {
    await _dbService.delete('webdav_servers', where: {'id': serverId});
  }

  // 获取所有 WebDAV 服务器
  Future<List<WebDAVServer>> getWebDAVServers() async {
    List<Map<String, dynamic>> maps = await _dbService.query('webdav_servers');
    return maps.map((map) => WebDAVServer.fromMap(map)).toList();
  }

  // 浏览 WebDAV 服务器文件
  Future<List<Book>> browseWebDAVServer(String serverId, String path) async {
    // 这里需要实现 WebDAV 客户端逻辑
    // 暂时返回空列表
    return [];
  }

  // 获取书籍目录
  Future<Directory> _getBooksDirectory() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    Directory booksDirectory = Directory('${documentsDirectory.path}/books');
    if (!await booksDirectory.exists()) {
      await booksDirectory.create();
    }
    return booksDirectory;
  }

  // 从文件名中提取标题
  String _extractTitle(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }

  // 从文件名中提取格式
  String _extractFormat(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(dotIndex + 1).toLowerCase() : '';
  }

  // 按格式分类文件
  Future<List<Book>> getFilesByCategory(String category) async {
    List<Map<String, dynamic>> maps = await _dbService.query('books', where: {'format': category});
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  // 排序文件
  Future<List<Book>> sortFiles(String sortBy) async {
    List<Map<String, dynamic>> maps;

    switch (sortBy) {
      case 'name':
        maps = await _dbService.query('books');
        maps.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case 'size':
        maps = await _dbService.query('books');
        maps.sort((a, b) => a['size'].compareTo(b['size']));
        break;
      case 'lastRead':
        maps = await _dbService.query('books');
        maps.sort((a, b) => b['lastReadAt'].compareTo(a['lastReadAt']));
        break;
      case 'progress':
        maps = await _dbService.query('books');
        maps.sort((a, b) => b['readingProgress'].compareTo(a['readingProgress']));
        break;
      default:
        maps = await _dbService.query('books');
    }

    return maps.map((map) => Book.fromMap(map)).toList();
  }
}
