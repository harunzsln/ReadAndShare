import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_and_share/models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (book.thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: book.thumbnail!,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Author: ${book.authors.join(', ')}'),
          const SizedBox(height: 4),
          Text('ISBN: ${book.isbn}'),
          if (book.publishedDate != null) ...[
            const SizedBox(height: 4),
            Text('Publish: ${book.publishedDate}'),
          ],
          if (book.categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: book.categories
                  .map((c) => Chip(label: Text(c)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            book.description ?? 'Description can not found.',
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
