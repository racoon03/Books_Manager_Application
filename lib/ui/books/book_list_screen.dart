import 'package:ct484_project/ui/books/book_delete_screen.dart';
import 'package:ct484_project/ui/books/book_form.dart';
import 'package:ct484_project/ui/books/book_restore_screen.dart';
import 'package:ct484_project/ui/books/books_grid.dart';
import 'package:ct484_project/ui/books/books_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BooksListView extends StatefulWidget {
  static const routeName = '/books';

  const BooksListView({super.key});

  @override
  BooksListViewState createState() => BooksListViewState();
}

class BooksListViewState extends State<BooksListView> {
  late Future<void> _fetchBooks;

  @override
  void initState() {
    super.initState();
    _fetchBooks = context.read<BooksManager>().fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: <Widget>[
          AddBookButton(
            onPressed: () {
              Navigator.of(context).pushNamed(BookForm.routeName);
            },
          ),
          // Nút xóa sách
          DeleteBookButton(
            onPressed: () {
              Navigator.of(context).pushNamed(DeleteBookScreen.routeName);
            },
          ),
          // Nút khôi phục sách
          RestoreBookButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RestoreBookScreen.routeName);
            },
          ),
        ],
      ),
      // Sử dụng FutureBuilder để quản lý trạng thái fetchBooks
      body: FutureBuilder<void>(
        future: _fetchBooks,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Consumer<BooksManager>(
              builder: (ctx, booksManager, child) => BooksGrid(
                books: booksManager.activeBooks,
              ),
            );
          }
        },
      ),
    );
  }
}

class AddBookButton extends StatelessWidget {
  const AddBookButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add Book',
      onPressed: onPressed,
    );
  }
}

class DeleteBookButton extends StatelessWidget {
  const DeleteBookButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      tooltip: 'Delete Book',
      onPressed: onPressed,
    );
  }
}

class RestoreBookButton extends StatelessWidget {
  const RestoreBookButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.restore),
      tooltip: 'Restore Book',
      onPressed: onPressed,
    );
  }
}
