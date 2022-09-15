import 'dart:developer';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';

class Profiles extends CommonStatefulWidget {
  const Profiles({required Key? key}) : super(key: key);
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  List<ProfileData> datas = [];
  List<Map<String, ProfileData>> dataConSolid = [];
  bool isLoginFormNeed = false;
  bool isRegistrationFormNeed = false;
  bool needShowWelcomeAlert = false;
  double endAnimatedPosition = -40;

  List<String> bornTypes = [
    'Yes!',
    'Not, not yet',
  ];

  List<BottomSheetAction> getActionSheetTypeLists() {
    List<BottomSheetAction> _n = [];
    for (var item in bornTypes) {
      _n.add(BottomSheetAction(
        title: Text(item),
        onPressed: (context) {
          Navigator.pop(context);
          if (bornTypes[0].compareTo(item) == 0) {
            Navigator.pushNamed(context, '/profileEditing');
          } else {
            Navigator.pushNamed(context, '/profileEditing_notborn');
          }
          setState(() {});
        },
      ));
    }
    return _n;
  }

  void showActionScript() {
    showAdaptiveActionSheet(
        context: context,
        actions: getActionSheetTypeLists(),
        title: Text('Has the baby been born yet?'),
        cancelAction: CancelAction(
          title: Text("Cancel"),
          onPressed: (context) => {},
        ));
  }

  double bottomZoneSize() {
    return 0.35;
  }

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  void datasConsolidated() {
    if (dataConSolid.isNotEmpty) {
      dataConSolid.clear();
    }

    //set 2 cell in row
    for (var index = 0; index < datas.length; index++) {
      if ((index == 0 || index % 2 == 0) && index < datas.length) {
        if (index + 1 < datas.length) {
          //case have 2 cell with datas
          log('case1');
          dataConSolid.add({
            'data1': datas[index],
            'data2': datas[index + 1],
          });
        } else {
          //case have 2 cell with only single data info
          log('case2');
          dataConSolid
              .add({'data1': datas[index], 'data2': const ProfileData()});
        }
      }
    }

    if (datas.length % 2 == 0) {
      //do add the create profile
      log('case3');
      dataConSolid.add({'data1': const ProfileData()});
    }
  }

  void getData() async {
    await widget.getProfileDatas().then((value) {
      value!.forEach((element) {
        datas.add(element);
      });
      datasConsolidated(); // do data massage
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            // backgroundColor: Color.fromRGBO(0, 0, 0, 0.0), //HexColor("#F4F4F5"),
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: globalDataStore.getResponsiveSize(15),
                    right: globalDataStore.getResponsiveSize(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                            margin: EdgeInsets.only(
                                top: widget.getResponsivePositioning(100)),
                            height: globalDataStore.getResponsiveSize(60),
                            width: globalDataStore.getResponsiveSize(153),
                            // decoration: BoxDecoration(color: Colors.red),
                            child: Image(
                                image: AssetImage(
                                    "assets/images/blook_logo.png"))),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              top: widget.getResponsivePositioning(16)),
                          child: Text(
                            "Our Kid’s Profile",
                            style: TextStyle(
                                // fontFamily: "SFPro-Bold",
                                fontSize: globalDataStore.getResponsiveSize(26),
                                fontWeight: FontWeight.w700,
                                color: HexColor("#0E3658"),
                                letterSpacing: 0.2),
                          ),
                        ),
                      ),

                      /// GridView
                      Expanded(
                          // height: getHeightOfView(1 - bottomZoneSize()),
                          // decoration: BoxDecoration(color: Colors.green),
                          child: GridView.count(
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                              crossAxisCount: 1,
                              childAspectRatio:
                                  (globalDataStore.getResponsiveSize(317) /
                                      globalDataStore
                                          .getResponsiveSize(162)), //252x162
                              shrinkWrap: true,
                              primary: true,
                              padding: EdgeInsets.only(
                                  top: globalDataStore
                                      .getResponsiveTopPositioning(0),
                                  bottom: 0),
                              clipBehavior: Clip.antiAlias,
                              children: //[new ProfileGridCell((id) {})]
                                  List.generate(dataConSolid.length, (index) {
                                if (dataConSolid[index]['data2'] != null) {
                                  return getProfileGridDoubleCellRoll(
                                      (fileID) async {
                                    //TODO : set selected Profile
                                    await widget
                                        .setSelectedProfile(fileID)
                                        .then((isSuccess) {
//push with existing data
                                      log('fileID ? ' + fileID);
                                      if (fileID.length > 0) {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/home',
                                            ModalRoute.withName('/welcome'));
                                      } else {
                                        showActionScript();
                                      }
                                    });
                                  },
                                      data1: dataConSolid[index]['data1']
                                          as ProfileData,
                                      data2: dataConSolid[index]['data2']
                                          as ProfileData);
                                } else {
                                  return Center(child:
                                      getProfileGridSingleCellRoll((fileID) {
                                    //push with new profile page
                                    showActionScript();
                                  }));
                                }
                              }))),
                    ],
                  ),
                ),
                if (needShowWelcomeAlert) ...[
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 500),
                    onEnd: () {
                      if (needShowWelcomeAlert) {
                        setState(() {
                          needShowWelcomeAlert = false;
                        });
                      }
                    },
                    top: endAnimatedPosition,
                    child: widget.getInAppNotificationBlock(
                        'Yeah! You’re completed the sign up process. You can create your babies profile now.',
                        context),
                  )
                ]
              ],
            )),
        onWillPop: () async {
          return false;
        });
  }
}

/// Componet

Widget getProfileGridCell(Function(String) pressedCallBack,
    {ProfileData data = const ProfileData()}) {
  return getProfileCell(pressedCallBack, data: data);
}

Widget getProfileGridDoubleCellRoll(Function(String) pressedCallBack,
    {ProfileData data1 = const ProfileData(),
    ProfileData data2 = const ProfileData(),
    String existingID = ''}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(
        horizontal: globalDataStore.getResponsiveSize(0),
        vertical: globalDataStore.getResponsiveSize(5)),
    padding: EdgeInsets.symmetric(
        horizontal: globalDataStore.getResponsiveSize(25),
        vertical: globalDataStore.getResponsiveSize(0)),
    // decoration: BoxDecoration(border: Border.all(), color: Colors.red),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getProfileCell(pressedCallBack,
            data: data1,
            isSelecting: (existingID.length > 0
                ? data1.id.compareTo(existingID) == 0
                : false)),
        getProfileCell(pressedCallBack,
            data: data2,
            isSelecting: (existingID.length > 0
                ? data2.id.compareTo(existingID) == 0
                : false))
      ],
    ),
  );
}

Widget getProfileGridSingleCellRoll(Function(String) pressedCallBack,
    {ProfileData data1 = const ProfileData(), String existingID = ''}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(
        horizontal: globalDataStore.getResponsiveSize(0),
        vertical: globalDataStore.getResponsiveSize(5)),
    // decoration: BoxDecoration(border: Border.all(), color: Colors.blue),
    child: getProfileCell(pressedCallBack,
        data: data1, isSelecting: data1.id.compareTo(existingID) == 0),
  );
}

Widget getProfileCell(Function(String) pressedCallBack,
    {ProfileData data = const ProfileData(), bool isSelecting = false}) {
  const double iconSize = 116;
  ImageProvider<Object> assetImg = loadImageAsset(data.profilePic);
  if (data.profilePic.length == 0) {
    assetImg = loadImageAsset('assets/images/icon_baby.png');
  }

  return Container(
      width: globalDataStore.getResponsiveSize(iconSize + 10),
      margin: EdgeInsets.symmetric(
          horizontal: globalDataStore.getResponsiveSize(10)),
      // decoration: BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 10)
      //     ],
      //     borderRadius: BorderRadius.all(Radius.circular(10))),
      child: TextButton(
        onPressed: () {
          pressedCallBack(data.id);
        },
        child: Column(
          children: [
            Container(
              child: Stack(
                children: [
                  Container(
                    width: globalDataStore.getResponsiveSize(iconSize),
                    height: globalDataStore.getResponsiveSize(iconSize),
                    margin: EdgeInsets.only(
                        top: globalDataStore.getResponsivePositioning(2)),
                    padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(22)),
                    decoration: BoxDecoration(
                        color: HexColor('#F4F4F5'),
                        image:
                            DecorationImage(image: assetImg, fit: BoxFit.cover),
                        borderRadius: getThumbRadius(iconSize)),
                    child: null,
                  ),
                  if (data.id.length > 0) ...[
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 25,
                          child: data.borned == 1
                              ? Image(
                                  image: AssetImage('assets/images/icon_' +
                                      (data.gender.compareTo('Girl') == 0
                                          ? 'girl'
                                          : 'boy') +
                                      '.png'),
                                )
                              : null,
                        ))
                  ]
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: globalDataStore.getResponsivePositioning(6)),
              child: Text(
                (data.id.length > 0 ? data.nickName : "New Kid"),
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'SFProText-Bold',
                    fontSize: 15,
                    letterSpacing: -0.24,
                    fontWeight: FontWeight.w700),
              ),
            ),
            if (data.id.length > 0) ...[
              if (data.borned == 1) ...[
                Container(
                  margin: EdgeInsets.only(
                      top: globalDataStore.getResponsivePositioning(2)),
                  child: Text(
                    data.daysStrOfAge(withSpacing: true),
                    style: TextStyle(
                        color: data.colorOfGender(),
                        fontFamily: 'SFProText-Medium',
                        fontSize: 10,
                        letterSpacing: -0.24,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ] else ...[
                Container(
                    margin: EdgeInsets.only(
                        top: globalDataStore.getResponsivePositioning(2)),
                    child: Text(
                      'is on the way',
                      style: TextStyle(
                          color: Color.fromRGBO(13, 54, 88, 1),
                          fontFamily: 'SFProText-Medium',
                          fontSize: 10,
                          letterSpacing: -0.24,
                          fontWeight: FontWeight.w700),
                    ))
              ],
              if (isSelecting) ...[
                Container(
                  child: Image(
                    height: globalDataStore.getResponsiveSize(24),
                    image: AssetImage('assets/images/u_check.png'),
                  ),
                )
              ]
            ]
          ],
        ),
      ));
}
