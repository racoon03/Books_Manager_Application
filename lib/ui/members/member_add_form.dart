import 'dart:developer';
import 'dart:io';

import 'package:ct484_project/models/member.dart';
import 'package:ct484_project/ui/members/members_manager.dart';
import 'package:ct484_project/ui/shared/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MemberAddForm extends StatelessWidget {
  static const routeName = '/members/add';

  const MemberAddForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
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
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? citizenId;
  String? selectedPackage;
  int total = 0;
  DateTime? expirationDate;

  final Map<String, int> _packageOptions = {
    '1 Month': 200000,
    '3 Months': 500000,
    '6 Months': 900000,
  };

  late Member member;
  bool _isLoading = false;

  void calculateExpirationDate() {
    if (selectedPackage != null) {
      int months = int.parse(selectedPackage!.split(' ')[0]);
      setState(() {
        expirationDate = DateTime.now()
            .add(Duration(days: months * 30)); // Store the DateTime

        total = _packageOptions[
            selectedPackage]!; // Use the selected package directly
        log(total.toString());
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loader
    });

    _formKey.currentState!.save();

    try {
      final membersManager = context.read<MembersManager>();
      await membersManager.addMember(member);
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loader
        });
        await showErrorDialog(
          context,
          error.toString(),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false; // Hide loader
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    member = Member(
      id: null,
      firstName: '',
      lastName: '',
      phone: '',
      email: '',
      citizenId: '',
      avatar: null,
      avatarUrl: '',
      createdAt: DateTime.now(),
      membershipDate: DateTime.now(),
      expirationDate: DateTime.now(),
      total: 0,
      isDeleted: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
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
                  onSaved: (newValue) => member = member.copyWith(
                    firstName: newValue,
                  )!,
                  onChanged: (value) => setState(() {
                    firstName = value;
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                  onSaved: (newValue) => member = member.copyWith(
                    lastName: newValue,
                  )!,
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                  onSaved: (newValue) => member = member.copyWith(
                    phone: newValue,
                  )!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (newValue) => member = member.copyWith(
                    email: newValue,
                  )!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Citizen ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Citizen ID';
                    }
                    return null;
                  },
                  onSaved: (newValue) => member = member.copyWith(
                    citizenId: newValue,
                  )!,
                ),
                const SizedBox(height: 16),
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
                      calculateExpirationDate();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a package';
                    }
                    return null;
                  },
                  onSaved: (newValue) => member = member.copyWith(
                      createdAt: DateTime.now(),
                      membershipDate: DateTime.now(),
                      expirationDate: expirationDate,
                      total: total)!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Total (Money)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Make this read-only
                  controller: TextEditingController(
                      text: NumberFormat.currency(locale: 'vi')
                          .format(total)), // Display total
                ),
                const SizedBox(height: 20),
                _buildProductField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveForm();
                    }
                  },
                  child: const Text('Add Member',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: !member.hasAvatar()
              ? const Center(child: Text('Enter a URL'))
              : FittedBox(
                  child: member.avatar == null
                      ? Image.network(member.avatarUrl, fit: BoxFit.cover)
                      : Image.file(
                          member.avatar!,
                          fit: BoxFit.cover,
                        )),
        ),
        Expanded(
          child: SizedBox(
            height: 100,
            child: _buildImagePickerButton(),
          ),
        )
      ],
    );
  }

  TextButton _buildImagePickerButton() {
    return TextButton.icon(
      icon: const Icon(Icons.camera),
      label: const Text('Take Picture'),
      onPressed: () async {
        final imagePicker = ImagePicker();
        try {
          final imageFile = await imagePicker.pickImage(
            source: ImageSource.gallery,
          );

          if (imageFile == null) {
            return;
          }
          member = member.copyWith(
            avatar: File(imageFile.path),
          )!;
          setState(() {});
        } catch (error) {
          if (mounted) {
            await showErrorDialog(
              context,
              'An error occurred',
            );
          }
        }
      },
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
