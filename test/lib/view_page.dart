import 'dart:io';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nowonbokji/browser.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class ViewPage extends StatefulWidget {

  final ChromeSafariBrowser browser = new MyChromeSafariBrowser(new MyInAppBrowser());

  @override
  _ViewPageState createState() => _ViewPageState();
}


class _ViewPageState extends State<ViewPage> {

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  InAppWebViewController webView;
  InAppWebViewController _webViewPopupController;


  String url = "";
  String version = "";
  double progress = 0;


  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();




  @override
  void initState(){
    super.initState();
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print('==================================token==================================');
      print(token);
    });

    _firebaseMessaging.configure(
      onLaunch: (message) async {

        if(Platform.isAndroid){
          Alert(context: context,
              title: '${message['notification']['title']}',
              desc: '${message['notification']['body']}')
              .show();
        }
        if(Platform.isIOS){
          Alert(context: context,
              title: '${message['title']}',
              desc: '${message['body']}')
              .show();
        }

      },

      onResume: (message) async {
        if(Platform.isAndroid){
          Alert(context: context,
              title: '${message['notification']['title']}',
              desc: '${message['notification']['body']}')
              .show();
        }
        if(Platform.isIOS){
          Alert(context: context,
              title: '${message['title']}',
              desc: '${message['body']}')
              .show();
        }
      },

      onMessage:(message) async {
        if(Platform.isAndroid){
          Alert(context: context,
              title: '${message['notification']['title']}',
              desc: '${message['notification']['body']}')
              .show();
        }
        if(Platform.isIOS){
          Alert(context: context,
              title: '${message['title']}',
              desc: '${message['body']}')
              .show();
        }
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }


  Future<bool> _exitApp(BuildContext context) async {
    if (await webView.canGoBack()) {
      webView.goBack();
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("?????? ?????? ???????????????????"),
          actions: <Widget>[
            FlatButton(
              child: Text("?????????"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("???"),
              onPressed: () => Navigator.pop(context, true),

            ),
          ],
        ),
      ) ??
          false;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: InAppWebView(
//              https://allince.members.markets
            initialUrl: "https://nowonsenior.or.kr/",
            initialHeaders: {},
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                debuggingEnabled: true,
                useShouldOverrideUrlLoading: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
            ),

            shouldOverrideUrlLoading: (InAppWebViewController controller, request) async {
              var url = request.url;
              var uri = Uri.parse(url);

              if (!["http", "https", "file",
                "chrome", "data", "javascript",
                "about",].contains(uri.scheme)) {
                if (await canLaunch(url)) {
                  // Launch the App
                  await launch(
                    url,
                  );
                  // and cancel the request
                  return ShouldOverrideUrlLoadingAction.CANCEL;
                }
              }

              return ShouldOverrideUrlLoadingAction.ALLOW;
            },

            onWebViewCreated: (InAppWebViewController controller) async {

              webView = controller;

              // ??? ?????? ?????? ??? ??????
              controller.addJavaScriptHandler(handlerName: "Jchannel_Info", callback: (args) async {

                String lat = null;
                String long = null;
                String gubun = "app";

                var arr = new List(3);
                arr[0] = gubun;
                arr[1] = lat;
                arr[2] = long;

                return arr;
              });

              // ????????? ??? ??????
              controller.addJavaScriptHandler(handlerName: "Jchannel_Login", callback: (args) async {


                final prefs = await SharedPreferences.getInstance();

                // ??? ????????????
                prefs.setString('userId', args.toString());

                // ??? ????????????
                final id = prefs.getString('userId') ?? 0;

                print("???????????? ?????? ?????????........");
                print(id);

              });

              //?????? ?????? ?????????
              controller.addJavaScriptHandler(handlerName: "Jchannel_UserData", callback: (args) async {

                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString('userId') ?? 0;
                String fmc_token = await _firebaseMessaging.getToken();

                var arr = new List(3);
                arr[0] = "ios";
                arr[1] = id;
                arr[2] = fmc_token;

                print("?????? ???????????? ?????? ????????? ?????????.......");
                print(arr);

                return arr;

              });

              // ???????????? ??????
              controller.addJavaScriptHandler(handlerName: "Jchannel_Send", callback: (args) async {


                final prefs = await SharedPreferences.getInstance();

                // ??? ????????????
                prefs.setString('cardInfo', args.toString());

                // ??? ????????????
                final card = prefs.getString('cardInfo') ?? 0;

                print("?????? ?????????..............................");
                print(card);

              });


              //???????????? ?????????
              controller.addJavaScriptHandler(handlerName: "Jchannel_Receive", callback: (args) async {

                final prefs = await SharedPreferences.getInstance();
                final card = prefs.getString('cardInfo') ?? 0;
                return card;

              });

              //???????????? ??????
              controller.addJavaScriptHandler(handlerName: "Jchannel_remove", callback: (args) async {

                final prefs = await SharedPreferences.getInstance();
                prefs.remove('cardInfo');

              });

              //?????? ????????? ?????????
              controller.addJavaScriptHandler(handlerName: "Jchannel_Data", callback: (args) async {


                final prefs = await SharedPreferences.getInstance();
                // ??? ????????????
                final id = prefs.getString('userId') ?? 0;

                String user = id;
                String fmc_token = await _firebaseMessaging.getToken();
                String lat = null;
                String long = null;
                String ver = "1.0.0";

                var arr = new List(5);
                arr[0] = user;
                arr[1] = fmc_token;
                arr[2] = lat;
                arr[3] = long;
                arr[4] = ver;

                return arr;
              });

              //?????? ?????????
              controller.addJavaScriptHandler(handlerName: "push_cnt_load", callback: (args) async {
                print("???????????????: ${args}");

              });

            },



            onCreateWindow: (controller, createWindowRequest) async {
              print("onCreateWindow" + url);

              showDialog(
                context: context,
                builder: (context) {
                  Future.delayed(Duration(milliseconds: 1), () {
                    Navigator.pop(context);
                  });
                  return AlertDialog(
                    content: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      child: InAppWebView(
                        // Setting the windowId property is important here!
                        windowId: createWindowRequest.windowId,
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            debuggingEnabled: true,
                          ),
                        ),
                        onWebViewCreated: (
                            InAppWebViewController controller) {
                          _webViewPopupController = controller;
                        },
                        onLoadStart: (InAppWebViewController controller,
                            String url) async {
                          print("onLoadStart popup $url");

                          await widget.browser.open(
                              url: url,
                              options: ChromeSafariBrowserClassOptions(
                                  android: AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
                                  ios: IOSSafariOptions(barCollapsingEnabled: true)));

                        },

                        onLoadStop: (InAppWebViewController controller,
                            String url) async {
                          print("onLoadStop popup $url");

                          await widget.browser.open(
                              url: url,
                              options: ChromeSafariBrowserClassOptions(
                                  android: AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
                                  ios: IOSSafariOptions(barCollapsingEnabled: true)));

                          // Inject JavaScript that will receive data back from Flutter

                        },
                      ),
                    ),
                  );
                },
              );
              return true;
            },

            onLoadStart: (InAppWebViewController controller, String url) {
              setState(() { this.url = url;});

            },

            onLoadStop: (InAppWebViewController controller, String url) async {
              setState(() { this.url = url;});

            },

            onProgressChanged: (InAppWebViewController controller, int progress) {
              setState(() { this.progress = progress / 100;});

            },

          ),
        );
      }
      ),
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}