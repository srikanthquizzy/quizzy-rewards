import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String phone;
  final int coinBalance;
  final int referralAppsCompleted;
  final bool hasJoinedTelegram;
  final bool firstWithdrawalDone;

  UserModel({
    required this.uid,
    required this.phone,
    required this.coinBalance,
    required this.referralAppsCompleted,
    required this.hasJoinedTelegram,
    required this.firstWithdrawalDone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      phone: map['phone'] ?? '',
      coinBalance: map['coins'] ?? 0,
      referralAppsCompleted: map['referralAppsCompleted'] ?? 0,
      hasJoinedTelegram: map['hasJoinedTelegram'] ?? false,
      firstWithdrawalDone: map['firstWithdrawalDone'] ?? false,
    );
  }
}

class AuthProvider with ChangeNotifier {
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, user.uid);
        notifyListeners();
      }
    }
  }

  Future<void> refreshUserData() async {
    await fetchUserData();
  }
}