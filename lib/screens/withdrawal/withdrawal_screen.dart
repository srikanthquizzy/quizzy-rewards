import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/coin_provider.dart';
import '../../utils/app_theme.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _upiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;
  bool _hasJoinedTelegram = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void _requestWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the withdrawal terms'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    final user = authProvider.userModel;
    if (user == null) return;
    
    final minAmount = coinProvider.getMinWithdrawalAmount(user);
    
    // Check if user has enough coins
    if (user.coinBalance < minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum withdrawal amount is $minAmount coins'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    // Check withdrawal conditions for ₹100+
    if (minAmount == 1000) {
      if (user.referralAppsCompleted < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to complete at least 2 referral apps for ₹100 withdrawal'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        return;
      }
      
      if (!_hasJoinedTelegram) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to join our Telegram channel for ₹100 withdrawal'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        return;
      }
    }
    
    try {
      await coinProvider.requestWithdrawal(
        user.uid,
        user.coinBalance,
        _upiController.text.trim(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Refresh user data
      authProvider.refreshUserData();
      
      // Clear form
      _upiController.clear();
      setState(() {
        _agreedToTerms = false;
        _hasJoinedTelegram = false;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit withdrawal request: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Withdraw Coins'),
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
          
          final coinProvider = Provider.of<CoinProvider>(context, listen: false);
          final minAmount = coinProvider.getMinWithdrawalAmount(user);
          final withdrawalValue = coinProvider.getWithdrawalValue(user.coinBalance);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Withdrawal icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: AppTheme.goldColor,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Withdraw Coins',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Balance card
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
                      const Text(
                        'Your Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: AppTheme.goldColor,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${user.coinBalance} coins',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '≈ ₹${withdrawalValue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Withdrawal info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Minimum withdrawal', '$minAmount coins'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Conversion rate', '100 coins = ₹10'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Processing time', '1-3 business days'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Payment method', 'UPI only'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Withdrawal conditions for ₹100+
                if (minAmount == 1000) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.warningColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Requirements for ₹100 withdrawal:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRequirement(
                          'Complete 2 referral apps',
                          user.referralAppsCompleted >= 2,
                        ),
                        const SizedBox(height: 8),
                        _buildRequirement(
                          'Join Telegram channel',
                          user.hasJoinedTelegram,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
                
                // Withdrawal form
                if (user.coinBalance >= minAmount) ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _upiController,
                          decoration: InputDecoration(
                            labelText: 'UPI ID',
                            hintText: 'Enter your UPI ID (e.g., user@paytm)',
                            prefixIcon: const Icon(Icons.payment),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your UPI ID';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid UPI ID';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Telegram join checkbox (for ₹100+ withdrawals)
                        if (minAmount == 1000 && !user.hasJoinedTelegram) ...[
                          CheckboxListTile(
                            title: const Text('I have joined the Telegram channel'),
                            subtitle: const Text('Required for ₹100 withdrawals'),
                            value: _hasJoinedTelegram,
                            onChanged: (value) {
                              setState(() {
                                _hasJoinedTelegram = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                        
                        // Terms checkbox
                        CheckboxListTile(
                          title: const Text('I agree to the withdrawal terms'),
                          subtitle: const Text('Processing takes 1-3 business days'),
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Submit button
                        Consumer<CoinProvider>(
                          builder: (context, coinProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: coinProvider.isLoading ? null : _requestWithdrawal,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.goldColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: coinProvider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Request Withdrawal (₹${withdrawalValue.toStringAsFixed(0)})',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Insufficient balance message
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.errorColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 48,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Insufficient Balance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You need at least $minAmount coins to withdraw. Keep playing quizzes and earning coins!',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildRequirement(String requirement, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: isCompleted ? AppTheme.successColor : AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          requirement,
          style: TextStyle(
            fontSize: 14,
            color: isCompleted ? AppTheme.successColor : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}