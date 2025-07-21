import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsProvider extends ChangeNotifier {
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isBannerAdLoaded = false;
  
  // Test Ad Unit IDs - Replace with your actual Ad Unit IDs
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          _isRewardedAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          _isInterstitialAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
        },
      ),
    );
    _bannerAd?.load();
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null || !_isRewardedAdLoaded) {
      return false;
    }

    bool adCompleted = false;
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('RewardedAd showed fullscreen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('RewardedAd dismissed fullscreen content');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        notifyListeners();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('RewardedAd failed to show fullscreen content: $error');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        notifyListeners();
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      print('User earned reward: ${reward.amount} ${reward.type}');
      adCompleted = true;
    });

    return adCompleted;
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null || !_isInterstitialAdLoaded) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('InterstitialAd showed fullscreen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('InterstitialAd dismissed fullscreen content');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        notifyListeners();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('InterstitialAd failed to show fullscreen content: $error');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        notifyListeners();
      },
    );

    await _interstitialAd!.show();
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}