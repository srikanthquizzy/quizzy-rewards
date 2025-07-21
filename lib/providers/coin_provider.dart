import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoinProvider with ChangeNotifier {
  bool isLoading = false;

  /// Get minimum withdrawal amount based on user data
  int getMinWithdrawalAmount(user) {
    return user.firstWithdrawalDone ? 1000 : 100;
  }

  /// Convert coins to rupees
  double getWithdrawalValue(int coins) {
    return (coins / 100) * 10; // 100 coins = ₹10
  }

  /// Request withdrawal logic
  Future<void> requestWithdrawal(String uid, int coins, String upiId) async {
    isLoading = true;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Save withdrawal request to Firestore
      await firestore.collection('withdrawals').add({
        'uid': uid,
        'upiId': upiId,
        'coins': coins,
        'amount': getWithdrawalValue(coins),
        'status': 'pending',
        'requestedAt': now.toIso8601String(),
      });

      // Reset user coin balance
      await firestore.collection('users').doc(uid).update({
        'coins': 0,
        'firstWithdrawalDone': true,
      });

    } catch (e) {
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }
}