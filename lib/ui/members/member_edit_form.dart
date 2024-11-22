import 'package:ct484_project/ui/screens.dart';
import 'package:ct484_project/ui/shared/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberEditForm extends StatelessWidget {
  static const routeName = '/members/edit';
  MemberEditForm(Member? member, {super.key}) : _member = member!;

  late final Member _member; // Member to extend
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Member'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EditForm(member: _member),
      ),
    );
  }
}

class EditForm extends StatefulWidget {
  final Member member;
  const EditForm({super.key, required this.member});

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends State<EditForm> {
  final _editForm = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String phone = '';
  String citizenId = '';

  late Member _editedMember;

  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate();
    if (!isValid) {
      return;
    }

    _editForm.currentState!.save();

    try {
      final membersManager = context.read<MembersManager>();
      if (_editedMember.id != null) {
        membersManager.updateMember(_editedMember);
      }
    } catch (error) {
      await showErrorDialog(
        context,
        error.toString(),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    _editedMember = widget.member;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap with SingleChildScrollView
      child: Form(
        key: _editForm,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.member.firstName,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              onSaved: (newValue) => _editedMember = _editedMember.copyWith(
                firstName: newValue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.member.lastName,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              onSaved: (newValue) => _editedMember = _editedMember.copyWith(
                lastName: newValue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.member.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onSaved: (newValue) => _editedMember = _editedMember.copyWith(
                phone: newValue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.member.citizenId,
              decoration: const InputDecoration(
                labelText: 'Citizen ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Citizen ID';
                }
                return null;
              },
              onSaved: (newValue) => _editedMember = _editedMember.copyWith(
                citizenId: newValue,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                if (_editForm.currentState!.validate()) {
                  // Process data (e.g., save to database)
                  _saveForm();
                }
              },
              child: const Text('Edit Member',
                  style: TextStyle(color: Colors.white)),
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
