import 'package:ct484_project/ui/books/book_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'books_manager.dart';

class BookDetailScreen extends StatefulWidget {
  static const routeName = '/books/detail';
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Future<void> _fetchBookFuture;

  @override
  void initState() {
    super.initState();
    // Gọi fetch dữ liệu trong initState
    _fetchBookFuture = _fetchBook();
  }

  Future<void> _fetchBook() {
    return context.read<BooksManager>().fetchBookById(widget.bookId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gọi lại fetch dữ liệu mỗi khi màn hình được làm mới
    _fetchBookFuture = _fetchBook();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: FutureBuilder(
        future: _fetchBookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final selectedBook =
                context.read<BooksManager>().findById(widget.bookId);

            if (selectedBook == null) {
              return const Center(
                child: Text('Book not found!'),
              );
            }

            // Hiển thị chi tiết sách nếu tìm thấy
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      selectedBook.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildDetailRow('ID', '${selectedBook.id}'),
                            buildDetailRow('Title', selectedBook.title),
                            buildDetailRow('Author', selectedBook.author),
                            buildDetailRow('Genre', selectedBook.genre),
                            buildDetailRow('Published', selectedBook.published),
                            buildDetailRow(
                                'Quantity', '${selectedBook.quantity}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: EditBookButton(
        bookId: widget.bookId,
        onEditComplete: () {
          setState(() {
            _fetchBookFuture = _fetchBook();
          });
        },
      ),
    );
  }

  Widget buildDetailRow(String label, dynamic value) {
    String displayValue;

    if (value is DateTime) {
      displayValue = DateFormat('yyyy-MM-dd').format(value);
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(displayValue),
        ],
      ),
    );
  }
}

class EditBookButton extends StatelessWidget {
  final String bookId;
  final VoidCallback onEditComplete;

  const EditBookButton({
    super.key,
    required this.bookId,
    required this.onEditComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue, // Màu nền xanh cho container
        borderRadius: BorderRadius.circular(8), // Bo góc
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // Màu bóng mờ
            blurRadius: 6, // Độ mờ của bóng
            offset: Offset(0, 4), // Độ lệch của bóng (trục X, trục Y)
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.edit),
        color: Colors.white, // Màu icon trắng
        onPressed: () async {
          // Điều hướng đến BookForm và chờ kết quả
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookForm(bookId: bookId),
            ),
          );
          // Gọi hàm onEditComplete khi quay lại màn hình này
          onEditComplete();
        },
      ),
    );
  }
}
