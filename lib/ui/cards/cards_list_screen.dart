import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../screens.dart';

class CardsListScreen extends StatefulWidget {
  static const routeName = '/cards';

  const CardsListScreen({super.key});

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  String filter = 'Pending'; // State to toggle between active and inactive

  void toggleFilter(String selectedFilter) {
    setState(() {
      filter = selectedFilter; // Set the filter based on the button clicked
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: <Widget>[
          AddCardButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CardAddForm.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => toggleFilter('Pending'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        filter == 'Pending' ? Colors.blue : Colors.white,
                    side: const BorderSide(
                      color: Colors.blue, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                        color:
                            filter == 'Pending' ? Colors.white : Colors.blue),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                ElevatedButton(
                  onPressed: () => toggleFilter('Overdue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        filter == 'Overdue' ? Colors.blue : Colors.white,
                    side: const BorderSide(
                      color: Colors.blue, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Overdue',
                    style: TextStyle(
                        color:
                            filter == 'Overdue' ? Colors.white : Colors.blue),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                ElevatedButton(
                  onPressed: () => toggleFilter('Returned'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        filter == 'Returned' ? Colors.blue : Colors.white,
                    side: const BorderSide(
                      color: Colors.blue, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Returned',
                    style: TextStyle(
                        color:
                            filter == 'Returned' ? Colors.white : Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CardsList(filter: filter), // Pass filter state
          ),
        ],
      ),
    );
  }
}

class CardsList extends StatefulWidget {
  final String filter; // Receive the filter state

  const CardsList({super.key, required this.filter});

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  late Future<void> _loadCards;

  @override
  void initState() {
    super.initState();
    _loadCards = context.read<CardsManager>().loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadCards,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Loading indicator
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Error handling
        } else {
          return Consumer<CardsManager>(builder: (ctx, cardsManager, child) {
            final filteredCards = cardsManager.cards.where((member) {
              if (widget.filter == 'Pending') return member.isDeleted == false;
              if (widget.filter == 'Returned') return member.isDeleted == true;
              if (widget.filter == 'Overdue') {
                return member.isDeleted == false &&
                    member.dueDate.isBefore(DateTime.now());
              }
              return true; // Show all cards
            }).toList();

            if (filteredCards.isEmpty) {
              return const Center(
                child: Text(
                  'No borrow cards found.',
                  style: TextStyle(fontSize: 20),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index]; // Get the current card

                return GestureDetector(
                  onTap: () {
                    // Show the modal dialog when the card is tapped
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final dateFormat = DateFormat('HH:mm - dd/MM/yy');
                        return AlertDialog(
                          title: Text(
                              'Details for ${card.memberName}'), // Display member name
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(
                                  'Member ID: ${card.memberId}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'Member Name: ${card.memberName}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'Borrow Date: ${dateFormat.format(card.borrowDate.toLocal())}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'Due Date: ${dateFormat.format(card.dueDate.toLocal())}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'Return Date: ${card.returnDate != null ? dateFormat.format(card.returnDate!.toLocal()) : "Not returned"}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const Text(
                                  'Books:',
                                  style: TextStyle(fontSize: 15),
                                ),
                                ...card.books.asMap().entries.map(
                                  (entry) {
                                    final index = entry.key; // Get the index
                                    final book =
                                        entry.value; // Get the book details

                                    return Text(
                                      '${index + 1}. ${book['bookName']} - ${book['author']} (Quantity: ${book['quantity']})',
                                      style: const TextStyle(fontSize: 15),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CardListTile(card), // Use filtered member
                  ),
                );
              },
            );
          });
        }
      },
    );
  }
}

class AddCardButton extends StatelessWidget {
  const AddCardButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add Member',
      onPressed: onPressed,
    );
  }
}
