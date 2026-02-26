import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:smile_reader/core/models/book.dart';
import 'package:smile_reader/core/services/reader_service.dart';
import 'package:smile_reader/ui/theme/theme.dart';

class ReaderScreen extends StatefulWidget {
  final String bookId;

  const ReaderScreen({super.key, required this.bookId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ReaderService _readerService = ReaderService();
  String _content = '';
  int _currentPage = 0;
  double _readingProgress = 0.0;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _showControls = false;
  Book? _book;
  EpubController? _epubController;
  
  // 阅读设置
  double _fontSize = 16.0;
  double _lineSpacing = 1.5;
  double _margin = 24.0; // 边距设置
  String _theme = 'light';
  String _pageLayout = 'scroll';
  
  // 翻页状态
  bool _isDragging = false;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
      _content = '加载中...';
    });

    try {
      print('Loading book with id: ${widget.bookId}');
      
      // 获取书籍信息
      _book = await _readerService.openBook(widget.bookId);
      print('Book loaded: ${_book!.title}, format: ${_book!.format}');
      
      // 尝试获取阅读进度
      try {
        var progress = await _readerService.getProgress(widget.bookId);
        _currentPage = progress['currentPage'] ?? 0;
        _readingProgress = progress['readingProgress'] ?? 0.0;
        _totalPages = progress['totalPages'] ?? 10;
        print('Progress: page $_currentPage, progress $_readingProgress, total $_totalPages');
      } catch (e) {
        print('Error getting progress: $e');
        // 忽略进度获取错误，使用默认值
        _currentPage = 0;
        _readingProgress = 0.0;
        _totalPages = 10;
      }
      
      // 尝试获取阅读设置
      try {
        var settings = await _readerService.getReadingSettings(widget.bookId);
        // 确保所有数值都是double类型
        _fontSize = double.tryParse((settings['fontSize'] ?? 16.0).toString()) ?? 16.0;
        _lineSpacing = double.tryParse((settings['lineSpacing'] ?? 1.5).toString()) ?? 1.5;
        _margin = double.tryParse((settings['margin'] ?? 24.0).toString()) ?? 24.0;
        _theme = settings['theme'] ?? 'light';
        _pageLayout = (settings['pageLayout'] ?? 'scroll') == 'vertical' ? 'scroll' : (settings['pageLayout'] ?? 'scroll');
        print('Settings loaded: fontSize $_fontSize, lineSpacing $_lineSpacing, margin $_margin, theme $_theme, layout $_pageLayout');
      } catch (e) {
        print('Error getting settings: $e');
        // 使用默认设置
        _fontSize = 16.0;
        _lineSpacing = 1.5;
        _margin = 24.0;
        _theme = 'light';
        _pageLayout = 'scroll';
      }
      
      // 检查是否是 EPUB 文件
      if (_book!.format.toLowerCase() == 'epub') {
        print('Loading EPUB file: ${_book!.filePath}');
        try {
          // 初始化 EPUB 控制器，使用 Future<EpubBook> 类型
          _epubController = EpubController(
            document: EpubDocument.openFile(File(_book!.filePath)),
          );
          print('EPUB controller initialized successfully');
        } catch (e) {
          print('Error initializing EPUB controller: $e');
          // 处理 EPUB 解析错误
          if (e.toString().contains('TOC item, not found in EPUB manifest')) {
            _content = '\nEPUB 文件解析错误：目录项在清单中未找到\n\n这是EPUB文件本身的格式问题，不是应用程序的问题。\n\n可能的原因：\n1. EPUB文件结构损坏\n2. 目录引用了不存在的内容\n3. 文件下载不完整\n\n解决方案：\n1. 尝试使用其他EPUB阅读器打开\n2. 重新下载该EPUB文件\n3. 使用EPUB修复工具修复文件\n';
          } else if (e.toString().contains('Failed to decode data using encoding')) {
            _content = 'EPUB 文件编码错误：无法使用指定的编码解码数据。';
          } else {
            _content = 'EPUB 控制器初始化失败: $e';
          }
          // 重置为文本阅读器模式以显示错误信息
          _book = null;
        }
      } else {
        // 获取文本内容
        _content = await _readerService.getContent(widget.bookId, _currentPage);
        print('Content loaded, length: ${_content.length}');
        if (_content.isEmpty) {
          _content = '书籍内容为空';
        }
      }
    } catch (e) {
      print('Error loading book: $e');
      setState(() {
        _content = '加载失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _saveProgress() {
    _readerService.saveProgress(widget.bookId, _currentPage, _readingProgress);
  }

  void _nextPage() async {
    setState(() {
      _currentPage++;
      // 暂时使用一个较大的值作为总页数，确保翻页功能可以正常工作
      // 实际总页数会在getContent方法中更新
      _totalPages = _totalPages > 1 ? _totalPages : 10;
      _readingProgress = (_currentPage / _totalPages).clamp(0.0, 1.0);
    });
    
    // 加载新内容
    if (_book != null && _book!.format.toLowerCase() != 'epub') {
      try {
        String newContent = await _readerService.getContent(widget.bookId, _currentPage);
        setState(() {
          _content = newContent;
        });
      } catch (e) {
        print('Error loading content: $e');
      }
    }
    
    _saveProgress();
  }

  void _prevPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        // 暂时使用一个较大的值作为总页数，确保翻页功能可以正常工作
        // 实际总页数会在getContent方法中更新
        _totalPages = _totalPages > 1 ? _totalPages : 10;
        _readingProgress = (_currentPage / _totalPages).clamp(0.0, 1.0);
      });
      
      // 加载新内容
      if (_book != null && _book!.format.toLowerCase() != 'epub') {
        try {
          String newContent = await _readerService.getContent(widget.bookId, _currentPage);
          setState(() {
            _content = newContent;
          });
        } catch (e) {
          print('Error loading content: $e');
        }
      }
      
      _saveProgress();
    }
  }

  @override
  void dispose() {
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book?.title ?? '阅读器'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book),
            onPressed: () {
              // 显示目录
              _showTableOfContents();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 显示搜索
              _showSearch();
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 显示阅读设置
              _showReadingSettings();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _book == null
              ? Center(child: Text(_content))
              : _book!.format.toLowerCase() == 'epub'
                  ? _buildEpubReader()
                  : _buildTextReader(),
    );
  }

  // 显示目录
  void _showTableOfContents() async {
    try {
      var toc = await _readerService.getTableOfContents(widget.bookId);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('目录'),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: toc.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(toc[index]['title'] ?? '未知章节'),
                    onTap: () {
                      // 导航到对应章节
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('关闭'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing TOC: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('错误'),
            content: Text('获取目录失败: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('确定'),
              ),
            ],
          );
        },
      );
    }
  }

  // 显示搜索
  void _showSearch() {
    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('搜索'),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: '搜索内容',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            if (searchController.text.isEmpty) return;
                            
                            setState(() {
                              isSearching = true;
                            });
                            
                            try {
                              var results = await _readerService.searchContent(
                                widget.bookId,
                                searchController.text
                              );
                              setState(() {
                                searchResults = results;
                                isSearching = false;
                              });
                            } catch (e) {
                              print('Error searching: $e');
                              setState(() {
                                isSearching = false;
                              });
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('错误'),
                                    content: Text('搜索失败: $e'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('确定'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    if (isSearching)
                      Center(child: CircularProgressIndicator())
                    else if (searchResults.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            var result = searchResults[index];
                            return ListTile(
                              title: Text(result['content'] ?? ''),
                              subtitle: Text('第 ${result['page'] ?? 0} 页，第 ${result['line'] ?? 0} 行'),
                              onTap: () {
                                // 导航到搜索结果位置
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      )
                    else if (searchController.text.isNotEmpty)
                      Center(child: Text('无搜索结果')),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('关闭'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 显示阅读设置
  void _showReadingSettings() {
    double tempFontSize = _fontSize;
    double tempLineSpacing = _lineSpacing;
    double tempMargin = _margin;
    String tempTheme = _theme;
    String tempPageLayout = _pageLayout;
    
    // 确保默认使用滚动模式
    if (tempPageLayout == 'vertical') {
      tempPageLayout = 'scroll';
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '阅读设置',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    // 字体大小
                    Text('字体大小'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.text_fields),
                          onPressed: () {
                            if (tempFontSize > 12) {
                              setState(() {
                                tempFontSize -= 2;
                              });
                            }
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: tempFontSize,
                            min: 12,
                            max: 24,
                            divisions: 6,
                            onChanged: (value) {
                              setState(() {
                                tempFontSize = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.text_fields),
                          onPressed: () {
                            if (tempFontSize < 24) {
                              setState(() {
                                tempFontSize += 2;
                              });
                            }
                          },
                        ),
                        Text('${tempFontSize.toInt()}px'),
                      ],
                    ),
                    
                    // 行间距
                    SizedBox(height: 16),
                    Text('行间距'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.format_line_spacing),
                          onPressed: () {
                            if (tempLineSpacing > 1.0) {
                              setState(() {
                                tempLineSpacing -= 0.2;
                              });
                            }
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: tempLineSpacing,
                            min: 1.0,
                            max: 2.0,
                            divisions: 5,
                            onChanged: (value) {
                              setState(() {
                                tempLineSpacing = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.format_line_spacing),
                          onPressed: () {
                            if (tempLineSpacing < 2.0) {
                              setState(() {
                                tempLineSpacing += 0.2;
                              });
                            }
                          },
                        ),
                        Text('${tempLineSpacing.toStringAsFixed(1)}'),
                      ],
                    ),
                    
                    // 边距
                    SizedBox(height: 16),
                    Text('边距'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.border_outer),
                          onPressed: () {
                            if (tempMargin > 8) {
                              setState(() {
                                tempMargin -= 4;
                              });
                            }
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: tempMargin,
                            min: 8,
                            max: 40,
                            divisions: 8,
                            onChanged: (value) {
                              setState(() {
                                tempMargin = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.border_outer),
                          onPressed: () {
                            if (tempMargin < 40) {
                              setState(() {
                                tempMargin += 4;
                              });
                            }
                          },
                        ),
                        Text('${tempMargin.toInt()}px'),
                      ],
                    ),
                    
                    // 主题
                    SizedBox(height: 16),
                    Text('主题'),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempTheme = 'light';
                            });
                          },
                          child: Text('浅色'),
                          style: tempTheme == 'light' 
                              ? ElevatedButton.styleFrom(backgroundColor: Colors.blue) 
                              : ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempTheme = 'dark';
                            });
                          },
                          child: Text('深色'),
                          style: tempTheme == 'dark' 
                              ? ElevatedButton.styleFrom(backgroundColor: Colors.blue) 
                              : ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempTheme = 'night';
                            });
                          },
                          child: Text('夜间'),
                          style: tempTheme == 'night' 
                              ? ElevatedButton.styleFrom(backgroundColor: Colors.blue) 
                              : ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                      ],
                    ),
                    
                    // 翻页模式
                    SizedBox(height: 16),
                    Text('翻页模式'),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempPageLayout = 'scroll';
                            });
                          },
                          child: Text('滚动'),
                          style: tempPageLayout == 'scroll' 
                              ? ElevatedButton.styleFrom(backgroundColor: Colors.blue) 
                              : ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempPageLayout = 'simulation';
                            });
                          },
                          child: Text('仿真'),
                          style: tempPageLayout == 'simulation' 
                              ? ElevatedButton.styleFrom(backgroundColor: Colors.blue) 
                              : ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempPageLayout = 'cover';
                            });
                          },
                          child: Text('覆盖'),
                          style: tempPageLayout == 'cover' 
                              ? ElevatedButton.styleFrom(backgroundColor: Colors.blue) 
                              : ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                        ),
                      ],
                    ),
                    
                    // 保存按钮
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // 保存设置
                          _saveReadingSettings(tempFontSize, tempLineSpacing, tempMargin, tempTheme, tempPageLayout);
                          Navigator.pop(context);
                        },
                        child: Text('保存设置'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 24), // 添加额外的底部空间
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  // 保存阅读设置
  void _saveReadingSettings(double fontSize, double lineSpacing, double margin, String theme, String pageLayout) async {
    try {
      setState(() {
        _fontSize = fontSize;
        _lineSpacing = lineSpacing;
        _margin = margin;
        _theme = theme;
        _pageLayout = pageLayout;
      });
      
      // 保存到服务层
      await _readerService.setReadingSettings(widget.bookId, {
        'fontSize': fontSize,
        'lineSpacing': lineSpacing,
        'margin': margin,
        'theme': theme,
        'pageLayout': pageLayout,
      });
      
      print('Settings saved: fontSize $fontSize, lineSpacing $lineSpacing, margin $margin, theme $theme, layout $pageLayout');
    } catch (e) {
      print('Error saving settings: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('错误'),
            content: Text('保存设置失败: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('确定'),
              ),
            ],
          );
        },
      );
    }
  }

  // 构建 EPUB 阅读器
  Widget _buildEpubReader() {
    if (_epubController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'EPUB 控制器初始化失败',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('返回书架'),
              ),
            ],
          ),
        ),
      );
    }

    // 根据主题设置颜色
    Color backgroundColor;
    Color textColor;
    
    switch (_theme) {
      case 'dark':
        backgroundColor = Colors.grey[900]!;
        textColor = Colors.grey[200]!;
        break;
      case 'night':
        backgroundColor = Colors.black;
        textColor = Colors.grey[300]!;
        break;
      default: // light
        backgroundColor = Colors.white;
        textColor = Colors.black;
        break;
    }
    
    // 创建 EPUB 内容
    Widget epubContent = Container(
      color: backgroundColor,
      padding: EdgeInsets.all(_margin),
      child: EpubView(
        controller: _epubController!,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: DefaultBuilderOptions(
            textStyle: TextStyle(
              fontSize: _fontSize,
              height: _lineSpacing,
              color: textColor,
            ),
            paragraphPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          chapterDividerBuilder: (_) => const Divider(),
        ),
      ),
    );
    
    // 根据翻页模式包装 EPUB 内容
    switch (_pageLayout) {
      case 'simulation':
        return _buildEpubPageTurnWrapper(epubContent, backgroundColor, textColor, true);
      case 'cover':
        return _buildEpubPageTurnWrapper(epubContent, backgroundColor, textColor, false);
      case 'scroll':
      default:
        return epubContent;
    }
  }
  
  // 构建 EPUB 翻页模式包装器
  Widget _buildEpubPageTurnWrapper(Widget epubContent, Color backgroundColor, Color textColor, bool isSimulation) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
          _startPosition = details.localPosition;
          _currentPosition = details.localPosition;
          _dragOffset = 0.0;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _currentPosition = details.localPosition;
          _dragOffset = details.localPosition.dx - _startPosition.dx;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
          double dx = _currentPosition.dx - _startPosition.dx;
          // 这里我们不调用EpubController的方法，而是通过手势来模拟翻页效果
          // 实际的页面导航将由EpubView的默认滚动行为处理
          _startPosition = Offset.zero;
          _currentPosition = Offset.zero;
          _dragOffset = 0.0;
        });
      },
      child: Stack(
        children: [
          // EPUB 内容
          epubContent,
          
          // 翻页效果
          if (_isDragging) _buildEpubPageTurnEffect(backgroundColor, textColor, isSimulation),
        ],
      ),
    );
  }
  
  // 构建 EPUB 翻页效果
  Widget _buildEpubPageTurnEffect(Color backgroundColor, Color textColor, bool isSimulation) {
    double dx = _currentPosition.dx - _startPosition.dx;
    double dy = _currentPosition.dy - _startPosition.dy;
    
    // 只处理水平滑动
    if (dx.abs() < dy.abs()) {
      return Container();
    }
    
    bool isNextPage = dx < 0;
    double progress = (dx.abs() / MediaQuery.of(context).size.width).clamp(0.0, 1.0);
    
    if (isSimulation) {
      // 仿真翻页效果
      double angle = isNextPage ? -progress * 1.0 : progress * 1.0;
      double translateY = (dy / MediaQuery.of(context).size.height) * 50;
      double shadowOpacity = progress * 0.5;
      
      return Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: Container(
          color: backgroundColor,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle)
              ..translate(isNextPage ? dx * 0.8 : dx * 0.8, translateY, -progress * 100)
              ..scale(1.0 - progress * 0.05),
            origin: isNextPage 
              ? Offset(0, MediaQuery.of(context).size.height / 2)
              : Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: backgroundColor,
              child: Center(
                child: Text(
                  isNextPage ? '下一页' : '上一页',
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: textColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(shadowOpacity),
                        offset: Offset(3, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 覆盖翻页效果
      return Positioned(
        left: _dragOffset < 0 ? _dragOffset : 0,
        top: 0,
        right: _dragOffset < 0 ? 0 : -_dragOffset,
        bottom: 0,
        child: Container(
          color: backgroundColor,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 50),
            transform: Matrix4.identity()
              ..translate(_dragOffset < 0 ? _dragOffset : 0, 0, (_dragOffset.abs() / MediaQuery.of(context).size.width) * -50)
              ..scale(1.0 + (_dragOffset.abs() / MediaQuery.of(context).size.width) * 0.1),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: backgroundColor,
              child: Center(
                child: Text(
                  isNextPage ? '下一页' : '上一页',
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: textColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity((dx.abs() / MediaQuery.of(context).size.width) * 0.4),
                        offset: Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  // 构建文本阅读器
  Widget _buildTextReader() {
    // 根据主题设置颜色
    Color backgroundColor;
    Color textColor;
    
    switch (_theme) {
      case 'dark':
        backgroundColor = Colors.grey[900]!;
        textColor = Colors.grey[200]!;
        break;
      case 'night':
        backgroundColor = Colors.black;
        textColor = Colors.grey[300]!;
        break;
      default: // light
        backgroundColor = Colors.white;
        textColor = Colors.black;
        break;
    }
    
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // 阅读内容
          Container(
            color: backgroundColor,
            child: _buildPageTurner(backgroundColor, textColor),
          ),
          
          // 顶部控制栏
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          _saveProgress();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        '阅读器',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // 更多选项
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // 底部控制栏
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // 阅读进度条
                      LinearProgressIndicator(
                        value: _readingProgress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                      const SizedBox(height: 8),
                      
                      // 页码和控制按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_currentPage / $_totalPages',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _prevPage,
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                              ),
                              IconButton(
                                onPressed: _nextPage,
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            '${(_readingProgress * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建翻页器
  Widget _buildPageTurner(Color backgroundColor, Color textColor) {
    switch (_pageLayout) {
      case 'simulation':
        return _buildSimulationPageTurner(backgroundColor, textColor);
      case 'cover':
        return _buildCoverPageTurner(backgroundColor, textColor);
      case 'scroll':
        return _buildScrollPageTurner(backgroundColor, textColor);
      default:
        return _buildVerticalPageTurner(backgroundColor, textColor);
    }
  }
  
  // 构建仿真翻页
  Widget _buildSimulationPageTurner(Color backgroundColor, Color textColor) {
    return PageTurnWidget(
      backgroundColor: backgroundColor,
      textColor: textColor,
      content: _content,
      currentPage: _currentPage,
      onPageChanged: (page) async {
        setState(() {
          _currentPage = page;
          _readingProgress = (_currentPage / _totalPages).clamp(0.0, 1.0);
        });
        
        // 加载新内容
        if (_book != null && _book!.format.toLowerCase() != 'epub') {
          try {
            String newContent = await _readerService.getContent(widget.bookId, _currentPage);
            setState(() {
              _content = newContent;
            });
          } catch (e) {
            print('Error loading content: $e');
          }
        }
        
        _saveProgress();
      },
      fontSize: _fontSize,
      lineSpacing: _lineSpacing,
      margin: _margin,
    );
  }
  
  // 构建覆盖翻页
  Widget _buildCoverPageTurner(Color backgroundColor, Color textColor) {
    return CoverPageTurnWidget(
      backgroundColor: backgroundColor,
      textColor: textColor,
      content: _content,
      currentPage: _currentPage,
      onPageChanged: (page) async {
        setState(() {
          _currentPage = page;
          _readingProgress = (_currentPage / _totalPages).clamp(0.0, 1.0);
        });
        
        // 加载新内容
        if (_book != null && _book!.format.toLowerCase() != 'epub') {
          try {
            String newContent = await _readerService.getContent(widget.bookId, _currentPage);
            setState(() {
              _content = newContent;
            });
          } catch (e) {
            print('Error loading content: $e');
          }
        }
        
        _saveProgress();
      },
      fontSize: _fontSize,
      lineSpacing: _lineSpacing,
      margin: _margin,
    );
  }
  
  // 构建滚动翻页
  Widget _buildScrollPageTurner(Color backgroundColor, Color textColor) {
    final ScrollController scrollController = ScrollController();
    
    scrollController.addListener(() {
      // 计算滚动进度并更新阅读进度
      if (scrollController.hasClients) {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double currentScrollPosition = scrollController.position.pixels;
        double scrollProgress = maxScrollExtent > 0 ? currentScrollPosition / maxScrollExtent : 0.0;
        
        setState(() {
          _readingProgress = scrollProgress;
        });
        
        _saveProgress();
      }
    });
    
    return Container(
      padding: EdgeInsets.all(_margin),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Text(
          _content,
          style: TextStyle(
            fontSize: _fontSize,
            height: _lineSpacing,
            color: textColor,
          ),
        ),
      ),
    );
  }
  
  // 构建垂直翻页
  Widget _buildVerticalPageTurner(Color backgroundColor, Color textColor) {
    return GestureDetector(
      onTapUp: (details) {
        // 点击左侧区域上一页，右侧区域下一页
        if (details.localPosition.dx < MediaQuery.of(context).size.width / 3) {
          _prevPage();
        } else if (details.localPosition.dx > MediaQuery.of(context).size.width * 2 / 3) {
          _nextPage();
        }
      },
      child: Container(
        padding: EdgeInsets.all(_margin),
        child: Text(
          _content,
          style: TextStyle(
            fontSize: _fontSize,
            height: _lineSpacing,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// 仿真翻页组件 - 参考anx-reader实现
class PageTurnWidget extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final String content;
  final int currentPage;
  final Function(int) onPageChanged;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  
  const PageTurnWidget({
    Key? key,
    required this.backgroundColor,
    required this.textColor,
    required this.content,
    required this.currentPage,
    required this.onPageChanged,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
  }) : super(key: key);
  
  @override
  _PageTurnWidgetState createState() => _PageTurnWidgetState();
}

class _PageTurnWidgetState extends State<PageTurnWidget> {
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
          _startPosition = details.localPosition;
          _currentPosition = details.localPosition;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _currentPosition = details.localPosition;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
          double dx = _currentPosition.dx - _startPosition.dx;
          if (dx > 50) {
            // 向右滑动，上一页
            widget.onPageChanged(widget.currentPage - 1);
          } else if (dx < -50) {
            // 向左滑动，下一页
            widget.onPageChanged(widget.currentPage + 1);
          }
          _startPosition = Offset.zero;
          _currentPosition = Offset.zero;
        });
      },
      child: Stack(
        children: [
          // 主页面
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: widget.backgroundColor,
            padding: EdgeInsets.all(widget.margin),
            child: Text(
              widget.content,
              style: TextStyle(
                fontSize: widget.fontSize,
                height: widget.lineSpacing,
                color: widget.textColor,
              ),
            ),
          ),
          
          // 翻页效果
          if (_isDragging) _buildPageTurnEffect(),
        ],
      ),
    );
  }
  
  Widget _buildPageTurnEffect() {
    double dx = _currentPosition.dx - _startPosition.dx;
    double dy = _currentPosition.dy - _startPosition.dy;
    
    // 只处理水平滑动
    if (dx.abs() < dy.abs()) {
      return Container();
    }
    
    bool isNextPage = dx < 0;
    double progress = (dx.abs() / MediaQuery.of(context).size.width).clamp(0.0, 1.0);
    
    // 计算翻页角度和位移
    double angle = isNextPage ? -progress * 1.0 : progress * 1.0;
    double translateY = (dy / MediaQuery.of(context).size.height) * 50;
    
    // 计算阴影强度
    double shadowOpacity = progress * 0.5;
    
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: widget.backgroundColor,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle)
            ..translate(isNextPage ? dx * 0.8 : dx * 0.8, translateY, -progress * 100)
            ..scale(1.0 - progress * 0.05),
          origin: isNextPage 
            ? Offset(0, MediaQuery.of(context).size.height / 2)
            : Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: widget.backgroundColor,
            padding: EdgeInsets.all(widget.margin),
            child: Text(
              widget.content,
              style: TextStyle(
                fontSize: widget.fontSize,
                height: widget.lineSpacing,
                color: widget.textColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(shadowOpacity),
                    offset: Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 覆盖翻页组件 - 参考anx-reader实现
class CoverPageTurnWidget extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final String content;
  final int currentPage;
  final Function(int) onPageChanged;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  
  const CoverPageTurnWidget({
    Key? key,
    required this.backgroundColor,
    required this.textColor,
    required this.content,
    required this.currentPage,
    required this.onPageChanged,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
  }) : super(key: key);
  
  @override
  _CoverPageTurnWidgetState createState() => _CoverPageTurnWidgetState();
}

class _CoverPageTurnWidgetState extends State<CoverPageTurnWidget> {
  double _dragOffset = 0.0;
  bool _isDragging = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
          _dragOffset = 0.0;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
          if (_dragOffset > 50) {
            // 向右滑动，上一页
            widget.onPageChanged(widget.currentPage - 1);
          } else if (_dragOffset < -50) {
            // 向左滑动，下一页
            widget.onPageChanged(widget.currentPage + 1);
          }
          _dragOffset = 0.0;
        });
      },
      child: Stack(
        children: [
          // 主页面
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: widget.backgroundColor,
            padding: EdgeInsets.all(widget.margin),
            child: Text(
              widget.content,
              style: TextStyle(
                fontSize: widget.fontSize,
                height: widget.lineSpacing,
                color: widget.textColor,
              ),
            ),
          ),
          
          // 覆盖翻页效果
          if (_isDragging)
            Positioned(
              left: _dragOffset < 0 ? _dragOffset : 0,
              top: 0,
              right: _dragOffset < 0 ? 0 : -_dragOffset,
              bottom: 0,
              child: Container(
                color: widget.backgroundColor,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 50),
                  transform: Matrix4.identity()
                    ..translate(_dragOffset < 0 ? _dragOffset : 0, 0, (_dragOffset.abs() / MediaQuery.of(context).size.width) * -50)
                    ..scale(1.0 + (_dragOffset.abs() / MediaQuery.of(context).size.width) * 0.1),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: widget.backgroundColor,
                    padding: EdgeInsets.all(widget.margin),
                    child: Text(
                      widget.content,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        height: widget.lineSpacing,
                        color: widget.textColor,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity((_dragOffset.abs() / MediaQuery.of(context).size.width) * 0.4),
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
