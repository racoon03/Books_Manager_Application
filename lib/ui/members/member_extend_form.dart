import 'package:ct484_project/models/member.dart';
import 'package:ct484_project/ui/members/members_manager.dart';
import 'package:ct484_project/ui/shared/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberExtendForm extends StatelessWidget {
  static const routeName = '/members/extend';
  final Member _member; // Member to extend
  const MemberExtendForm(Member member, {super.key}) : _member = member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extend Membership'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExtendForm(
          member: _member,
        ),
      ),
    );
  }
}

class ExtendForm extends StatefulWidget {
  final Member member;

  const ExtendForm({super.key, required this.member}); // Accept member

  @override
  ExtendFormState createState() => ExtendFormState();
}

class ExtendFormState extends State<ExtendForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPackage; // Default value
  int? total; // Default total

  late Member _member; // Member to extend

  final Map<String, int> _packageOptions = {
    '1 Month': 200000,
    '3 Months': 500000,
    '6 Months': 900000,
  };

  bool checkRenew(DateTime expirationDate) {
    if (expirationDate.isBefore(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    try {
      final membersManager = context.read<MembersManager>();
      if (_member.id != null) {
        await membersManager.updateMember(_member);
      }
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, error.toString());
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _member = widget.member; // Ensure member is initialized from widget
    selectedPackage = '1 Month'; // Default package
    total = _packageOptions[selectedPackage];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Current Member: ${_member.lastName} ${_member.firstName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Package',
                border: OutlineInputBorder(),
              ),
              value: selectedPackage,
              items: _packageOptions.keys
                  .map((String package) => DropdownMenuItem<String>(
                        value: package,
                        child: Text(package),
                      ))
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedPackage = value;
                  total = _packageOptions[value];
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a package';
                }
                return null;
              },
              onSaved: (newValue) => _member = _member.copyWith(
                  membershipDate: checkRenew(_member.expirationDate)
                      ? DateTime.now()
                      : _member.membershipDate,
                  expirationDate: checkRenew(_member.expirationDate)
                      ? DateTime.now().add(Duration(
                          days: selectedPackage == '1 Month'
                              ? 30
                              : selectedPackage == '3 Months'
                                  ? 90
                                  : 180))
                      : _member.expirationDate.add(Duration(
                          days: selectedPackage == '1 Month'
                              ? 30
                              : selectedPackage == '3 Months'
                                  ? 90
                                  : 180)),
                  total: _member.total + total!)!,
            ),
            const SizedBox(height: 20),
            Text(
              'Total: $total',
              style: const TextStyle(fontSize: 28),
            ), // Display selected total
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Show confirmation dialog and wait for user response
                  bool? confirm = await showConfirmDialog(
                    context,
                    'Are you sure you want to extend membership for ID: ${_member.id} - ${_member.lastName} ${_member.firstName}?',
                  );

                  if (confirm == true && context.mounted) {
                    // Parse months and total from the selected package
                    _saveForm();
                    // Optionally, navigate back after submission
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Extend Membership',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error),
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          ActionButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
