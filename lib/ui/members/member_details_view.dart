import 'package:ct484_project/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MemberDetailsView extends StatefulWidget {
  static const routeName = '/member-details';
  const MemberDetailsView(this.member, {super.key});

  final Member member;

  @override
  State<MemberDetailsView> createState() => _MemberDetailsViewState();
}

class _MemberDetailsViewState extends State<MemberDetailsView> {
  late Member member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MembersManager>(builder: (ctx, membersManager, child) {
      final updatedMember = membersManager.members
          .firstWhere((m) => m.id == member.id, orElse: () => member);

      return Scaffold(
        appBar: AppBar(
          title: Text('${updatedMember.lastName} ${updatedMember.firstName}'),
          centerTitle: true,
        ),
        body: membersManager.isLoading // Show loader if loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard('ID', updatedMember.id.toString()),
                      _buildDetailCard('Last Name', updatedMember.lastName),
                      _buildDetailCard('First Name', updatedMember.firstName),
                      _buildDetailCard('Phone', updatedMember.phone),
                      _buildDetailCard('Citizen Id', updatedMember.citizenId),
                      _buildDetailCard('Email', updatedMember.email),
                      _buildDetailCard(
                          'Created at', updatedMember.getFormattedCreatedAt()),
                      _buildDetailCard('Begin at',
                          updatedMember.getFormattedMembershipDate()),
                      _buildDetailCard(
                          'Expire at', updatedMember.getFormattedExpireDate()),
                      _buildDetailCard(
                          'Total paid', updatedMember.total.toString()),
                      _buildDetailCard(
                          'Status',
                          updatedMember.isDeleted == false
                              ? 'Active'
                              : 'Inactive'),
                      const SizedBox(height: 16),
                      _actions(context, updatedMember.isDeleted),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildDetailCard(String title, String value) {
    bool isInactive = false;
    bool isActive = false;
    if (title.toLowerCase().contains('status')) {
      if (value.toLowerCase().contains('inactive')) {
        isInactive = true;
      } else {
        isActive = true;
      }
    }

    bool isExpired = false;
    if (title.toLowerCase().contains('expire')) {
      // Parse the date from the string using DateFormat
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(value);

      // Check if the parsed date is before the current date
      if (parsedDate.isBefore(DateTime.now())) {
        isExpired = true;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: isActive
                    ? Colors.green
                    : isInactive || isExpired
                        ? Colors.red
                        : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, bool isDeleted) {
    bool isInactive = isDeleted != false;
    final membersManager = context.read<MembersManager>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // background
          ),
          onPressed: isInactive
              ? null
              : () {
                  Navigator.of(context).pushNamed(MemberExtendForm.routeName,
                      arguments: widget.member.id);
                },
          child: const Text('Extend', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // background
          ),
          onPressed: isInactive
              ? null
              : () async {
                  Navigator.of(context)
                      .pushNamed(MemberEditForm.routeName,
                          arguments: widget.member.id)
                      .then((_) async {
                    // After returning, fetch the updated member details
                    final updatedMember =
                        membersManager.findById(widget.member.id!);

                    // Check if the updatedMember is not null
                    if (updatedMember != null) {
                      setState(() {
                        member =
                            updatedMember; // Update the local member instance
                      });
                    }
                  });
                },
          child: const Text('Edit', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Yellow background
          ),
          onPressed: () {
            final title = isInactive ? 'Restore Member' : 'Disactivate Member';
            final content = isInactive
                ? 'Are you sure you want to restore this member?'
                : 'Are you sure you want to disactivate this member?';

            _showConfirmationDialog(context, title, content).then((confirmed) {
              if (confirmed) {
                membersManager.updateActive(widget.member.id!);
              }
            });
          },
          child: Text(
            isInactive ? 'Restore' : 'Disactivate',
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
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
