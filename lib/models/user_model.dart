import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final int coinBalance;
  final String referralCode;
  final String? referredBy;
  final DateTime createdAt;
  final DateTime lastQuizDate;
  final int quizzesPlayedToday;
  final int adsWatchedToday;
  final int spinsUsedToday;
  final bool hasJoinedTelegram;
  final int referralAppsCompleted;
  final List<String> completedReferralApps;
  final Map<String, dynamic> quizHistory;
  final List<Map<String, dynamic>> withdrawalRequests;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.coinBalance = 25,
    required this.referralCode,
    this.referredBy,
    required this.createdAt,
    required this.lastQuizDate,
    this.quizzesPlayedToday = 0,
    this.adsWatchedToday = 0,
    this.spinsUsedToday = 0,
    this.hasJoinedTelegram = false,
    this.referralAppsCompleted = 0,
    this.completedReferralApps = const [],
    this.quizHistory = const {},
    this.withdrawalRequests = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      coinBalance: map['coinBalance'] ?? 25,
      referralCode: map['referralCode'] ?? '',
      referredBy: map['referredBy'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastQuizDate: (map['lastQuizDate'] as Timestamp).toDate(),
      quizzesPlayedToday: map['quizzesPlayedToday'] ?? 0,
      adsWatchedToday: map['adsWatchedToday'] ?? 0,
      spinsUsedToday: map['spinsUsedToday'] ?? 0,
      hasJoinedTelegram: map['hasJoinedTelegram'] ?? false,
      referralAppsCompleted: map['referralAppsCompleted'] ?? 0,
      completedReferralApps: List<String>.from(map['completedReferralApps'] ?? []),
      quizHistory: Map<String, dynamic>.from(map['quizHistory'] ?? {}),
      withdrawalRequests: List<Map<String, dynamic>>.from(map['withdrawalRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'coinBalance': coinBalance,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastQuizDate': Timestamp.fromDate(lastQuizDate),
      'quizzesPlayedToday': quizzesPlayedToday,
      'adsWatchedToday': adsWatchedToday,
      'spinsUsedToday': spinsUsedToday,
      'hasJoinedTelegram': hasJoinedTelegram,
      'referralAppsCompleted': referralAppsCompleted,
      'completedReferralApps': completedReferralApps,
      'quizHistory': quizHistory,
      'withdrawalRequests': withdrawalRequests,
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    int? coinBalance,
    String? referralCode,
    String? referredBy,
    DateTime? createdAt,
    DateTime? lastQuizDate,
    int? quizzesPlayedToday,
    int? adsWatchedToday,
    int? spinsUsedToday,
    bool? hasJoinedTelegram,
    int? referralAppsCompleted,
    List<String>? completedReferralApps,
    Map<String, dynamic>? quizHistory,
    List<Map<String, dynamic>>? withdrawalRequests,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      coinBalance: coinBalance ?? this.coinBalance,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      createdAt: createdAt ?? this.createdAt,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      quizzesPlayedToday: quizzesPlayedToday ?? this.quizzesPlayedToday,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      spinsUsedToday: spinsUsedToday ?? this.spinsUsedToday,
      hasJoinedTelegram: hasJoinedTelegram ?? this.hasJoinedTelegram,
      referralAppsCompleted: referralAppsCompleted ?? this.referralAppsCompleted,
      completedReferralApps: completedReferralApps ?? this.completedReferralApps,
      quizHistory: quizHistory ?? this.quizHistory,
      withdrawalRequests: withdrawalRequests ?? this.withdrawalRequests,
    );
  }
}