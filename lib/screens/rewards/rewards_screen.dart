import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/ads_provider.dart';
import '../../providers/coin_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/sound_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool _isWatchingAd = false;

  void _watchAd() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adsProvider = Provider.of<AdsProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    final user = authProvider.userModel;
    if (user == null) return;
    
    if (user.adsWatchedToday >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have reached your daily ad limit (5 ads)'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isWatchingAd = true;
    });
    
    try {
      if (!adsProvider.isRewardedAdLoaded) {
        adsProvider.loadRewardedAd();
        await Future.delayed(const Duration(seconds: 2));
      }
      
      final adCompleted = await adsProvider.showRewardedAd();
      
      if (adCompleted) {
        await coinProvider.addCoins(user.uid, 5, 'Watched rewarded ad');
        SoundService.playCoinsSound();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 You earned 5 coins!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        authProvider.refreshUserData();
      }
      
      // Load next ad
      adsProvider.loadRewardedAd();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to watch ad: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isWatchingAd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Watch Ads & Earn'),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userModel;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final adsLeft = 5 - user.adsWatchedToday;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Ad illustration
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                  child: const Icon(
                    Icons.video_library,
                    size: 80,
                    color: AppTheme.warningColor,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Watch Ads & Earn Coins',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'Watch short video ads to earn coins instantly!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Stats card
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
                      _buildStatRow('Coins per ad', '5'),
                      const SizedBox(height: 12),
                      _buildStatRow('Daily limit', '5 ads'),
                      const SizedBox(height: 12),
                      _buildStatRow('Ads watched today', '${user.adsWatchedToday}'),
                      const SizedBox(height: 12),
                      _buildStatRow('Ads remaining', adsLeft.toString()),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Watch ad button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (adsLeft > 0 && !_isWatchingAd) ? _watchAd : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isWatchingAd
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            adsLeft > 0 ? 'Watch Ad (+5 coins)' : 'Daily Limit Reached',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Earnings summary
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.goldColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 48,
                        color: AppTheme.goldColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ad Rewards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can earn up to 25 coins per day by watching ads',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total earned today: ${user.adsWatchedToday * 5} coins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (adsLeft <= 0) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Come back tomorrow for more ads!',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}