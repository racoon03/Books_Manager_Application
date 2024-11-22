import 'dart:developer';

import 'package:ct484_project/models/book.dart';
import 'package:ct484_project/models/borrow_card.dart';
import 'package:ct484_project/models/member.dart';
import 'package:ct484_project/services/book_services.dart';
import 'package:ct484_project/services/card_service.dart';
import 'package:flutter/material.dart';

class CardsManager extends ChangeNotifier {
  final Cardservice _cardService = Cardservice();
  final BookService _bookService = BookService();

  List<BorrowCard> _cards = [];

  List<BorrowCard> get cards => _cards;

  List<BorrowCard> get cardsDeleted {
    return _cards.where((card) => card.isDeleted == true).toList();
  }

  Future<void> loadCards() async {
    _cards = await _cardService.getCards();

    notifyListeners();
  }

  Future<void> addCard(
      List<Map<String, dynamic>> selectedBooks, Member member) async {
    if (selectedBooks.isEmpty) {
      throw Exception('No books selected.');
    }

    if (member.id == null) {
      throw Exception('Member ID is required.');
    }

    final books = await _bookService.fetchBooks();
    final List<Book> updatedBooks = []; // To keep track of updated books

    final errors = [];
    // Check availability and prepare updates
    for (Book book in books) {
      for (final selectedBook in selectedBooks) {
        if (book.id == selectedBook['bookId']) {
          if (book.quantity < selectedBook['quantity']) {
            errors.add({
              'title': book.title,
              'available': book.quantity,
            });
          }
        }
      }
    }

    if (errors.isNotEmpty) {
      throw Exception('Books not available: \n${errors.map(
            (e) => '- ${e['title']} (stock: ${e['available']}).\n',
          ).join('')}');
    }

    for (Book book in books) {
      for (final selectedBook in selectedBooks) {
        if (book.id == selectedBook['bookId']) {
          // Save original quantity for rollback
          updatedBooks.add(book.copyWith(quantity: book.quantity));

          // Update the book quantity
          book = book.copyWith(
            quantity: book.quantity - (selectedBook['quantity'] as int),
          );

          try {
            await _bookService.updateBook(book);
          } catch (e) {
            throw Exception('Book service failed: $e');
          }
        }
      }
    }

    final borrowCard = BorrowCard(
      memberId: member.id!,
      memberName: '${member.lastName} ${member.firstName}',
      books: selectedBooks,
      borrowDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      isDeleted: false,
    );

    try {
      final borrowed = await _cardService.addCard(borrowCard);
      _cards.add(borrowed!);
    } catch (e) {
      log('Card service failed: $e');
      // Rollback book quantities if card service fails
      for (Book book in updatedBooks) {
        await _bookService.updateBook(book.copyWith(
          quantity: book.quantity +
              (selectedBooks.firstWhere(
                  (b) => b['bookId'] == book.id)['quantity'] as int),
        ));
      }
      throw Exception('Card transaction failed: $e');
    }
    notifyListeners();
  }

  Future<void> updateCard(BorrowCard card) async {
    log('Updating card: ${card.id}');
    final updatedCard = await _cardService.updateCard(card.copyWith(
      returnDate: DateTime.now(),
      isDeleted: true,
    ));
    if (updatedCard != null) {
      final index = _cards.indexWhere((c) => c.id == updatedCard.id);
      _cards[index] = updatedCard;

      // Update book quantities
      final books = await _bookService.fetchBooks();
      for (Book book in books) {
        for (final selectedBook in updatedCard.books) {
          if (book.id == selectedBook['bookId']) {
            book = book.copyWith(
              quantity: book.quantity + (selectedBook['quantity'] as int),
            );
            try {
              await _bookService.updateBook(book);
            } catch (e) {
              throw Exception('Book service failed: $e');
            }
          }
        }
      }
      notifyListeners();
    }
  }
}
