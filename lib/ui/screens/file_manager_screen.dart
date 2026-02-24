import 'package:flutter/material.dart';
import 'package:smile_reader/core/models/book.dart';
import 'package:smile_reader/core/models/webdav_server.dart';
import 'package:smile_reader/core/services/file_manager_service.dart';
import 'package:smile_reader/ui/components/book_card.dart';
import 'package:smile_reader/ui/screens/reader_screen.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  final FileManagerService _fileManagerService = FileManagerService();
  List<Book> _books = [];
  List<WebDAVServer> _webdavServers = [];
  bool _isLoading = true;
  String _viewMode = 'grid'; // grid or list
  String _sortBy = 'lastRead';

  @override
  void initState() {
    super.initState();
    _loadFiles();
    _loadWebDAVServers();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _books = await _fileManagerService.sortFiles(_sortBy);
    } catch (e) {
      print('Error loading files: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWebDAVServers() async {
    try {
      _webdavServers = await _fileManagerService.getWebDAVServers();
    } catch (e) {
      print('Error loading WebDAV servers: $e');
    }
  }

  void _refreshFiles() {
    _loadFiles();
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(bookId: book.id),
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
    });
  }

  void _changeSortBy(String value) {
    setState(() {
      _sortBy = value;
    });
    _loadFiles();
  }

  void _showAddWebDAVServerDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加 WebDAV 服务器'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '服务器名称'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: '服务器 URL'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: '用户名'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _fileManagerService.addWebDAVServer(
                nameController.text,
                urlController.text,
                usernameController.text,
                passwordController.text,
              );
              Navigator.pop(context);
              _loadWebDAVServers();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件管理'),
        actions: [
          IconButton(
            onPressed: () async {
              await _fileManagerService.importFiles();
              _refreshFiles();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _toggleViewMode,
            icon: Icon(_viewMode == 'grid' ? Icons.list : Icons.grid_view),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshFiles(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 排序和筛选选项
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: _sortBy,
                          onChanged: (value) => _changeSortBy(value!),
                          items: [
                            DropdownMenuItem(value: 'name', child: const Text('名称')),
                            DropdownMenuItem(value: 'size', child: const Text('大小')),
                            DropdownMenuItem(value: 'lastRead', child: const Text('最近阅读')),
                            DropdownMenuItem(value: 'progress', child: const Text('阅读进度')),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _showAddWebDAVServerDialog,
                          child: const Text('添加 WebDAV'),
                        ),
                      ],
                    ),
                  ),
                  
                  // WebDAV 服务器列表
                  if (_webdavServers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('WebDAV 服务器'),
                          const SizedBox(height: 8),
                          Container(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _webdavServers.length,
                              itemBuilder: (context, index) {
                                WebDAVServer server = _webdavServers[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(server.name),
                                        Text(server.url, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // 书籍列表
                  Expanded(
                    child: _viewMode == 'grid'
                        ? GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _books.length,
                            itemBuilder: (context, index) {
                              return BookCard(
                                book: _books[index],
                                onTap: () => _openBook(_books[index]),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _books.length,
                            itemBuilder: (context, index) {
                              Book book = _books[index];
                              return ListTile(
                                leading: Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      book.title.isNotEmpty ? book.title[0] : '?',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(book.title),
                                subtitle: Text('${book.author} • ${book.format.toUpperCase()}'),
                                trailing: Text('${(book.readingProgress * 100).toInt()}%'),
                                onTap: () => _openBook(book),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
