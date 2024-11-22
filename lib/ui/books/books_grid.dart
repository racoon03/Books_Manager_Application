import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../models/book.dart';
import 'book_grid_tile.dart';

class BooksGrid extends StatelessWidget {
  final List<Book> books;
  const BooksGrid({Key? key, required this.books}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1 / 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: books.length,
      itemBuilder: (ctx, i) => BookGridTile(books[i]),
    );
  }
}
