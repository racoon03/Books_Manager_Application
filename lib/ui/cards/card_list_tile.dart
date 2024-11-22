import 'package:ct484_project/models/borrow_card.dart';
import 'package:ct484_project/ui/cards/cards_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardListTile extends StatefulWidget {
  final BorrowCard borrowCard;

  const CardListTile(
    this.borrowCard, {
    super.key,
  });

  @override
  State<CardListTile> createState() => _CardListTileState();
}

class _CardListTileState extends State<CardListTile> {
  bool _isLoading = false;

  Future<void> _handleUpdate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<CardsManager>(context, listen: false)
          .updateCard(widget.borrowCard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardManager = Provider.of<CardsManager>(context);
    return Stack(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(
            Icons.book,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            widget.borrowCard.memberName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member: ${widget.borrowCard.memberName}',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Borrow: ${widget.borrowCard.borrowDate.toLocal().toShortDateString()}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Due: ${widget.borrowCard.dueDate.toLocal().toShortDateString()}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: !widget.borrowCard.isDeleted
              ? _checkinButton(context, cardManager)
              : null,
        ),
        Positioned(right: 0, top: 0, child: _buildStatusChip()),
        if (_isLoading) // Show loading indicator if loading
          Positioned.fill(
            child: Container(
              color: Colors.black54, // Optional: semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(), // Loading indicator
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color tagColor;
    String statusText;

    if (widget.borrowCard.isDeleted == true) {
      tagColor = Colors.green[700]!;
      statusText = 'Returned';
    } else if (widget.borrowCard.isDeleted == false) {
      tagColor = Colors.yellow[800]!;
      statusText = 'Pending';
    } else if (widget.borrowCard.dueDate.isBefore(DateTime.now())) {
      tagColor = Colors.red;
      statusText = 'Overdue';
    } else {
      tagColor = Colors.grey;
      statusText = 'Returned';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _checkinButton(context, cardManager) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      const Spacer(),
      ElevatedButton(
        onPressed: () {
          const title = 'CheckIn';
          const content = 'Are you sure you want to checkin this card?';

          _showConfirmationDialog(context, title, content).then((confirmed) {
            if (confirmed) {
              _handleUpdate();
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          side: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: const Text(
          'CheckIn',
          style: TextStyle(color: Colors.white),
        ),
      )
    ]);
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss the dialog and return false
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss the dialog and return true
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Ensure a boolean is returned
  }
}

extension DateTimeFormatting on DateTime {
  String toShortDateString() {
    return "$day/$month/$year";
  }
}
