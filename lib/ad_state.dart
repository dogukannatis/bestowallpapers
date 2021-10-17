import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdState {
  Future<InitializationStatus> initialization;
  AdState(this.initialization);

  String get bannerAdUnitId =>  "ca-app-pub-3006575161312172/8163928531";
  String get rewardedAdUnitId =>  "ca-app-pub-3006575161312172/8598192746";
  String get interstitialAdUnitId =>  "ca-app-pub-3006575161312172/7583320510";

  BannerAdListener get adListener => _adListener;
  BannerAdListener _adListener = BannerAdListener(
    onAdLoaded: (ad) => print("ad loaded: ${ad.adUnitId}."),
    onAdClosed: (ad) => print("ad closed: ${ad.adUnitId}."),
    onAdFailedToLoad: (ad,error) => print("ad failed to load: ${ad.adUnitId}, $error."),
    onAdOpened: (ad) => print("ad opened: ${ad.adUnitId}."),
  );


}
/*
 onAppEvent: (ad,name,data) => print("ad opened: ${ad.adUnitId}, $name, $data"),
    onApplicationExit: (ad) => print("ad exit: ${ad.adUnitId}."),
    onNativeAdClicked: (nativeAd) => print("Native ad clicked: ${nativeAd.adUnitId}."),
    onNativeAdImpression: (nativeAd) => print("Native ad impression: ${nativeAd.adUnitId}."),
 */