import 'dart:developer';

import 'package:ct484_project/models/borrow_card.dart';
import 'package:ct484_project/services/pocketbase_client.dart';

class Cardservice {
  Future<List<BorrowCard>> getCards() async {
    final List<BorrowCard> cards = [];
    try {
      final pb = await getPocketbaseInstance();
      final cardModels = await pb.collection('cards').getFullList(
            sort: '-created',
          );

      for (final cardModel in cardModels) {
        cards.add(BorrowCard.fromJson(cardModel.toJson()));
      }
      return cards;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<BorrowCard?> addCard(BorrowCard card) async {
    try {
      final pb = await getPocketbaseInstance();
      final newCard = await pb.collection('cards').create(body: card.toJson());
      return BorrowCard.fromJson(newCard.toJson());
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<BorrowCard?> updateCard(BorrowCard card) async {
    try {
      final pb = await getPocketbaseInstance();
      log(card.toJson().toString());
      final updatedCard =
          await pb.collection('cards').update(card.id!, body: card.toJson());
      return BorrowCard.fromJson(updatedCard.toJson());
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
