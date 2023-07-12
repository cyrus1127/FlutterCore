import 'dart:ffi';

import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/dataObjects/pregnancy.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/pregnancyRecordCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/subviews/zoomingPhotoView.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// final AudioPlayer audioPlayer = AudioPlayer();
// final AudioPlayer effectPlayer = AudioPlayer();

class CommonStatefulWidget extends ResponsiveStatefulWidget
    with WidgetsBindingObserver {
  final String target;

  const CommonStatefulWidget({required Key? key, this.target = ''})
      : super(key: key);

  CommonStatefulWidget.clean({this.target = ''}) : super.clean();
  //for
  CommonStatefulWidget.checker(this.target) : super.clean();

  void playButtonSoundEffect() async {
    // await effectPlayer.setAsset("assets/bgm/button.mp3");
    // await effectPlayer.setLoopMode(LoopMode.off);
    // await effectPlayer.setVolume(70);
    // await effectPlayer.setSkipSilenceEnabled(false);
    // effectPlayer.play();
  }

  void stopBGM() async {
    // if (Platform.isAndroid) {
    //   audioPlayer.pause();
    // } else {
    //   audioPlayer.stop();
    // }
  }

  void resumeBGM() async {
    // RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool playBGM = prefs.getBool("playBGM") ?? true;
    // if (!audioPlayer.playing && playBGM) {
    //   audioPlayer.play();
    // }
  }

  creatAlertDialog(BuildContext context, String header, String errMessage) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: HexColor("#f26724"),
            shape: RoundedRectangleBorder(
                side: BorderSide(color: HexColor("#f26724"), width: 10),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(
              header,
              style: TextStyle(color: Colors.white),
            ),
            content: Text(errMessage, style: TextStyle(color: Colors.white)),
            actions: <Widget>[
              TextButton(
                child: Text("確定", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  Future<bool> checkIsFirstLaunchOpeningPlayDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPlayed = (prefs.getBool('OP') == true);
    return Future<bool>.value(isPlayed);
  }

  Future<void> setOpeningPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("OP", true);
  }

  Future<bool> checkIsNeedTutoral() async {
    bool isFirstLaunchPlayed = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('Tut') == true) {
      //is opening showed already ?
      isFirstLaunchPlayed = true;
    }
    return Future<bool>.value(isFirstLaunchPlayed);
  }

  Future<void> setFirstLaunchTutorialPlayed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("Tut", true);
  }

/*
  =-=-=-=-=-=-=-=-=-=-=-=-* Local bundles handling  *-=-=-=-=-=-=-=-=-=-=-=-=
  */

  Future<String> loadJson(String fileName) {
    return rootBundle.loadString('assets/bundles/' + fileName + '.json');
  }

  Future<List<Map<String, dynamic>>?> loadPregnancyGuideDatas() async {
    var dataContent = await loadJson('pregnancy_LanguagePack');
    List<dynamic>? decoded = jsonDecode(dataContent);
    if (decoded != null) {
      List<Map<String, dynamic>> objs = [];
      Future.forEach(decoded, (element) {
        objs.add(element as Map<String, dynamic>);
      });

      return Future.value(objs);
    }
    return Future.value(null);
  }

  Future<List<PregnancyGuid>> getPregnancyGuideDatas() async {
    List<PregnancyGuid> list = [];

    var datas = await loadPregnancyGuideDatas() ?? [];
    int weekIdx = -1;

    Future.forEach(datas, (element) {
      Map<String, dynamic> mapping = element as Map<String, dynamic>;

      if (mapping["Weeks"] != weekIdx) {
        var nObj = new PregnancyGuid(
            mapping["Weeks"],
            mapping["Status_Name_EN"],
            mapping["Status_Name_TC"],
            mapping["Length"] != null ? mapping["Length"].toString() : '',
            mapping["Length_Unit_EN"],
            mapping["Length_Unit_TC"],
            mapping["Weight"] != null ? mapping["Weight"].toString() : '',
            mapping["Weight_Unit_EN"],
            mapping["Weight_Unit_TC"]);
        list.add(nObj);
        weekIdx = mapping["Weeks"];
        // print('add next pregnancy guides object -> ' + weekIdx.toString());
      }

      //set Q & A
      list[list.length - 1].addQuestWithAwnser(
          mapping["QuestType-EN"] ?? '',
          mapping["Question_EN"] ?? '',
          mapping["Answer_EN"] ?? '',
          mapping["Question_TC"] ?? '',
          mapping["Answer_TC"] ?? '');
    });

    return Future.value(list);
  }

  Future<Map<String, dynamic>?> loadPregnancyChartGuideDatas() async {
    var dataContent = await loadJson('Fetal development[MFA]');
    Map<String, dynamic>? decoded = jsonDecode(dataContent);
    if (decoded != null) {
      return Future.value(decoded);
    }
    return Future.value(null);
  }

  Future<List<PregnancyChartGuid>> getPregnancyChartGuideDatas() async {
    List<PregnancyChartGuid> list = [];

    Map<String, dynamic>? datas = await loadPregnancyChartGuideDatas();
    int weekIdx = -1;

    Future.forEach(datas!.keys, (element) {
      String weekKey = element as String;
      Map<String, dynamic> mapData = datas[element];
      print(mapData);
      list.add(PregnancyChartGuid(
        week: double.parse(weekKey),
        crl: globalDataStore.objToDouble(mapData["CRL"]),
        brd: globalDataStore.objToDouble(mapData["BPD"]),
        brd_range: globalDataStore.objToDouble(mapData["BPD_range"]),
        hc: globalDataStore.objToDouble(mapData["HC"]),
        hc_range: globalDataStore.objToDouble(mapData["HC_range"]),
        fl: globalDataStore.objToDouble(mapData["FL"]),
        fl_range: globalDataStore.objToDouble(mapData["FL_range"]),
        ac: globalDataStore.objToDouble(mapData["AC"]),
        ac_range: globalDataStore.objToDouble(mapData["AC_range"]),
      ));
    });

    return Future.value(list);
  }

  Future<Map<String, dynamic>?> loadChildChartGuideDatas(
      bool getGirlDatas) async {
    var dataContent = await loadJson(
        'WeightHeight_' + (getGirlDatas ? 'girl' : 'boy') + '[MFA]');
    Map<String, dynamic>? decoded = jsonDecode(dataContent);
    if (decoded != null) {
      return Future.value(decoded);
    }
    return Future.value(null);
  }

  Future<List<ChildChartGuid>> getChildChartGuidDatas(bool isGirl) async {
    List<ChildChartGuid> list = [];

    Map<String, dynamic>? datas = await loadChildChartGuideDatas(isGirl);

    List<dynamic> keymap = datas!["fields"];
    List<dynamic> mapData = datas["data"];
    for (int i = 0; i < mapData.length; i++) {
      List<dynamic> innerData = mapData[i];
      print(innerData);
      list.add(ChildChartGuid(
        innerData[keymap.indexOf('MonthIDX')],
        innerData[keymap.indexOf('Year')],
        innerData[keymap.indexOf('Month')],
        MeasureDataSet(
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 1]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 2]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 3]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 4]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 5]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 6]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 7]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 8]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 9]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 10]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Height') + 11])),
        MeasureDataSet(
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 1]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 2]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 3]),
            0,
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 4]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 5]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 6]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 7]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 8]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 9]),
            globalDataStore
                .objToDouble(innerData[keymap.indexOf('Weight') + 10])),
      ));
    }

    return Future.value(list);
  }

/*
  =-=-=-=-=-=-=-=-=-=-=-=-* Data handling for Post & artical *-=-=-=-=-=-=-=-=-=-=-=-=
  */

  Future<bool> setPostDatas(PostData nData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<PostData>? value = await getPostDatas();

    int needUpdateIndex = -1;

    if (value != null) {
//find existing data rows
      value.forEach((element) {
        if (element.id == nData.id) {
          //do update
          needUpdateIndex = value.indexOf(element);
          return;
        }
      });
    }

//encode datas to json string
    String jsonDataStr = jsonEncode(nData);
    //get latest data list
    final dataStr = prefs.getStringList('postRecords') ?? [];
    if (needUpdateIndex >= 0 && dataStr.length > 0) {
      dataStr.removeAt(needUpdateIndex);
    }
    //do add/insert data row
    dataStr.add(jsonDataStr);
    //do save/update shareprefence
    return prefs.setStringList('postRecords', dataStr);
  }

  Future<List<PostData>?> getPostDatas() async {
    List<PostData> listItems = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataStr = prefs.getStringList('postRecords');

    if (dataStr != null) {
      Future.forEach(dataStr, (element) {
        Map<String, dynamic> decoded = jsonDecode(element as String);
        PostData ex = new PostData(
          id: decoded['id'],
          postOwnerID: decoded['postOwnerID'],
          postOwnerThumbnails: decoded['postOwnerThumbnails'],
          postDatetime: decoded['postDatetime'],
          postContents: decoded['postContents'],
          postMediaLink: decoded['postMediaLink'],
          likes: decoded['likes'],
          comments: decoded['comments'],
        );
        listItems.add(ex);
      });
    }

    return Future<List<PostData>>.value(listItems);
  }

/*
  =-=-=-=-=-=-=-=-=-=-=-=-* Data handling for Daily *-=-=-=-=-=-=-=-=-=-=-=-=
  */

  Future<bool> setDailyDatas(DailyRecord? nData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DailyRecord>? allDatas = await getDailyDatas();

    //do remove all local data
    if (nData == null) {
      return Future.value(false);
    } else {
      // return prefs.setStringList('dailyRecords', []); //debug use clear data;
    }

    int needUpdateIndex = -1;

    if (allDatas != null) {
//find existing data rows
      allDatas.forEach((element) {
        if (element.id == nData.id) {
          //set to do update
          needUpdateIndex = allDatas.indexOf(element);
          return;
        }
      });
    }

//encode datas to json string
    String jsonDataStr = jsonEncode(nData);
    //get latest data list
    final dataStr = prefs.getStringList('dailyRecords') ?? [];
    if (needUpdateIndex >= 0 && dataStr.length > 0) {
      dataStr.removeAt(needUpdateIndex);
    }
    //do add/insert data row
    dataStr.add(jsonDataStr);
    //do save/update shareprefence
    return prefs.setStringList('dailyRecords', dataStr);
  }

  Future<bool> deleteDailyDatas(DailyRecord? nData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DailyRecord>? allDatas = await getDailyDatas();

    if (nData == null) {
      return Future.value(false);
    }

    int needUpdateIndex = -1;

    if (allDatas != null) {
//find existing data rows
      allDatas.forEach((element) {
        if (element.id == nData.id) {
          //set to do update
          needUpdateIndex = allDatas.indexOf(element);
        }
      });
    }
    if (needUpdateIndex >= 0) {
      final dataStr = prefs.getStringList('dailyRecords') ?? [];
      dataStr.removeAt(needUpdateIndex);
      return prefs.setStringList('dailyRecords', dataStr);
    }

    return Future<bool>.value(false);
  }

  Future<List<DailyRecord>?> getDailyDatas() async {
    List<DailyRecord> listItems = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataStr = prefs.getStringList('dailyRecords');

    if (dataStr != null) {
      Future.forEach(dataStr, (element) {
        Map<String, dynamic> decoded = jsonDecode(element as String);
        DailyRecord ex = new DailyRecord(
            id: decoded['id'],
            activityType:
                decoded['activityType'] == null ? -1 : decoded['activityType'],
            activityKey:
                decoded['activityKey'] == null ? '' : decoded['activityKey'],
            activity: decoded['activity'],
            quanity: decoded['quanity'] == null ? '' : decoded['quanity'],
            amount: decoded['amount'] == null ? 0 : decoded['amount'],
            amountMark: decoded['amountMark'],
            datetime: decoded['datetime'] == null ? '' : decoded['datetime'],
            datetimeEnd:
                decoded['datetimeEnd'] == null ? '' : decoded['datetimeEnd'],
            datetimeDuration: decoded['datetimeDuration'] == null
                ? 0
                : decoded['datetimeDuration'],
            notes: decoded['notes'],
            userID: decoded['userID'] == null ? '' : decoded['userID']);
        listItems.add(ex);
      });
    }

    return Future<List<DailyRecord>>.value(listItems);
  }

/*
  =-=-=-=-=-=-=-=-=-=-=-=-* Data handling for Daily of Pregnancy *-=-=-=-=-=-=-=-=-=-=-=-=
  */

  Future<bool> setPregnancyData(PregnancyDailyRecord? nData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<PregnancyDailyRecord>? allDatas = await getPregnancyDatas();

    //do remove all local data
    if (nData == null) {
      return Future.value(false);
    }

    int needUpdateIndex = -1;

    if (allDatas != null) {
//find existing data rows
      allDatas.forEach((element) {
        if (element.id == nData.id) {
          //set to do update
          needUpdateIndex = allDatas.indexOf(element);
          return;
        }
      });
    }

//encode datas to json string
    String jsonDataStr = jsonEncode(nData);
    //get latest data list
    final dataStr = prefs.getStringList('pregnancyDailyRecords') ?? [];
    if (needUpdateIndex >= 0 && dataStr.length > 0) {
      dataStr.removeAt(needUpdateIndex);
    }
    //do add/insert data row
    dataStr.add(jsonDataStr);
    //do save/update shareprefence
    return prefs.setStringList('pregnancyDailyRecords', dataStr);
  }

  Future<bool> deletePregnancyDatas(PregnancyDailyRecord? nData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<PregnancyDailyRecord>? allDatas = await getPregnancyDatas();

    //do remove all local data
    if (nData == null) {
      return Future.value(false);
    }

    int needUpdateIndex = -1;

    if (allDatas != null) {
//find existing data rows
      allDatas.forEach((element) {
        if (element.id == nData.id) {
          //set to do update
          needUpdateIndex = allDatas.indexOf(element);
        }
      });
    }
    if (needUpdateIndex >= 0) {
      final dataStr = prefs.getStringList('pregnancyDailyRecords') ?? [];
      dataStr.removeAt(needUpdateIndex);
      return prefs.setStringList('pregnancyDailyRecords', dataStr);
    }

    return Future<bool>.value(false);
  }

  Future<List<PregnancyDailyRecord>?> getPregnancyDatas() async {
    List<PregnancyDailyRecord> listItems = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataStr = prefs.getStringList('pregnancyDailyRecords');

    if (dataStr != null) {
      Future.forEach(dataStr, (element) {
        Map<String, dynamic> decoded = jsonDecode(element as String);
        PregnancyDailyRecord ex = new PregnancyDailyRecord(
            id: decoded['id'],
            datetime: decoded['datetime'] == null ? '' : decoded['datetime'],
            crl: decoded['crl'],
            bpd: decoded['bpd'],
            hc: decoded['hc'],
            fl: decoded['fl'],
            ac: decoded['ac'] == null ? 0 : decoded['ac'],
            photoPath: decoded['photoPath'],
            notes: decoded['notes'],
            userID: decoded['userID'] == null ? '' : decoded['userID']);
        listItems.add(ex);
      });
    }

    return Future<List<PregnancyDailyRecord>>.value(listItems);
  }

  /*
  =-=-=-=-=-=-=-=-=-=-=-=-* Data handling for Profile *-=-=-=-=-=-=-=-=-=-=-=-=
  */
  Future<bool> setSelectedProfile(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('selectedProfile', id);
  }

  Future<ProfileData?> getSelectedProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileID = prefs.getString('selectedProfile') ?? '';
    List<ProfileData>? datas = await getProfileDatas();

    Future.forEach(datas!, (element) {
      ProfileData data = element as ProfileData;
      print('stored profile : $data ??' + data.id + ' , ' + data.name);
      if (data.id.compareTo(profileID) == 0) {
        return Future<ProfileData?>.value(data);
      }
    });
  }

  Future<bool> setProfileDatas(ProfileData nData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<ProfileData>? value = await getProfileDatas();

    int needUpdateIndex = -1;

    if (value != null) {
      //find existing data rows
      value.forEach((element) {
        if (element.id == nData.id) {
          //do update
          needUpdateIndex = value.indexOf(element);
          return;
        }
      });
    }

    //encode datas to json string
    String jsonDataStr = jsonEncode(nData);
    //get latest data list
    final dataStr = prefs.getStringList('profiles') ?? [];
    if (needUpdateIndex >= 0 && dataStr.length > 0) {
      dataStr.removeAt(needUpdateIndex);
    }
    //do add/insert data row
    dataStr.add(jsonDataStr);
    //do save/update shareprefence
    return prefs.setStringList('profiles', dataStr);
  }

  Future<List<ProfileData>?> getProfileDatas() async {
    List<ProfileData> listItems = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataStr = prefs.getStringList('profiles');

    if (dataStr != null) {
      Future.forEach(dataStr, (element) {
        Map<String, dynamic> decoded = jsonDecode(element as String);
        ProfileData ex = new ProfileData(
            id: decoded['id'],
            age: decoded['age'],
            name: decoded['name'],
            nickName: decoded['nickName'],
            birthday: decoded['birthday'],
            gender: decoded['gender'],
            bloodType: decoded['bloodType'],
            parentKind: decoded['parentKind'],
            parentName:
                decoded['parentName'] == null ? '' : decoded['parentName'],
            parentNameCo:
                decoded['parentNameCo'] == null ? '' : decoded['parentNameCo'],
            parentEmail: decoded['parentEmail'],
            profilePic: decoded['profilePic'],
            borned: decoded['borned'] == null ? 1 : decoded['borned'],
            followed: decoded['followed']);
        listItems.add(ex);
      });
    }

    return Future<List<ProfileData>>.value(listItems);
  }

  /*
  =-=-=-=-=-=-=-=-=-=-=-=-* Common widgets *-=-=-=-=-=-=-=-=-=-=-=-=
  */
  Widget getInAppNotificationBlock(
    String msg,
    BuildContext context,
  ) {
    return Container(
        height: 60,
        width: MediaQuery.of(context).size.width - 20,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
            color: Color.fromRGBO(241, 163, 135, 0.8),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Center(
          child: Text(
            msg,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: "SFProText-Semibold",
              fontSize: 14,
              letterSpacing: -0.24,
              height: 1.2,
            ),
          ),
        ));
  }

  Widget getInAppReminderBlock(String msg, BuildContext context,
      {bool needRichText = false, String tapableString = ''}) {
    double height = getResponsiveSize(needRichText ? 75 : 60);
    double width = MediaQuery.of(context).size.width - getResponsiveSize(20);
    double margin = getResponsiveSize(10);
    double paddingHor = getResponsiveSize(20);
    BoxDecoration bd = BoxDecoration(
        color: Color.fromRGBO(240, 87, 87, 0.8),
        borderRadius: BorderRadius.all(Radius.circular(10)));
    TextStyle ts = TextStyle(
      color: needRichText ? Colors.white : Colors.black,
      fontWeight: FontWeight.w600,
      fontFamily: "SFProText-Semibold",
      fontSize: getResponsiveSize(14),
      letterSpacing: -0.24,
      height: 1.2,
    );

    if (needRichText) {
      TextStyle ts_tap = TextStyle(
          color: needRichText ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: "SFProText-Semibold",
          fontSize: getResponsiveSize(14),
          letterSpacing: -0.24,
          height: 1.2,
          decoration: TextDecoration.underline);

      return Container(
        height: height,
        width: width,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.symmetric(horizontal: paddingHor, vertical: margin),
        decoration: bd,
        child: RichText(
            text: TextSpan(style: ts, children: [
          TextSpan(text: msg),
          TextSpan(
              style: ts_tap,
              text: "Learn more",
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  //to call API
                  //TODO : show alert
                }),
        ])),
      );
    }

//Normal text
    return Container(
        height: height,
        width: width,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.symmetric(horizontal: paddingHor, vertical: margin),
        decoration: bd,
        child: Center(
          child: Text(
            msg,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: ts,
          ),
        ));
  }

  Widget cardView(Widget childWidget) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.0), //HexColor("#F4F4F5"),
        resizeToAvoidBottomInset: false,
        body: Container(
            margin: EdgeInsets.only(top: getResponsivePositioning(50)),
            decoration: BoxDecoration(
                color: HexColor("#F4F4F5"),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    blurRadius: getResponsiveSize(10),
                  )
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(getResponsiveSize(15)),
                    topRight: Radius.circular(getResponsiveSize(15)))),
            child: childWidget));
  }

  void showFunctionWillProvideSoon(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Reminder'),
              content: Text('function will come soon'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void pushImageZoomingView(String imageResPath, BuildContext context) {
    Navigator.push(
        context,
        PageTransition(
            child: new ZoomingPhotoView.clean(imageResPath),
            type: PageTransitionType.topToBottom));
  }

  ///TODO : remove/modify it if server exist
  List<String> getLocalBundledImage() {
    return [
      'assets/images/thumbnails/original/02-e89189e5afb6e5afb6-e1566198293252.jpg',
      'assets/images/thumbnails/original/02e0-hphsupx4870075.jpg',
      'assets/images/thumbnails/original/54-1606903865.jpg',
      'assets/images/thumbnails/original/1629518770594950.jpg',
      'assets/images/thumbnails/original/b1.jpeg',
      'assets/images/thumbnails/original/b2.jpeg',
      'assets/images/thumbnails/original/b3.jpeg',
      'assets/images/thumbnails/original/b4.jpeg',
      'assets/images/thumbnails/original/b5.jpeg',
      'assets/images/thumbnails/original/b6.jpg',
      'assets/images/thumbnails/original/baby_1.jpg',
      'assets/images/thumbnails/original/baby_2.jpg',
      'assets/images/thumbnails/original/baby_3.jpg',
      'assets/images/thumbnails/original/baby_5.jpg',
      'assets/images/thumbnails/original/baby_6.jpg',
      'assets/images/thumbnails/original/baby_7.jpg',
      'assets/images/thumbnails/original/baby_8.jpg',
      'assets/images/thumbnails/original/baby_9.jpg',
      'assets/images/thumbnails/original/d1.jpeg',
      'assets/images/thumbnails/original/d2.jpeg',
      'assets/images/thumbnails/original/d3.jpeg',
      'assets/images/thumbnails/original/d4.jpeg',
      'assets/images/thumbnails/original/d5.jpeg',
      'assets/images/thumbnails/original/f1.jpeg',
      'assets/images/thumbnails/original/f2.jpeg',
      'assets/images/thumbnails/original/f3.jpeg',
      'assets/images/thumbnails/original/f4.jpeg',
      'assets/images/thumbnails/original/f5.jpeg',
      'assets/images/thumbnails/original/GsPpqc9t6YfVghEWjzWyPLuBeGAczqnWrhh4Qkbu.jpeg',
      'assets/images/thumbnails/original/ID5_1.jpg',
      'assets/images/thumbnails/original/ID5_2.jpg',
      'assets/images/thumbnails/original/ID9_1.jpg',
      'assets/images/thumbnails/original/ID9_2.jpg',
      'assets/images/thumbnails/original/ID14_1.jpg',
      'assets/images/thumbnails/original/ID22_1.jpg',
      'assets/images/thumbnails/original/ID22_2.jpg',
      'assets/images/thumbnails/original/ID23_1.jpg',
      'assets/images/thumbnails/original/ID23_3.jpg',
      'assets/images/thumbnails/original/ID26_1.jpg',
      'assets/images/thumbnails/original/ID26_2.jpg',
      'assets/images/thumbnails/original/ID29_1.jpg',
      'assets/images/thumbnails/original/m1.jpeg',
      'assets/images/thumbnails/original/m2.jpeg',
      'assets/images/thumbnails/original/m3.jpeg',
      'assets/images/thumbnails/original/m4.jpeg',
      'assets/images/thumbnails/original/m5.jpeg',
      'assets/images/thumbnails/original/m6.jpeg',
      'assets/images/thumbnails/original/m7.jpeg',
      'assets/images/thumbnails/original/OMDb9z4I0hj3gsIbR84NzFPGYr7xZ4mgJgoN7pIq.jpg',
      'assets/images/thumbnails/original/P1404299861722.jpg',
      'assets/images/thumbnails/original/Ru5JFxe4uKDmYkbvlem998N02gVfKjBxATo6nBCK.jpg',
      'assets/images/thumbnails/original/wZS4l4SBBm1AODVcuQbOTGm1YOmMPDGIfmC51SrE.jpg',
    ];
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // setState(() { _notification = state; });

    print("didChangeAppLifecycleState -> " + state.toString());
    if (state == AppLifecycleState.inactive) {
      stopBGM();
    } else if (state == AppLifecycleState.resumed) {
      resumeBGM();
    }
  }
}

// class _CommonStatefulWidgetState extends State<CommonStatefulWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Material();
//   }
// }

