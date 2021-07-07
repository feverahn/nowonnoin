import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nowonbokji/browser.dart';

class ViewPageTest extends StatefulWidget {
  final String getURL;

  ViewPageTest({Key key, this.getURL}) : super(key: key);

  final ChromeSafariBrowser browser = new MyChromeSafariBrowser(new MyInAppBrowser());

  @override
  _ViewPageState createState() => _ViewPageState();
}


class _ViewPageState extends State<ViewPageTest> {
  InAppWebViewController webView;

  @override
  void initState() {
    super.initState();
  }

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
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(builder: (BuildContext context) {
          return SafeArea(
            child: InAppWebView(
              initialUrl: widget.getURL,
              initialHeaders: {},
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  debuggingEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  javaScriptCanOpenWindowsAutomatically: false,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) async {
                webView = controller;
              },

            ),
          );
        }
        ),
      ),
    );
  }
}