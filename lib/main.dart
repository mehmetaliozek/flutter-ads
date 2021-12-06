import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

const int maxAttempts = 3;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BannerAd staticAd;
  bool staticAdLoaded = false;

  InterstitialAd? interstitialAd;
  int interstitialAttempts = 0;

  RewardedAd? rewardedAd;
  int rewardedAdAttempts = 0;

  static const AdRequest request = AdRequest(
      // keywords: ["", ""],
      // contentUrl: "",
      // nonPersonalizedAds: false,
      );

  void loadStaticBannerAd() {
    staticAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            staticAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          // ignore: avoid_print
          print("ad failed to load ${error.message}");
        },
      ),
    );

    staticAd.load();
  }

  void createInterstialAd() {
    InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          interstitialAttempts++;
          interstitialAd = null;

          // ignore: avoid_print
          print("ad failed to load ${error.message}");

          if (interstitialAttempts <= maxAttempts) {
            createInterstialAd();
          }
        },
      ),
    );
  }

  void showInterstialAd() {
    if (interstitialAd == null) {
      // ignore: avoid_print
      print("trying to show before loading");
      return;
    }

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        // ignore: avoid_print
        onAdShowedFullScreenContent: (ad) => print("ad showed $ad"),
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          createInterstialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();

          // ignore: avoid_print
          print("failed to show the ad $ad");

          createInterstialAd();
        });

    interstitialAd!.show();
    interstitialAd = null;
  }

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: RewardedAd.testAdUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          rewardedAdAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          rewardedAdAttempts++;
          rewardedAd = null;

          // ignore: avoid_print
          print("ad failed to load ${error.message}");

          if (rewardedAdAttempts <= maxAttempts) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd() {
    if (rewardedAd == null) {
      // ignore: avoid_print
      print("trying to show before loading");
      return;
    }

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        // ignore: avoid_print
        onAdShowedFullScreenContent: (ad) => print("ad showed $ad"),
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          createRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();

          // ignore: avoid_print
          print("failed to show the ad $ad");

          createRewardedAd();
        });

    rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      // ignore: avoid_print
      print("reward video ${reward.amount} ${reward.type}");
    });
    rewardedAd = null;
  }

  @override
  void initState() {
    loadStaticBannerAd();
    createInterstialAd();
    createRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Test"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                if (staticAdLoaded)
                  Container(
                    child: AdWidget(ad: staticAd),
                    width: staticAd.size.width.toDouble(),
                    height: staticAd.size.height.toDouble(),
                    alignment: Alignment.center,
                  ),
                ElevatedButton(
                  onPressed: () {
                    showInterstialAd();
                  },
                  child: const Text("Show AD"),
                ),
                ElevatedButton(
                  onPressed: () {
                    showRewardedAd();
                  },
                  child: const Text("Show Reward AD"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
