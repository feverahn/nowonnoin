import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _debugLabelString = "";
  String url = "https://nowonsenior.or.kr";


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);



    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((notification) {
      this.setState(() {
        url = notification.payload.additionalData['url'].toString() ;

      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        // the value of result.notification.payload.additionalData['url'] =
        // https://www.facebook.com/
        url = result.notification.payload.additionalData['url'].toString() ;
      });
    });


// NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared
        .init("e579a66a-9ba5-44ed-b317-13dc1609da4a", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);


  }



  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('OneSignal Flutter Demo'),
            backgroundColor: Color.fromARGB(255, 212, 86, 83),
          ),
          body:  WebviewScaffold(
            url: url,

            withJavascript: true,
          )
      ),
    );
  }
}