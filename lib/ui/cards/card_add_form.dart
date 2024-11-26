import 'dart:developer';

import 'package:ct484_project/models/book.dart';
import 'package:ct484_project/ui/screens.dart';
import 'package:ct484_project/ui/shared/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardAddForm extends StatelessWidget {
  static const routeName = '/cards/add';

  const CardAddForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: _AddForm(),
      ),
    );
  }
}

class _AddForm extends StatefulWidget {
  const _AddForm();

  @override
  _AddFormState createState() => _AddFormState();
}

class _AddFormState extends State<_AddForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bookIdController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();

  final List<Map<String, dynamic>> _selectedBooks = [];
  Member? _selectedMember;
  Book? _selectedBook;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final booksManager = context.read<BooksManager>();
      final membersManager = context.read<MembersManager>();

      // Bắt đầu tải dữ liệu
      await Future.wait([
        booksManager.fetchBooks(),
        membersManager.loadMembers(),
      ]);

      // Sau khi dữ liệu tải xong
      if (mounted) {
        setState(() {
          _isLoading = false; // Dừng hiển thị vòng tròn chờ
        });
      }
    });
  }

  @override
  void dispose() {
    _bookIdController.dispose();
    _memberIdController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isLoading =
            true; // Notify Flutter to rebuild and reflect the loading state
      });
      final cardsManager = context.read<CardsManager>();
      await cardsManager.addCard(_selectedBooks, _selectedMember!);
      if (mounted) {
        setState(() {
          _isLoading =
              false; // Notify Flutter to rebuild and reflect the loading state
        });
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        await showErrorDialog(
          context,
          error.toString(),
        );
        setState(() {
          _isLoading =
              false; // Notify Flutter to rebuild and reflect the loading state
        });
      }
    }
  }

  void _addBookToList() {
    if (_selectedBook != null) {
      final selectedBook = {
        'bookId': _selectedBook!.id,
        'bookName': _selectedBook!.title,
        'author': _selectedBook!.author,
        'quantity': 1,
      };
      if (!_selectedBooks.any((book) => book['bookId'] == _selectedBook!.id)) {
        setState(() {
          _selectedBooks.add(selectedBook);
          log('Book added: $selectedBook'); // Kiểm tra sách đã được thêm
        });
      } else {
        final index = _selectedBooks
            .indexWhere((book) => book['bookId'] == _selectedBook!.id);
        _updateBookQuantity(index, 1);
      }
    }
  }

  void _updateBookQuantity(int index, int change) {
    setState(() {
      _selectedBooks[index]['quantity'] += change;
      if (_selectedBooks[index]['quantity'] <= 0) {
        _selectedBooks.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersManager = context.read<MembersManager>();
    final booksManager = context.read<BooksManager>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Member ID Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<Member>(
                  value: _selectedMember, // Member được chọn
                  decoration: const InputDecoration(
                    labelText: 'Select Member',
                    border: OutlineInputBorder(),
                  ),
                  items: membersManager.members.map((member) {
                    return DropdownMenuItem<Member>(
                      value: member,
                      child: Text(
                          '${member.firstName} ${member.lastName}'), // Tên member
                    );
                  }).toList(),
                  onChanged: (member) {
                    setState(() {
                      _selectedMember = member; // Cập nhật member được chọn
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a member';
                    }
                    return null;
                  },
                ),
              ),

              if (_selectedMember != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Member: ${_selectedMember!.firstName}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedMember = null; // Clear selected member
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Book ID Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<Book>(
                  value: _selectedBook, // Sách được chọn
                  decoration: const InputDecoration(
                    labelText: 'Select Book',
                    border: OutlineInputBorder(),
                  ),
                  items: booksManager.books.map((book) {
                    return DropdownMenuItem<Book>(
                      value: book,
                      child: Text(book.title), // Tên sách
                    );
                  }).toList(),
                  onChanged: (book) {
                    setState(() {
                      _selectedBook = book; // Cập nhật sách được chọn
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a book';
                    }
                    return null;
                  },
                ),
              ),

              // Display Books List
              if (_selectedBook != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Book: ${_selectedBook!.title}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _addBookToList();
                          })
                    ],
                  ),
                ),

              if (_selectedBooks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedBooks.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selected Books:',
                                style: TextStyle(fontSize: 18)),
                            ..._selectedBooks.map((book) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Tooltip(
                                        message: book[
                                            'bookName']!, // Full book name for the tooltip
                                        child: Text(
                                          book['bookName']!,
                                          style: const TextStyle(fontSize: 18),
                                          overflow: TextOverflow
                                              .ellipsis, // Truncate long text with ellipsis
                                          maxLines:
                                              1, // Ensure text stays in a single line
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          ' x ${book['quantity']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 16),
                                          onPressed: () {
                                            _updateBookQuantity(
                                                _selectedBooks.indexOf(book),
                                                1);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove,
                                              size: 16),
                                          onPressed: () {
                                            _updateBookQuantity(
                                                _selectedBooks.indexOf(book),
                                                -1);
                                          },
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.clear, size: 16),
                                          onPressed: () {
                                            setState(() {
                                              _selectedBooks.remove(
                                                  book); // Remove book from the list
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),

              if (_selectedBooks.isNotEmpty && _selectedMember != null)
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable button when loading
                      : () {
                          log('Creating card...');
                          _saveForm();
                        },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Text color
                  ),
                  child: _isLoading == true
                      ? const Text('Creating') // Show "Creating" while loading
                      : const Text('Create'), // Show "Create" when not loading
                )
            ],
          ),
        ),
      ),
    );
  }
}
