import 'package:ct484_project/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersListView extends StatefulWidget {
  static const routeName = '/members';

  const MembersListView({super.key});

  @override
  MembersListViewState createState() => MembersListViewState();
}

class MembersListViewState extends State<MembersListView> {
  String filter = 'All'; // State to toggle between active and inactive

  void toggleFilter(String selectedFilter) {
    setState(() {
      filter = selectedFilter; // Set the filter based on the button clicked
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: <Widget>[
          AddMemberButton(
            onPressed: () {
              Navigator.of(context).pushNamed(MemberAddForm.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => toggleFilter('All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        filter == 'All' ? Colors.blue : Colors.white,
                    side: const BorderSide(
                      color: Colors.blue, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'All',
                    style: TextStyle(
                        color: filter == 'All' ? Colors.white : Colors.blue),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                ElevatedButton(
                  onPressed: () => toggleFilter('Active'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        filter == 'Active' ? Colors.blue : Colors.white,
                    side: const BorderSide(
                      color: Colors.blue, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                        color: filter == 'Active' ? Colors.white : Colors.blue),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                ElevatedButton(
                  onPressed: () => toggleFilter('Inactive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        filter == 'Inactive' ? Colors.blue : Colors.white,
                    side: const BorderSide(
                      color: Colors.blue, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Inactive',
                    style: TextStyle(
                        color:
                            filter == 'Inactive' ? Colors.white : Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MembersList(filter: filter), // Pass filter state
          ),
        ],
      ),
    );
  }
}

class MembersList extends StatefulWidget {
  final String filter; // Receive the filter state

  const MembersList({super.key, required this.filter});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  late Future<void> _loadMembers;
  @override
  void initState() {
    super.initState();
    _loadMembers = context.read<MembersManager>().loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadMembers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Consumer<MembersManager>(
          builder: (ctx, membersManager, child) {
            if (membersManager.members.isEmpty) {
              return const Center(child: Text('No data available.'));
            }

            final filteredMembers = membersManager.members.where((member) {
              if (widget.filter == 'Active') return !member.isDeleted;
              if (widget.filter == 'Inactive') return member.isDeleted;
              return true; // Show all members
            }).toList();

            return ListView.builder(
              padding:
                  const EdgeInsets.all(16.0), // Add padding around the list
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4, // Add a shadow effect
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0), // Space between cards
                  child: MemberListTile(
                      filteredMembers[index]), // Use filtered member
                );
              },
            );
          },
        );
      },
    );
  }
}

class AddMemberButton extends StatelessWidget {
  const AddMemberButton({super.key, this.onPressed});

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
