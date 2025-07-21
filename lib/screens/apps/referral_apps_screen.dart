import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/coin_provider.dart';
import '../../models/referral_app_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';

class ReferralAppsScreen extends StatefulWidget {
  const ReferralAppsScreen({super.key});

  @override
  State<ReferralAppsScreen> createState() => _ReferralAppsScreenState();
}

class _ReferralAppsScreenState extends State<ReferralAppsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<ReferralApp> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferralApps();
  }

  Future<void> _loadReferralApps() async {
    try {
      final apps = await _firebaseService.getReferralApps();
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load apps: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _installApp(ReferralApp app) async {
    try {
      final uri = Uri.parse(app.deepLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        
        // Show confirmation dialog
        _showInstallConfirmationDialog(app);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open app store'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open app: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showInstallConfirmationDialog(ReferralApp app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('App Installation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Did you successfully install and open the app?'),
            const SizedBox(height: 8),
            Text(
              'You will earn ${app.coinsReward} coins for this installation.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _claimReward(app);
            },
            child: const Text('Yes, I Installed It'),
          ),
        ],
      ),
    );
  }

  Future<void> _claimReward(ReferralApp app) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    final user = authProvider.userModel;
    if (user == null) return;
    
    // Check if user already completed this app
    if (user.completedReferralApps.contains(app.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already completed this app'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    try {
      // Add coins and mark app as completed
      await coinProvider.addCoins(user.uid, app.coinsReward, 'Referral app: ${app.name}');
      await _firebaseService.completeReferralApp(user.uid, app.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 You earned ${app.coinsReward} coins!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Refresh user data
      authProvider.refreshUserData();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim reward: ${e.toString()}'),
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
        title: const Text('Install Apps & Earn'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.userModel;
                
                if (user == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.apps,
                          size: 60,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Install Apps & Earn',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Install the apps below and earn coins instantly!',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Apps list
                      if (_apps.isEmpty) ...[
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
                          child: const Column(
                            children: [
                              Icon(
                                Icons.apps_outlined,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Apps Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Check back later for new apps to install',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _apps.length,
                          itemBuilder: (context, index) {
                            final app = _apps[index];
                            final isCompleted = user.completedReferralApps.contains(app.id);
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAppCard(app, isCompleted),
                            );
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Progress card
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
                              Icons.task_alt,
                              size: 48,
                              color: AppTheme.goldColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Apps Completed: ${user.referralAppsCompleted}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.goldColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Complete 2 apps to unlock ₹100 withdrawals',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAppCard(ReferralApp app, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // App icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: app.iconUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      app.iconUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.apps,
                          size: 32,
                          color: AppTheme.primaryColor,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.apps,
                    size: 32,
                    color: AppTheme.primaryColor,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // App info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: AppTheme.goldColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${app.coinsReward} coins',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action button
          SizedBox(
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: isCompleted ? null : () => _installApp(app),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCompleted ? 'Done' : 'Install',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}