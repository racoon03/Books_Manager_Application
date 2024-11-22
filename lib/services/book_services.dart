import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/book.dart';
import 'pocketbase_client.dart';

class BookService {
  // Lấy URL đầy đủ cho ảnh từ PocketBase
  String _getImageUrl(PocketBase pb, RecordModel bookModel) {
    final imageName = bookModel.getStringValue('imageUrl');
    return pb.files.getUrl(bookModel, imageName).toString();
  }

  // Thêm mới một Book
  Future<Book?> addBook(Book book) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.model!.id; // Lấy userId hiện tại

      // Tạo mới book trên PocketBase
      final bookModel = await pb.collection('books').create(
        body: {
          ...book.toJson(),
          'userId': userId, // Thêm userId vào trường quan hệ
        },
        files: [
          if (book.imageFile != null)
            http.MultipartFile.fromBytes(
              'imageUrl', // Tên trường ảnh trong PocketBase
              await book.imageFile!.readAsBytes(),
              filename: book.imageFile!.uri.pathSegments.last,
            ),
        ],
      );

      // Trả về book đã thêm với URL của ảnh
      return book.copyWith(
        id: bookModel.id,
        imageUrl: _getImageUrl(pb, bookModel),
      );
    } catch (error) {
      print('Error adding book: $error');
      return null;
    }
  }

  // Lấy danh sách tất cả Book (hoặc của người dùng hiện tại nếu có `filteredByUser`)
  Future<List<Book>> fetchBooks({bool filteredByUser = false}) async {
    final List<Book> books = [];

    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.model!.id;

      // Lấy danh sách sách từ PocketBase
      final bookModels = await pb
          .collection('books')
          .getFullList(filter: filteredByUser ? "userId='$userId'" : null);

      // Chuyển đổi từng bookModel thành đối tượng Book
      for (final bookModel in bookModels) {
        books.add(
          Book.fromJson(
            bookModel.toJson()
              ..addAll({
                'imageUrl': _getImageUrl(pb, bookModel),
              }),
          ),
        );
      }
      return books;
    } catch (error) {
      print('Error fetching books: $error');
      return books;
    }
  }

  // Cập nhật Book hiện tại
  Future<Book?> updateBook(Book book) async {
    try {
      final pb = await getPocketbaseInstance();

      // Cập nhật thông tin book trên PocketBase
      final bookModel = await pb.collection('books').update(
            book.id!,
            body: book.toJson(),
            files: book.imageFile != null
                ? [
                    http.MultipartFile.fromBytes(
                      'imageUrl',
                      await book.imageFile!.readAsBytes(),
                      filename: book.imageFile!.uri.pathSegments.last,
                    ),
                  ]
                : [],
          );

      // Trả về đối tượng Book với URL của ảnh
      return book.copyWith(
        imageUrl: book.imageFile != null
            ? _getImageUrl(pb, bookModel)
            : book.imageUrl,
      );
    } catch (error) {
      print('Error updating book: $error');
      return null;
    }
  }

  // Xóa Book theo ID
  Future<bool> deleteBook(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('books').delete(id);

      return true;
    } catch (error) {
      print('Error deleting book: $error');
      return false;
    }
  }

  // Thêm phương thức fetchBookById
  Future<Book?> fetchBookById(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      final bookModel = await pb.collection('books').getOne(id);

      // Chuyển đổi dữ liệu thành đối tượng Book
      return Book.fromJson(bookModel.toJson());
    } catch (error) {
      print('Error fetching book by ID: $error');
      return null;
    }
  }
}
