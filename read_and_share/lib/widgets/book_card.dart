import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_and_share/models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel bookModel;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDelete;

  const BookCard({
    super.key,
    required this.bookModel,
    this.onTap,
    this.onToggleFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: bookModel.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: bookModel.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (c, _) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (c, _, _) => const Icon(Icons.image),
                      )
                    : const ColoredBox(
                        color: Colors.black12,
                        child: Center(child: Icon(Icons.menu_book_outlined)),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookModel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bookModel.authors.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (bookModel.publishedDate != null)
                            Text(
                              bookModel.publishedDate!,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          const Spacer(),
                          IconButton(
                            onPressed: onToggleFavorite,
                            icon: Icon(
                              bookModel.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            tooltip: 'Favorite',
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
