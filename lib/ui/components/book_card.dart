import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smile_reader/core/models/book.dart';
import 'package:smile_reader/core/utils/file_utils.dart';
import 'package:smile_reader/ui/theme/theme.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final bool showProgress;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                image: book.coverPath.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(book.coverPath)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.coverPath.isEmpty
                  ? Center(
                      child: Text(
                        book.title.isNotEmpty ? book.title[0] : '?',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            
            // 书籍标题
            Text(
              book.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 作者
            Text(
              book.author,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 格式和大小
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  book.format.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                ),
                Text(
                  FileUtils.formatFileSize(book.size),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            
            // 阅读进度
            if (showProgress)
              Column(
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: book.readingProgress,
                    backgroundColor: AppTheme.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(book.readingProgress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
