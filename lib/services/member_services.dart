import 'dart:developer';

import 'package:ct484_project/models/member.dart';
import 'package:ct484_project/services/pocketbase_client.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

class MemberServices {
  String _getAvatarUrl(PocketBase pb, RecordModel memberModel) {
    final avatarName = memberModel.getStringValue('avatar');
    return pb.files.getUrl(memberModel, avatarName).toString();
  }

  Future<List<Member>> getMembers() async {
    final List<Member> members = [];

    try {
      final pb = await getPocketbaseInstance();
      final memberModels = await pb.collection('members').getFullList();

      for (final memberModel in memberModels) {
        members.add(Member.fromJson(memberModel.toJson()
          ..addAll({'avatarUrl': _getAvatarUrl(pb, memberModel)})));
      }
      return members;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<Member?> addMember(Member member) async {
    try {
      final pb = await getPocketbaseInstance();
      final memberModel =
          await pb.collection('members').create(body: member.toJson(), files: [
        http.MultipartFile.fromBytes('avatar', member.avatar!.readAsBytesSync(),
            filename: member.avatar!.uri.pathSegments.last)
      ]);
      return member.copyWith(
        id: memberModel.id,
        avatarUrl: _getAvatarUrl(pb, memberModel),
      );
    } catch (e) {
      return null;
    }
  }

  Future<Member?> updateMember(Member member) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('members').update(member.id!, body: member.toJson());
      return member;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<List<Member>?> searchMember(String query) async {
    if (query.isEmpty) {
      return null; // Return null or empty list for empty query
    }

    try {
      final pb = await getPocketbaseInstance();

      final memberModels = await pb.collection('members').getFullList(
            filter: 'id~"$query"', // The filter query for searching
          );
      if (memberModels.isEmpty) {
        return null; // Return null or empty list for no results
      }
      // // Map the results to the Member model
      return memberModels
          .map((memberModel) => Member.fromJson(memberModel.toJson()
            ..addAll({'avatarUrl': _getAvatarUrl(pb, memberModel)})))
          .toList();
    } catch (e) {
      log('Error during search: ${e.toString()}');
      return null;
    }
  }
}
