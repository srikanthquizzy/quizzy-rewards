import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:math';

import '../../providers/auth_provider.dart';
import '../../providers/coin_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/sound_service.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  bool _isSpinning = false;
  int _lastWinning = 0;
  
  final List<int> _wheelValues = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  final List<Color> _wheelColors = [
    AppTheme.errorColor,
    AppTheme.successColor,
    AppTheme.warningColor,
    AppTheme.primaryColor,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.lime,
    AppTheme.goldColor,
  ];

  void _spinWheel() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    final user = authProvider.userModel;
    if (user == null) return;
    
    if (user.spinsUsedToday >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have reached your daily spin limit (2 spins)'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isSpinning = true;
    });
    
    try {
      // Generate random result
      final random = Random();
      final winningIndex = random.nextInt(_wheelValues.length);
      final coinsWon = _wheelValues[winningIndex];
      
      setState(() {
        _lastWinning = winningIndex;
      });
      
      // Wait for spin animation
      await Future.delayed(const Duration(seconds: 3));
      
      // Add coins to user account
      if (coinsWon > 0) {
        await coinProvider.addCoins(user.uid, coinsWon, 'Spin wheel reward');
        SoundService.playCoinsSound();
      }
      
      // Update daily spin count
      await coinProvider.addCoins(user.uid, 0, 'Spin wheel used');
      
      // Show result
      _showResultDialog(coinsWon);
      
      // Refresh user data
      authProvider.refreshUserData();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to spin wheel: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isSpinning = false;
      });
    }
  }

  void _showResultDialog(int coinsWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              coinsWon > 0 ? Icons.celebration : Icons.sentiment_neutral,
              size: 64,
              color: coinsWon > 0 ? AppTheme.goldColor : AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              coinsWon > 0 ? 'Congratulations!' : 'Better luck next time!',
              style: TextStyle(
                color: coinsWon > 0 ? AppTheme.goldColor : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (coinsWon > 0) ...[
              Text(
                'You won $coinsWon coins!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Coins have been added to your account',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ] else ...[
              const Text(
                'You won 0 coins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try again tomorrow!',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Spin to Win'),
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
          
          final spinsLeft = 2 - user.spinsUsedToday;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Title
                Text(
                  'Spin the Wheel!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'Spin the wheel to win 0-10 coins!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Wheel
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: FortuneWheel(
                    selected: _isSpinning ? Stream.value(_lastWinning) : null,
                    items: _wheelValues.map((value) {
                      return FortuneItem(
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: FortuneItemStyle(
                          color: _wheelColors[_wheelValues.indexOf(value)],
                          borderColor: Colors.white,
                          borderWidth: 2,
                        ),
                      );
                    }).toList(),
                    onAnimationEnd: () {
                      print('Spin animation ended');
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Stats
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
                      _buildStatRow('Spins per day', '2'),
                      const SizedBox(height: 12),
                      _buildStatRow('Spins used today', '${user.spinsUsedToday}'),
                      const SizedBox(height: 12),
                      _buildStatRow('Spins remaining', spinsLeft.toString()),
                      const SizedBox(height: 12),
                      _buildStatRow('Possible rewards', '0-10 coins'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Spin button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (spinsLeft > 0 && !_isSpinning) ? _spinWheel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSpinning
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            spinsLeft > 0 ? 'SPIN NOW!' : 'Daily Limit Reached',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                if (spinsLeft <= 0) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Come back tomorrow for more spins!',
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