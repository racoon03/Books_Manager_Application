import 'package:ct484_project/ui/screens.dart';
import 'package:flutter/material.dart';

class MemberListTile extends StatelessWidget {
  final Member member;

  const MemberListTile(this.member, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      tileColor: Theme.of(context).colorScheme.surface,
      splashColor: Theme.of(context).colorScheme.surface,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(member.avatarUrl),
      ),
      title: Text(
        '${member.lastName} ${member.firstName}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                member.isDeleted == false ? Icons.check_circle : Icons.cancel,
                color:
                    member.isDeleted == false ? Colors.green[600] : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                member.isDeleted == false ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: member.isDeleted == false
                      ? Colors.green[600]
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Begin: ${member.getFormattedMembershipDate()}',
            style: TextStyle(color: Colors.grey[800], fontSize: 11),
          ),
          Text(
            'Expire: ${member.getFormattedExpireDate()}',
            style: TextStyle(
              color: member.expirationDate.isAfter(DateTime.now())
                  ? Colors.green[600]
                  : Colors.red,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            'Paid: ${member.getFormattedTotal()}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).pushNamed(
        MemberDetailsView.routeName,
        arguments: member.id,
      ),
    );
  }
}
