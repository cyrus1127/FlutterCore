import 'dart:io';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';

class Home extends CommonStatefulWidget {
  const Home({required Key? key}) : super(key: key);

  // @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double tapBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 34 : 10) : 10);
  double tapBarHeight = 58;
  double tapBarPadding = 10;
  bool tapBarOnShow = true;

  ScrollController mainContentListController = ScrollController();

  _scrollListener() {
    if (mainContentListController.offset >
            MediaQuery.of(context).size.height / 3 &&
        tapBarOnShow) {
      tapBarOnShow = false;
      setState(() {});
    } else if (mainContentListController.offset < 10 && !tapBarOnShow) {
      tapBarOnShow = true;
      setState(() {});
    }
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String profileID = prefs.getString('selectedProfile') ?? '';

    // await widget.getProfileDatas().then((value) {
    //   value!.forEach((element) {

    //   });
    // });

    localRecordNeedUpdate();
  }

  void localRecordNeedUpdate() async {}

  void changeProfile() {
    loadUserData();
  }

  @override
  void initState() {
    super.initState();
    changeProfile();
    globalDataStore.changeNotifier.addListener(changeProfile);
    globalDataStore.changeNotifier.addListener(localRecordNeedUpdate);
    mainContentListController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    globalDataStore.changeNotifier.removeListener(changeProfile);
    globalDataStore.changeNotifier.removeListener(localRecordNeedUpdate);
    mainContentListController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(232, 235, 237, 1),
        body: Stack(
          children: [
            Center(
              child: Text("Demo"),
            ),
          ],
        ));
  }
}
