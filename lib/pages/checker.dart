// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Checker extends CommonStatefulWidget {
  Checker() : super.clean();

  @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   throw UnimplementedError();
  // }
  _CheckerState createState() => _CheckerState();
}

class _CheckerState extends State<Checker> with WidgetsBindingObserver {
  Future<void> checkUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isDemo = (prefs.getBool("isDemo") == true);
    if (isDemo) {
    } else {}

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);

    return Future<void>.value();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      globalDataStore.UpdateRatio(context);

      checkUserData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image(
              image: AssetImage('assets/icon/launcher_icon.png'),
            ),
          )
        ],
      ),
    );
  }
}
