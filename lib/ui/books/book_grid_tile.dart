import 'package:ct484_project/models/book.dart';
import 'package:flutter/material.dart';
import 'book_detail_screen.dart';

class BookGridTile extends StatelessWidget {
  const BookGridTile(
    this.book, {
    super.key,
  });

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: GridTile(
          // Thay đổi footer để hiển thị tên sách trực tiếp
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              // Điều hướng đến BookDetailScreen và truyền book.id
              Navigator.of(context).pushNamed(
                BookDetailScreen.routeName,
                arguments: book.id,
              );
            },
            child: Image.network(
              book.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
