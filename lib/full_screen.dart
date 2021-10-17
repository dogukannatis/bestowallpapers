import 'dart:typed_data';

import 'package:bestwallpapers/ad_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FullScreen extends StatefulWidget {
  final String? imageurl;
  final String? originalUrl;
  final String? ultraUrl;
  final String? largeUrl;
  final String? mediumUrl;
  final String? smallUrl;


  const FullScreen({Key? key, this.imageurl, this.originalUrl, this.ultraUrl, this.largeUrl, this.mediumUrl, this.smallUrl}) : super(key: key);
  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  bool isLoading = false;
  var status;
  Key _scaffoldKey = GlobalKey<ScaffoldState>();
  BannerAd? banner;
  RewardedAd? rewardedAd;
  InterstitialAd? interstitialAd;
  bool _isRewardedAdReady = false;
  bool _isInterstitialAdReady = false;


  @override
  void dispose() {
    rewardedAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status){
      setState(() {
        banner = BannerAd(
            adUnitId: adState.bannerAdUnitId,
            size: AdSize.banner,
            request: AdRequest(),
            listener: adState.adListener
        )..load();

        //_loadRewardedAd();

      });
    });
  }

  void _loadInterstitialAd() {
    final adState = Provider.of<AdState>(context, listen: false);
    InterstitialAd.load(
      adUnitId: adState.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this.interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.pop(context);
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _loadRewardedAd(){
    final adState = Provider.of<AdState>(context, listen: false);
    RewardedAd.load(
        adUnitId: adState.rewardedAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad){
              rewardedAd = ad;
              ad.fullScreenContentCallback = FullScreenContentCallback(
                  onAdDismissedFullScreenContent: (ad){
                    setState(() {
                      _isRewardedAdReady = false;
                    });
                    _loadRewardedAd();
                  }
              );
              setState(() {
                _isRewardedAdReady = true;
              });
            },
            onAdFailedToLoad: (error){
              print("Failed to load a rewarded ad: " + error.message);
              setState(() {
                _isRewardedAdReady = false;
              });
            }
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Container(
          child: Column(
            children: [
               Expanded(
                 child: Container(
                    child: Image.network(widget.imageurl!),
                  ),
               ),

              if(banner == null)
                SizedBox(height: 5)
              else
                Container(
                  height: 50,
                  child: AdWidget(
                    ad: banner!,
                  ),
                ),
              SizedBox(height: 20,),
              InkWell(
                onTap: () async{
                  showBarModalBottomSheet(
                      context: context,
                      builder: (context){
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: (){
                                _loadRewardedAd();

                                if(_isRewardedAdReady){
                                  Navigator.pop(context);
                                  rewardedAd!.show(onUserEarnedReward: (rew,item){
                                    print("başarılı");
                                    _download(widget.originalUrl!);
                                  });
                                }

                              },
                              title: Text("Original Download"),
                              leading: Icon(Icons.download, color: Colors.orange,),
                            ),
                            ListTile(
                              onTap: (){
                                _loadRewardedAd();

                                if(_isRewardedAdReady){
                                  Navigator.pop(context);
                                  rewardedAd!.show(onUserEarnedReward: (rew,item){
                                    print("başarılı");
                                    _download(widget.ultraUrl!);
                                  });
                                }

                              },
                              title: Text("Ultra Download"),
                              leading: Icon(Icons.download, color: Colors.orange),
                            ),
                            ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                _download(widget.largeUrl!);
                              },
                              title: Text("Large Download"),
                              leading: Icon(Icons.download),
                            ),
                            ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                _download(widget.mediumUrl!);
                              },
                              title: Text("Medium Download"),
                              leading: Icon(Icons.download),
                            ),
                            ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                _download(widget.smallUrl!);
                              },
                              title: Text("Small Download"),
                              leading: Icon(Icons.download),
                            ),
                            SizedBox(
                              height: 30,
                            )
                          ],
                        );
                      }
                  );
                },
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: isLoading ? CircularProgressIndicator(color: Colors.white,) :
                    Text('Download', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              )
            ],
          )),
    );
  }

  void _download(String url) async{

    if(await _requestPermission(Permission.storage)) {
      setState(() {
         isLoading = true;
      });
      var response = await Dio().get(
          url,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          );

      print(result);
      if(result["isSuccess"] == true){
        print("başarılı");
        final snackBar = SnackBar(content: Text("Picture saved succesfully! "));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }else{
        print(result["errorMessage"]);
        final snackBarError = SnackBar(content: Text("Picture could not saved! "));
        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
      }
      setState(() {
        isLoading = false;
      });
    }

  }
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

}