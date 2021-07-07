import 'package:flutter/material.dart';
import 'package:nowonbokji/main.dart';
import 'package:nowonbokji/view_page_test.dart';

class BlankPage extends StatefulWidget {
  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {

  String url = 'https://nowonsenior.or.kr/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Blank!'),
      ),
      body: InkWell(
        onTap: () {
          navigatorKey.currentState.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ViewPageTest(getURL: url,)), (Route<dynamic> route) => false);
        },
        child: Center(
          child: Text('Blank'),
        ),
      ),
    );
  }
}
