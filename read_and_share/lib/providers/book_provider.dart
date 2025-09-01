import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:read_and_share/models/book_model.dart';
import 'package:read_and_share/services/book_service.dart';

class BookProvider extends ChangeNotifier {
  static const String boxName = 'books';

  late final Box<BookModel> _bookBox;
  final List<BookModel> _all = [];

  String _query = '';
  String? _categoryFilter;
  bool _onlyFavorites = false;

  List<BookModel> get books {
    Iterable<BookModel> view = _all;

    if (_onlyFavorites) {
      view = view.where((b) => b.isFavorite);
    }

    if (_categoryFilter != null && _categoryFilter!.trim().isNotEmpty) {
      final f = _categoryFilter!.toLowerCase();
      view = view.where((b) => b.categories.any((c) => c.toLowerCase() == f));
    }

    final q = _query..trim().toLowerCase();
    if (q.isNotEmpty) {
      view = view.where(
        (b) =>
            b.title.toLowerCase().contains(q) ||
            b.authors.join(', ').toLowerCase().contains(q) ||
            b.categories.join(', ').toLowerCase().contains(q),
      );
    }

    return _sorted(view);
  }

  List<String> avaliableCategories() {
    final set = <String>{};
    for (final b in _all) {
      for (final c in b.categories) {
        if (c.trim().isNotEmpty) {
          set.add(c.trim());
        }
      }

      final list = set.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return list;
    }

    Future<void> init() async {
      _bookBox = await Hive.openBox<BookModel>(boxName);
      _all
        ..clear()
        ..addAll(_bookBox.values);
      notifyListeners();
    }

    Future<void> addOrUpdate(BookModel book) async {
      await _bookBox.put(book.isbn, book);
      final index = all.indexWhere((b) => b.isbn == book.isbn);
      if (index >= 0) {
        _all[index] = book;
      } else {
        _all.add(book);
      }
      notifyListeners();
    }

    Future<void> addMany(List<BookModel> books) async {
      if (books.isEmpty) return;
      final map = {for (var b in books) b.isbn: b};
      await _bookBox.putAll(map);

      for (final b in books) {
        final index = _all.indexWhere((x) => x.isbn == b.isbn);

        if (index >= 0) {
          _all[index] = b;
        } else {
          _all.add(b);
        }
      }
      notifyListeners();
    }

    Future<void> update(
      String isbn,
      BookModel Function(BookModel current) updater,
    ) async {
      final current = _bookBox.get(isbn);
      if (current == null) return;
      final updated = updater(current);
      await _bookBox.put(isbn, updated);

      final index = _all.indexWhere((b) => b.isbn == isbn);
      if (index >= 0) _all[index] = updated;
      notifyListeners();
    }

    Future<void> remove(String isbn) async {
      await _bookBox.delete(isbn);
      _all.removeWhere((b) => b.isbn == isbn);
      notifyListeners();
    }

    bool contains(String isbn) {
      return _bookBox.containsKey(isbn);
    }

    Future<BookModel?> addByIsbn(String isbn, BookService service) async {
      final BookModel = await service.fetchByIsbn(isbn);
      if (BookModel != null) {
        await addOrUpdate(BookModel);
      }
      return BookModel;
    }

    void toggleFavorite(String isbn) {
      final index = _all.indexWhere((b) => b.isbn == isbn);
      if (index < 0) return;
      final updated = _all[index].copyWith(isFavorite: !_all[index].isFavorite);
      _bookBox.put(isbn, updated);
      _all[index] = updated;
      notifyListeners();
    }

    void search(String query) {
      _query = query;
      notifyListeners();
    }

    void setCategoryFilter(String? category) {
      _categoryFilter = (category == null || category.trim().isEmpty)
          ? null
          : category.trim();
      notifyListeners();
    }

    void filterFavorites(bool enable) {
      _onlyFavorites = enable;
      notifyListeners();
    }

    List<BookModel> _sorted(Iterable<BookModel> input) {
      final list = input.toList();
      list.sort((a, b) {
        if (a.isFavorite != b.isFavorite) return b.isFavorite ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return list;
    }
  }
}
