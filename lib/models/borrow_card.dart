class BorrowCard {
  final String? id;
  final String memberId;
  final String memberName;
  final List<Map<String, dynamic>> books;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate; // Nullable if not returned yet
  final bool isDeleted;

  BorrowCard({
    this.id,
    required this.memberId,
    required this.memberName,
    required this.books,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.isDeleted,
  });

  copyWith({
    String? id,
    String? memberId,
    String? memberName,
    List<Map<String, dynamic>>? books,
    DateTime? borrowDate,
    DateTime? dueDate,
    DateTime? returnDate,
    int? statusId,
    bool? isDeleted,
  }) {
    return BorrowCard(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      books: books ?? this.books,
      memberName: memberName ?? this.memberName,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory BorrowCard.fromJson(Map<String, dynamic> json) {
    return BorrowCard(
      id: json['id'] as String? ?? '', // Default to an empty string if null
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      books: (json['books'] as List)
          .map((book) => {
                'bookId': book['bookId'] as String? ?? '',
                'bookName': book['bookName'] as String? ?? '',
                'quantity': book['quantity'] as int? ?? 0,
                'author': book['author'] as String? ?? '',
              })
          .toList(),
      borrowDate: json['borrowDate'] != null
          ? DateTime.parse(json['borrowDate'] as String)
          : DateTime.now(), // Handle as needed
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : DateTime.now(), // Handle as needed
      returnDate: json['returnDate'] != null && json['returnDate'] != ''
          ? DateTime.parse(json['returnDate'] as String)
          : null, // Handle nullable returnDate
      isDeleted: json['isDeleted'] == null
          ? false // Default to false if null
          : json['isDeleted'] as bool, // Assume it's a bool if not null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'books': books,
      'memberName': memberName,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}
