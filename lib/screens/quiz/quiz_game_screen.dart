import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ads_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/sound_service.dart';
import 'quiz_result_screen.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  Timer? _timer;
  int _selectedAnswer = -1;
  bool _hasAnswered = false;
  bool _showCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        
        if (quizProvider.timeLeft == 0) {
          timer.cancel();
          _timeUp();
        } else {
          quizProvider.updateTimer(quizProvider.timeLeft - 1);
        }
      },
    );
  }

  void _timeUp() {
    if (!_hasAnswered) {
      setState(() {
        _hasAnswered = true;
        _showCorrectAnswer = true;
      });
      
      SoundService.playWrongSound();
      
      Timer(const Duration(seconds: 2), () {
        _nextQuestion();
      });
    }
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;
    
    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      _showCorrectAnswer = true;
    });
    
    _timer?.cancel();
    
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final currentQuestion = quizProvider.currentQuestion;
    
    if (currentQuestion != null) {
      quizProvider.answerQuestion(index);
      
      // Play sound
      if (index == currentQuestion.correctAnswer) {
        SoundService.playCorrectSound();
      } else {
        SoundService.playWrongSound();
      }
    }
    
    Timer(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final adsProvider = Provider.of<AdsProvider>(context, listen: false);
    
    if (quizProvider.isLastQuestion) {
      // Show ad before result
      if (adsProvider.isInterstitialAdLoaded) {
        await adsProvider.showInterstitialAd();
      }
      
      // Finish quiz
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await quizProvider.finishQuiz(authProvider.userModel!.uid);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(result: result),
          ),
        );
      }
    } else {
      // Show ad before question 6
      if (quizProvider.currentQuestionIndex == 4 && adsProvider.isInterstitialAdLoaded) {
        await adsProvider.showInterstitialAd();
      }
      
      setState(() {
        _selectedAnswer = -1;
        _hasAnswered = false;
        _showCorrectAnswer = false;
      });
      
      quizProvider.nextQuestion();
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            final currentQuestion = quizProvider.currentQuestion;
            
            if (currentQuestion == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Question counter
                      Text(
                        'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: quizProvider.timeLeft <= 3 
                              ? AppTheme.errorColor 
                              : AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          quizProvider.timeLeft.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress bar
                LinearProgressIndicator(
                  value: (quizProvider.currentQuestionIndex + 1) / quizProvider.totalQuestions,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                
                // Question
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Question card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentQuestion.options.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOptionCard(
                                  currentQuestion.options[index],
                                  index,
                                  currentQuestion.correctAnswer,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Banner Ad
                Consumer<AdsProvider>(
                  builder: (context, adsProvider, child) {
                    if (adsProvider.isBannerAdLoaded && adsProvider.bannerAd != null) {
                      return Container(
                        alignment: Alignment.center,
                        width: adsProvider.bannerAd!.size.width.toDouble(),
                        height: adsProvider.bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: adsProvider.bannerAd!),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard(String option, int index, int correctAnswer) {
    Color cardColor = Colors.white;
    Color textColor = AppTheme.textPrimary;
    IconData? icon;
    
    if (_showCorrectAnswer) {
      if (index == correctAnswer) {
        cardColor = AppTheme.successColor;
        textColor = Colors.white;
        icon = Icons.check_circle;
      } else if (index == _selectedAnswer && index != correctAnswer) {
        cardColor = AppTheme.errorColor;
        textColor = Colors.white;
        icon = Icons.cancel;
      }
    } else if (_selectedAnswer == index) {
      cardColor = AppTheme.primaryColor.withOpacity(0.1);
      textColor = AppTheme.primaryColor;
    }
    
    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedAnswer == index && !_showCorrectAnswer
                ? AppTheme.primaryColor
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}