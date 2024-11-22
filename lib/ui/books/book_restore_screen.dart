import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'books_manager.dart';

class RestoreBookScreen extends StatefulWidget {
  const RestoreBookScreen({super.key});
  static const routeName = '/books/restore';

  @override
  State<RestoreBookScreen> createState() => _RestoreBookScreenState();
}

class _RestoreBookScreenState extends State<RestoreBookScreen> {
  late Future<void> _fetchBooksFuture;
  final Map<String, bool> _selectedBooks = {}; // Map để theo dõi sách đã chọn

  @override
  void initState() {
    super.initState();
    // Gọi fetchBooks để lấy dữ liệu từ BooksManager
    _fetchBooksFuture = context.read<BooksManager>().fetchBooks();
  }

  // Hàm xử lý khi nhấn nút "Restore Selected Books"
  Future<void> _restoreSelectedBooks() async {
    final booksManager = context.read<BooksManager>();
    final selectedBookIds = _selectedBooks.entries
        .where((entry) => entry.value) // Chỉ lấy các sách được chọn
        .map((entry) => entry.key)
        .toList();

    for (var bookId in selectedBookIds) {
      final book = booksManager.findById(bookId);
      if (book != null) {
        // Cập nhật sách với trạng thái deleted = 0
        await booksManager.updateBook(
          book.copyWith(deleted: 0),
        );
      }
    }

    // Xóa các sách đã chọn khỏi danh sách chọn và làm mới màn hình
    setState(() {
      _selectedBooks.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected books have been restored.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Books'),
      ),
      body: FutureBuilder(
        future: _fetchBooksFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Lấy danh sách sách đã bị xóa (deleted = 1)
            final books = context
                .read<BooksManager>()
                .books
                .where(
                    (book) => book.deleted == 1) // Chỉ lấy sách có deleted = 1
                .toList();

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
                        ? _restoreSelectedBooks
                        : null, // Vô hiệu hóa nút nếu không có sách được chọn
                    child: const Text('Restore Selected Books'),
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
