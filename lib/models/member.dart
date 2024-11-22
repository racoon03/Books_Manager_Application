import 'dart:io';

import 'package:intl/intl.dart';

class Member {
  final String? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String citizenId;
  final File? avatar;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime membershipDate;
  final DateTime expirationDate;
  final int total;
  final bool isDeleted;

  Member(
      {this.id,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.email,
      required this.citizenId,
      this.avatar,
      required this.avatarUrl,
      required this.createdAt,
      required this.membershipDate,
      required this.expirationDate,
      required this.total,
      required this.isDeleted});

  copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? citizenId,
    File? avatar,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? membershipDate,
    DateTime? expirationDate,
    int? total,
    bool? isDeleted,
  }) {
    return Member(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        citizenId: citizenId ?? this.citizenId,
        avatar: avatar ?? this.avatar,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
        membershipDate: membershipDate ?? this.membershipDate,
        expirationDate: expirationDate ?? this.expirationDate,
        total: total ?? this.total,
        isDeleted: isDeleted ?? this.isDeleted);
  }

  factory Member.defaultMember() {
    return Member(
        id: '',
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        citizenId: '',
        avatarUrl: '',
        createdAt: DateTime.now(),
        membershipDate: DateTime.now(),
        expirationDate: DateTime.now(),
        total: 0,
        isDeleted: false); // Adjust as necessary
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      citizenId: json['citizenId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      membershipDate:
          DateTime.tryParse(json['membershipDate'] as String? ?? '') ??
              DateTime.now(),
      expirationDate:
          DateTime.tryParse(json['expirationDate'] as String? ?? '') ??
              DateTime.now(),
      total: json['total'] ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'citizenId': citizenId,
      'createdAt': createdAt.toIso8601String(),
      'membershipDate': membershipDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'total': total,
      'isDeleted': isDeleted,
    };
  }

  bool hasAvatar() {
    return avatar != null || avatarUrl.isNotEmpty;
  }

  String getFormattedExpireDate() {
    return DateFormat('dd-MM-yyyy – kk:mm').format(expirationDate);
  }

  String getFormattedMembershipDate() {
    return DateFormat('dd-MM-yyyy – kk:mm').format(membershipDate);
  }

  String getFormattedCreatedAt() {
    return DateFormat('dd-MM-yyyy – kk:mm').format(createdAt);
  }

  String getFormattedTotal() {
    return NumberFormat.currency(locale: 'vi').format(total);
  }
}
