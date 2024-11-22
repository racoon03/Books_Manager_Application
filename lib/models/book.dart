import 'dart:io';

class Book {
  final String? id;
  final String title;
  final String author;
  final String genre;
  final String imageUrl;
  final File? imageFile;
  final DateTime published;
  final int quantity;
  int deleted;

  Book(
      {this.id,
      required this.title,
      required this.author,
      required this.genre,
      this.imageUrl = '',
      this.imageFile,
      required this.published,
      required this.quantity,
      required this.deleted});

  copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    String? imageUrl, // Thêm imageUrl ở đây
    File? imageFile,
    DateTime? published,
    int? quantity,
    int? deleted,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      published: published ?? this.published,
      quantity: quantity ?? this.quantity,
      deleted: deleted ?? this.deleted,
    );
  }

  bool hasimageFile() {
    return imageFile != null || imageUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'published': published.toIso8601String(),
      'quantity': quantity,
      'deleted': deleted,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      genre: json['genre'],
      imageUrl: json['imageUrl'] ?? '',
      published: DateTime.tryParse(json['published'] ?? '') ?? DateTime.now(),
      quantity: json['quantity'],
      deleted: json['deleted'],
    );
  }
}
