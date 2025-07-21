import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:math';

import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/referral_app_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // User Management
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Quiz Management
  Future<List<QuizQuestion>> getQuizQuestions(int count) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_questions')
          .where('isActive', isEqualTo: true)
          .limit(count * 2) // Get more questions to randomize
          .get();

      List<QuizQuestion> questions = snapshot.docs
          .map((doc) => QuizQuestion.fromMap(doc.data()))
          .toList();

      // Shuffle and return requested count
      questions.shuffle();
      return questions.take(count).toList();
    } catch (e) {
      print('Error fetching quiz questions: $e');
      return _getDefaultQuestions(count);
    }
  }

  List<QuizQuestion> _getDefaultQuestions(int count) {
    // Default questions in case Firebase fetch fails
    return [
      QuizQuestion(
        id: '1',
        question: 'What is the capital of India?',
        options: ['Mumbai', 'Delhi', 'Kolkata', 'Chennai'],
        correctAnswer: 1,
        category: 'Geography',
        difficulty: 'easy',
      ),
      QuizQuestion(
        id: '2',
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        category: 'Science',
        difficulty: 'easy',
      ),
      QuizQuestion(
        id: '3',
        question: 'Who wrote "Romeo and Juliet"?',
        options: ['Charles Dickens', 'William Shakespeare', 'Mark Twain', 'Jane Austen'],
        correctAnswer: 1,
        category: 'Literature',
        difficulty: 'medium',
      ),
      QuizQuestion(
        id: '4',
        question: 'What is the largest mammal in the world?',
        options: ['African Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus'],
        correctAnswer: 1,
        category: 'Science',
        difficulty: 'easy',
      ),
      QuizQuestion(
        id: '5',
        question: 'Which year did India gain independence?',
        options: ['1945', '1947', '1948', '1950'],
        correctAnswer: 1,
        category: 'History',
        difficulty: 'easy',
      ),
      QuizQuestion(
        id: '6',
        question: 'What is the chemical symbol for gold?',
        options: ['Go', 'Gd', 'Au', 'Ag'],
        correctAnswer: 2,
        category: 'Science',
        difficulty: 'medium',
      ),
      QuizQuestion(
        id: '7',
        question: 'Which is the smallest country in the world?',
        options: ['Monaco', 'Vatican City', 'San Marino', 'Liechtenstein'],
        correctAnswer: 1,
        category: 'Geography',
        difficulty: 'medium',
      ),
      QuizQuestion(
        id: '8',
        question: 'Who invented the telephone?',
        options: ['Thomas Edison', 'Alexander Graham Bell', 'Nikola Tesla', 'Benjamin Franklin'],
        correctAnswer: 1,
        category: 'Science',
        difficulty: 'medium',
      ),
      QuizQuestion(
        id: '9',
        question: 'What is the currency of Japan?',
        options: ['Yuan', 'Won', 'Yen', 'Ringgit'],
        correctAnswer: 2,
        category: 'Geography',
        difficulty: 'easy',
      ),
      QuizQuestion(
        id: '10',
        question: 'Which gas makes up most of the Earth\'s atmosphere?',
        options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
        correctAnswer: 2,
        category: 'Science',
        difficulty: 'medium',
      ),
    ].take(count).toList();
  }

  Future<void> updateQuizStats(String userId, QuizResult result) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    await _firestore.collection('users').doc(userId).update({
      'lastQuizDate': Timestamp.fromDate(today),
      'quizzesPlayedToday': FieldValue.increment(1),
      'coinBalance': FieldValue.increment(result.coinsEarned),
      'quizHistory.${result.completedAt.millisecondsSinceEpoch}': result.toMap(),
    });
  }

  // Coin Management
  Future<void> addCoins(String userId, int coins, String reason) async {
    await _firestore.collection('users').doc(userId).update({
      'coinBalance': FieldValue.increment(coins),
    });

    // Log transaction
    await _firestore.collection('coin_transactions').add({
      'userId': userId,
      'amount': coins,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestWithdrawal(String userId, int coins, String upiId) async {
    final request = {
      'userId': userId,
      'amount': coins,
      'upiId': upiId,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('withdrawal_requests').add(request);
    
    // Update user's withdrawal requests
    await _firestore.collection('users').doc(userId).update({
      'withdrawalRequests': FieldValue.arrayUnion([request]),
    });
  }

  // Referral System
  Future<void> processReferralReward(String referralCode, String newUserId) async {
    try {
      // Find user with the referral code
      final querySnapshot = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final referrerDoc = querySnapshot.docs.first;
        final referrerId = referrerDoc.id;

        // Give 50 coins to referrer
        await addCoins(referrerId, 50, 'Referral bonus');

        // Give 25 coins to new user (already done in user creation)
        await addCoins(newUserId, 25, 'Welcome bonus');
      }
    } catch (e) {
      print('Error processing referral reward: $e');
    }
  }

  // Referral Apps
  Future<List<ReferralApp>> getReferralApps() async {
    try {
      final snapshot = await _firestore
          .collection('referral_apps')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      return snapshot.docs
          .map((doc) => ReferralApp.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching referral apps: $e');
      return [];
    }
  }

  Future<void> completeReferralApp(String userId, String appId) async {
    await _firestore.collection('users').doc(userId).update({
      'completedReferralApps': FieldValue.arrayUnion([appId]),
      'referralAppsCompleted': FieldValue.increment(1),
    });
  }

  // Spin Wheel
  Future<int> spinWheel(String userId) async {
    final random = Random();
    final coins = random.nextInt(11); // 0-10 coins

    await _firestore.collection('users').doc(userId).update({
      'spinsUsedToday': FieldValue.increment(1),
      'coinBalance': FieldValue.increment(coins),
    });

    return coins;
  }

  // Daily Reset
  Future<void> resetDailyLimits(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    await _firestore.collection('users').doc(userId).update({
      'lastQuizDate': Timestamp.fromDate(today),
      'quizzesPlayedToday': 0,
      'adsWatchedToday': 0,
      'spinsUsedToday': 0,
    });
  }

  // FCM Token Management
  Future<void> updateFCMToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}