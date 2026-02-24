import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smile_reader/core/models/book.dart';
import 'package:smile_reader/core/services/file_manager_service.dart';
import 'package:smile_reader/ui/components/book_card.dart';
import 'package:smile_reader/ui/screens/reader_screen.dart';

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  final FileManagerService _fileManagerService = FileManagerService();
  List<Book> _books = [];
  List<Book> _recentBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _books = await _fileManagerService.browseFiles();
      // 按最后阅读时间排序，获取最近阅读的书籍
      _recentBooks = [..._books]
        ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt))
        ..take(4).toList();
    } catch (e) {
      print('Error loading books: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshBooks() {
    _loadBooks();
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(bookId: book.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          IconButton(
            onPressed: () async {
              await _fileManagerService.importFiles();
              _refreshBooks();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshBooks(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 最近阅读
                    if (_recentBooks.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '最近阅读',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _recentBooks.length,
                            itemBuilder: (context, index) {
                              return BookCard(
                                book: _recentBooks[index],
                                onTap: () => _openBook(_recentBooks[index]),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    
                    // 我的书架
                    Text(
                      '我的书架',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (_books.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '书架为空，点击右上角添加书籍',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
