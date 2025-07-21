import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String phone = '';
  int coins = 0;
  bool isLoading = true;

  // 👇 AdMob
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadBannerAd(); // Load banner ad
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1932081965171538/3692732727',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Banner Ad failed: $error");
        },
      ),
    )..load();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          phone = data?['phone'] ?? '';
          coins = data?['coins'] ?? 0;
          isLoading = false;
        });
      }
    }
  }

  void _showInterstitialAndStartQuiz() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1932081965171538/6587361513',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              Navigator.pushNamed(context, '/quiz');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              Navigator.pushNamed(context, '/quiz');
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          Navigator.pushNamed(context, '/quiz');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzy Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Back to login
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Welcome, $phone', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      Text('Your Coins: $coins 🪙',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),

                      // 🎯 Play Quiz
                      ElevatedButton.icon(
                        icon: const Icon(Icons.quiz),
                        label: const Text("Play Quiz"),
                        onPressed: _showInterstitialAndStartQuiz,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🎥 Watch Ads to Earn Coins
                      ElevatedButton.icon(
                        icon: const Icon(Icons.ondemand_video),
                        label: const Text("Watch Ad to Earn 5 Coins"),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
                            final doc = await ref.get();
                            String today = DateTime.now().toIso8601String().split('T')[0];
                            int adsWatched = 0;

                            if (doc.exists) {
                              String adsLastWatched = doc['adsLastWatched'] ?? '';
                              if (adsLastWatched == today) {
                                adsWatched = doc['adsWatched'] ?? 0;
                              }
                            }

                            if (adsWatched >= 5) {
                              showDialog(
                                context: context,
                                builder: (_) => const AlertDialog(
                                  title: Text("Limit Reached"),
                                  content: Text("You can only watch 5 ads per day.\nTry again tomorrow."),
                                ),
                              );
                              return;
                            }

                            final ad = RewardedAd(
                              adUnitId: 'ca-app-pub-1932081965171538/9213524858',
                              request: const AdRequest(),
                              listener: RewardedAdListener(
                                onUserEarnedReward: (ad, reward) async {
                                  final newCoins = (doc['coins'] ?? 0) + 5;
                                  await ref.set({
                                    'coins': newCoins,
                                    'adsWatched': adsWatched + 1,
                                    'adsLastWatched': today,
                                  }, SetOptions(merge: true));

                                  setState(() {
                                    coins = newCoins;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("You've earned 5 coins 🎉")),
                                  );
                                },
                                onAdFailedToLoad: (ad, err) => ad.dispose(),
                                onAdDismissedFullScreenContent: (ad) => ad.dispose(),
                              ),
                            );

                            await ad.load();
                            ad.show(onUserEarnedReward: (ad, reward) {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🎡 Spin to Win
                      ElevatedButton.icon(
                        icon: const Icon(Icons.casino),
                        label: const Text("Spin to Win"),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
                            final doc = await ref.get();
                            String today = DateTime.now().toIso8601String().split('T')[0];
                            int spinCount = 0;

                            if (doc.exists) {
                              String lastSpin = doc['lastSpinDate'] ?? '';
                              if (lastSpin == today) {
                                spinCount = doc['spinCount'] ?? 0;
                              }
                            }

                            if (spinCount >= 2) {
                              showDialog(
                                context: context,
                                builder: (_) => const AlertDialog(
                                  title: Text("Limit Reached"),
                                  content: Text("You already used your 2 spins today.\nCome back tomorrow!"),
                                ),
                              );
                              return;
                            }

                            List<int> rewards = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
                            rewards.shuffle();
                            int reward = rewards.first;

                            int currentCoins = doc['coins'] ?? 0;
                            await ref.set({
                              'coins': currentCoins + reward,
                              'spinCount': spinCount + 1,
                              'lastSpinDate': today,
                            }, SetOptions(merge: true));

                            setState(() {
                              coins = currentCoins + reward;
                            });

                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Spin Result"),
                                content: Text("You earned 🪙 $reward coins!"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                // Banner Ad (bottom)
                if (_isBannerAdLoaded)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
              ],
            ),
    );
  }
}