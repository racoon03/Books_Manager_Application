import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ct484_project/models/book.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'books_manager.dart';
import 'package:image_picker/image_picker.dart';

class BookForm extends StatefulWidget {
  static const routeName = '/books/form';
  final String? bookId; // ID sách nếu có (để chỉnh sửa)

  const BookForm({super.key, this.bookId});

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _publishedDate; // Khai báo biến DateTime này
  Book? _book;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final booksManager = Provider.of<BooksManager>(context, listen: false);
    if (widget.bookId != null) {
      _book = booksManager.findById(widget.bookId!);
      if (_book != null) {
        _titleController.text = _book!.title;
        _authorController.text = _book!.author;
        _genreController.text = _book!.genre;
        _publishedDate = _book!.published;
        _quantityController.text = _book!.quantity.toString();
        _imageFile = _book!.imageFile;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 10),

            // Author field
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
              ),
            ),
            const SizedBox(height: 10),

            // Genre field
            TextFormField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
              ),
            ),
            const SizedBox(height: 10),

            // Quantity field
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
            ),

            const SizedBox(height: 20), //
            // Published Date field
            buildDatePicker(context),
            const SizedBox(height: 10),
            const SizedBox(height: 10),

            const SizedBox(height: 20),
            // Image Picker and Preview
            buildBookPreview(),
            const SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _publishedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _publishedDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Published Date',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _publishedDate != null
              ? DateFormat('yyyy-MM-dd').format(_publishedDate!)
              : 'Select a date',
          style: TextStyle(
            color: _publishedDate != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildBookPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _imageFile == null && (_book == null || !_book!.hasimageFile())
              ? const Center(child: Text('No Image'))
              : FittedBox(
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _book!.imageUrl,
                          fit: BoxFit.cover,
                        ),
                ),
        ),
        Expanded(
          child: SizedBox(
            height: 100,
            child: _buildImagePickerButton(),
          ),
        ),
      ],
    );
  }

  TextButton _buildImagePickerButton() {
    return TextButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Pick Image'),
      onPressed: () async {
        final imagePicker = ImagePicker();
        try {
          final pickedFile =
              await imagePicker.pickImage(source: ImageSource.gallery);
          if (pickedFile == null) return;

          setState(() {
            _imageFile = File(pickedFile.path);
          });
        } catch (error) {
          showErrorDialog(context, 'Something went wrong.');
        }
      },
    );
  }

  Future<void> _submitForm() async {
    final booksManager = Provider.of<BooksManager>(context, listen: false);
    final newBook = Book(
      id: widget.bookId,
      title: _titleController.text,
      author: _authorController.text,
      genre: _genreController.text,
      imageUrl: _imageFile == null && _book != null
          ? _book!.imageUrl // Giữ nguyên URL ảnh cũ nếu không có ảnh mới
          : '', // Sẽ cập nhật nếu có ảnh mới được chọn
      imageFile: _imageFile,
      published: _publishedDate!,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      deleted: 0,
    );

    if (widget.bookId == null) {
      await booksManager.addBook(newBook); // Thêm sách mới
    } else {
      await booksManager.updateBook(newBook); // Cập nhật sách hiện có
    }

    print("Data sent to PocketBase:");
    print(newBook.toJson());

    // Hiển thị thông báo lưu thành công
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Book saved successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context)
                ..pop() // Đóng AlertDialog
                ..pop(); // Quay về trang trước
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
