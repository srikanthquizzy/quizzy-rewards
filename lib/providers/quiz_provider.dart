import 'package:flutter/material.dart';
import 'dart:math';
import '../models/quiz_model.dart';
import '../services/firebase_service.dart';

class QuizProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  int _timeLeft = 10;
  bool _isLoading = false;
  bool _isQuizActive = false;
  QuizResult? _lastResult;

  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion? get currentQuestion => 
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  int get timeLeft => _timeLeft;
  bool get isLoading => _isLoading;
  bool get isQuizActive => _isQuizActive;
  QuizResult? get lastResult => _lastResult;
  int get totalQuestions => _questions.length;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;

  Future<void> startQuiz(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _questions = await _firebaseService.getQuizQuestions(10);
      _currentQuestionIndex = 0;
      _userAnswers = List.filled(10, null);
      _timeLeft = 10;
      _isQuizActive = true;
      _lastResult = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void answerQuestion(int answerIndex) {
    if (!_isQuizActive || _currentQuestionIndex >= _questions.length) return;
    
    _userAnswers[_currentQuestionIndex] = answerIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _timeLeft = 10;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _timeLeft = 10;
      notifyListeners();
    }
  }

  void updateTimer(int seconds) {
    _timeLeft = seconds;
    notifyListeners();
  }

  Future<QuizResult> finishQuiz(String userId) async {
    _isQuizActive = false;
    
    int correctAnswers = 0;
    List<bool> answerResults = [];
    
    for (int i = 0; i < _questions.length; i++) {
      bool isCorrect = _userAnswers[i] == _questions[i].correctAnswer;
      answerResults.add(isCorrect);
      if (isCorrect) correctAnswers++;
    }
    
    int coinsEarned = correctAnswers * 2; // 2 coins per correct answer
    
    _lastResult = QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: correctAnswers,
      coinsEarned: coinsEarned,
      completedAt: DateTime.now(),
      answers: answerResults,
    );
    
    // Update user data
    await _firebaseService.updateQuizStats(userId, _lastResult!);
    
    notifyListeners();
    return _lastResult!;
  }

  void resetQuiz() {
    _questions = [];
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _timeLeft = 10;
    _isQuizActive = false;
    _lastResult = null;
    notifyListeners();
  }
}