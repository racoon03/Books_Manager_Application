import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'books_manager.dart';

class DeleteBookScreen extends StatefulWidget {
  const DeleteBookScreen({super.key});
  static const routeName = '/books/delete';

  @override
  State<DeleteBookScreen> createState() => _DeleteBookScreenState();
}

class _DeleteBookScreenState extends State<DeleteBookScreen> {
  late Future<void> _fetchBooksFuture;
  final Map<String, bool> _selectedBooks = {}; // Map để theo dõi sách đã chọn

  @override
  void initState() {
    super.initState();
    _fetchBooksFuture = context.read<BooksManager>().fetchBooks();
  }

  // Hàm xử lý khi nhấn nút "Delete Selected Books"
  Future<void> _deleteSelectedBooks() async {
    final booksManager = context.read<BooksManager>();
    final selectedBookIds = _selectedBooks.entries
        .where((entry) => entry.value) // Chỉ lấy các sách được chọn
        .map((entry) => entry.key)
        .toList();

    for (var bookId in selectedBookIds) {
      final book = booksManager.findById(bookId);
      if (book != null) {
        // Cập nhật sách với trạng thái deleted = 1
        await booksManager.updateBook(
          book.copyWith(deleted: 1),
        );
      }
    }

    // Xóa các sách đã chọn khỏi danh sách chọn và làm mới màn hình
    setState(() {
      _selectedBooks.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected books have been deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Books'),
      ),
      body: FutureBuilder(
        future: _fetchBooksFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final books = context.read<BooksManager>().activeBooks;

            return Column(
              children: [
                Expanded(
                  child: books.isNotEmpty
                      ? ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (ctx, index) {
                            final book = books[index];
                            return Card(
                              margin: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${book.id}'),
                                    Text(
                                      'Title: ${book.title}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Author: ${book.author}'),
                                  ],
                                ),
                                trailing: Checkbox(
                                  value: _selectedBooks[book.id] ?? false,
                                  onChanged: (isChecked) {
                                    setState(() {
                                      _selectedBooks[book.id!] = isChecked!;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('No books to display.'),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: _selectedBooks.containsValue(true)
                        ? _deleteSelectedBooks
                        : null, // Vô hiệu hóa nút nếu không có sách được chọn
                    child: const Text('Delete Selected Books'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
