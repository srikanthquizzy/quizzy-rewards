import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ Add this

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isLoading = true;

  // ✅ Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    _loadBannerAd();
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
          print("Banner failed to load: $error");
        },
      ),
    )..load();
  }

  Future<void> loadQuestions() async {
    final snapshot = await FirebaseFirestore.instance.collection('quiz_questions').get();
    questions = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() => isLoading = false);
  }

  void checkAnswer(int selectedIndex) async {
    final correctIndex = questions[currentIndex]['correctAnswer'];
    if (selectedIndex == correctIndex) correctAnswers++;

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      await updateCoins();
      showResult();
    }
  }

  Future<void> updateCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();
    final existingCoins = snapshot.data()?['coins'] ?? 0;

    await userDoc.update({
      'coins': existingCoins + (correctAnswers * 2), // 2 coins per correct
    });
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("You got $correctAnswers correct!\nCoins earned: ${correctAnswers * 2}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to home
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 70),
            child: Column(
              children: [
                Text("Q${currentIndex + 1}: ${question['question']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ...List.generate(question['options'].length, (index) {
                  return ListTile(
                    title: Text(question['options'][index]),
                    tileColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onTap: () => checkAnswer(index),
                  );
                }),
              ],
            ),
          ),

          // ✅ Banner Ad
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