import 'dart:developer';

import 'package:ct484_project/services/book_services.dart';
import 'package:flutter/foundation.dart';

import '../../models/book.dart';

class BooksManager with ChangeNotifier {
  final BookService _booksService = BookService();
  List<Book> _books = [];

  int get count {
    return _books.length;
  }

  List<Book> get books {
    return [..._books];
  }

  List<Book> get activeBooks {
    // Lọc sách chưa bị xóa (deleted = 0)
    return _books.where((book) => book.deleted == 0).toList();
  }

  Book? findById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (error) {
      return null;
    }
  }

  Book? searchBooks(String id) {
    try {
      return _books.firstWhere((book) => id != '' && book.id!.contains(id));
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> addBook(Book book) async {
    final newBook = await _booksService.addBook(book);
    if (newBook != null) {
      _books.add(newBook);
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book) async {
    final index = _books.indexWhere((item) => item.id == book.id);
    if (index >= 0) {
      final updatedBook = await _booksService.updateBook(book);
      if (updatedBook != null) {
        _books[index] = updatedBook;
        notifyListeners();
      }
    }
  }

  Future<void> deleteBook(String id) async {
    final index = _books.indexWhere((item) => item.id == id);
    if (index >= 0 && await _booksService.deleteBook(id)) {
      _books.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> fetchBooks() async {
    _books = await _booksService.fetchBooks();
    notifyListeners();
  }

  Future<void> fetchUserBooks() async {
    _books = await _booksService.fetchBooks(filteredByUser: true);
    notifyListeners();
  }

  // Thêm phương thức fetchBookById để tải chi tiết sách từ backend nếu cần
  Future<Book?> fetchBookById(String id) async {
    // Kiểm tra sách có sẵn trong danh sách không
    var existingBook = findById(id);
    if (existingBook != null) {
      return existingBook;
    }

    // Nếu sách chưa có, lấy từ backend
    final fetchedBook = await _booksService.fetchBookById(id);
    if (fetchedBook != null) {
      _books.add(fetchedBook);
      notifyListeners();
    }
    return fetchedBook;
  }
}
