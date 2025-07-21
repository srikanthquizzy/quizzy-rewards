class ReferralApp {
  final String name;
  final String iconUrl;
  final String link;
  final int rewardCoins;

  ReferralApp({
    required this.name,
    required this.iconUrl,
    required this.link,
    required this.rewardCoins,
  });

  factory ReferralApp.fromMap(Map<String, dynamic> map) {
    return ReferralApp(
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      link: map['link'] ?? '',
      rewardCoins: map['rewardCoins'] ?? 0,
    );
  }
}