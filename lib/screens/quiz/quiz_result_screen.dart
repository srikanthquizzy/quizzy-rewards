import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/quiz_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/sound_service.dart';
import '../home/home_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;

  const QuizResultScreen({super.key, required this.result});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    SoundService.playResultSound();
    _refreshUserData();
    _loadInterstitialAd();
  }

  void _refreshUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.refreshUserData();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1932081965171538/6587361513',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showAdThenNavigate(VoidCallback onFinished) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Preload for next time
          onFinished();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          onFinished();
        },
      );
      _interstitialAd!.show();
    } else {
      onFinished();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.result.percentage;
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result Animation
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: isExcellent
                      ? AppTheme.successColor
                      : isGood
                          ? AppTheme.warningColor
                          : AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(75),
                  boxShadow: [
                    BoxShadow(
                      color: (isExcellent
                              ? AppTheme.successColor
                              : isGood
                                  ? AppTheme.warningColor
                                  : AppTheme.errorColor)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isExcellent
                      ? Icons.emoji_events
                      : isGood
                          ? Icons.thumb_up
                          : Icons.thumb_down,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isExcellent
                    ? 'Excellent!'
                    : isGood
                        ? 'Good Job!'
                        : 'Keep Trying!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.toInt()}%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildStatRow('Correct Answers',
                        '${widget.result.correctAnswers}/${widget.result.totalQuestions}'),
                    const SizedBox(height: 12),
                    _buildStatRow('Coins Earned',
                        '${widget.result.coinsEarned}'),
                    const SizedBox(height: 12),
                    _buildStatRow('Completion Time', _formatTime()),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (widget.result.coinsEarned > 0) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.goldColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppTheme.goldColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '+${widget.result.coinsEarned} Coins Earned!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showAdThenNavigate(() {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Home',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showAdThenNavigate(() {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Play Again',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  String _formatTime() {
    final now = DateTime.now();
    final diff = now.difference(widget.result.completedAt);
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
  }
}