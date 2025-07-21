import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static RewardedAd? _rewardedAd;

  static void loadRewardedAd(Function onRewardEarned) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) => onRewardEarned(),
          );
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }
}