import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nowonbokji/browser.dart';
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




  Future<bool> _exitApp(BuildContext context) async {
    if (await webView.canGoBack()) {
      webView.goBack();
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("앱을 종료 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니요"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("네"),
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
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(builder: (BuildContext context) {
          return SafeArea(
            child: InAppWebView(
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
                  "about",].contains(uri.scheme))
                  if (await canLaunch(url)) {
                    // Launch the App
                    await launch(
                      url
                    );
                    // and cancel the request
                    return ShouldOverrideUrlLoadingAction.CANCEL;
                  }


                return ShouldOverrideUrlLoadingAction.ALLOW;
              },

              onWebViewCreated: (InAppWebViewController controller) async {
                webView = controller;
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
                                    android: AndroidChromeCustomTabsOptions(
                                        addDefaultShareMenuItem: false,showTitle: false),
                                    ios: IOSSafariOptions(barCollapsingEnabled: true)));
                          },

                          onLoadStop: (InAppWebViewController controller,
                              String url) async {
                            print("onLoadStop popup $url");

                            await widget.browser.open(
                                url: url,
                                options: ChromeSafariBrowserClassOptions(
                                    android: AndroidChromeCustomTabsOptions(
                                        addDefaultShareMenuItem: false,showTitle: false),
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
                setState(() {
                  this.url = url;
                });
              },
              onLoadStop: (InAppWebViewController controller, String url) async {
                setState(() {
                  this.url = url;
                });
              },

              onProgressChanged: (InAppWebViewController controller, int progress) {
                setState(() { this.progress = progress / 100;});
              },

            ),
          );
         }
        ),
      ),
    );
  }
}