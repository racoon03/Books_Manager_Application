import 'dart:developer';

import 'package:ct484_project/models/member.dart';
import 'package:ct484_project/services/member_services.dart';
import 'package:flutter/foundation.dart';

class MembersManager extends ChangeNotifier {
  final MemberServices memberService = MemberServices();
  List<Member> _members = [];
  bool _isLoading = false;

  int get count {
    return _members.length;
  }

  List<Member> get members => _members;

  bool get isLoading => _isLoading;

  Future<void> loadMembers() async {
    _members = await memberService.getMembers();
    notifyListeners();
  }

  Member? findById(String id) {
    try {
      log('Find member by id $id');
      return _members.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  Member? searchMembers(String id) {
    try {
      log('Find member by id contains $id');
      return _members
          .firstWhere((member) => id != '' && member.id!.contains(id));
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> addMember(Member member) async {
    Member? newMember = await memberService.addMember(member);
    notifyListeners();
    if (newMember != null) {
      _members.add(newMember);
      notifyListeners();
    }
  }

  Future<void> updateActive(String id) async {
    log('Update active member');
    _isLoading = true;
    notifyListeners();
    final index = _members.indexWhere((m) => m.id == id);
    final member = _members[index];
    final updateMember = member.copyWith(isDeleted: !member.isDeleted);
    try {
      final updatedMember = await memberService.updateMember(updateMember);
      if (updatedMember != null) {
        _members[index] = updatedMember;
      }
    } catch (e) {
      log(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMember(Member member) async {
    _isLoading = true;
    notifyListeners();
    final updatedMember = await memberService.updateMember(member);
    if (updatedMember != null) {
      _members[_members.indexWhere((m) => m.id == member.id)] = updatedMember;
    }
    _isLoading = false;
    notifyListeners();
  }
}
