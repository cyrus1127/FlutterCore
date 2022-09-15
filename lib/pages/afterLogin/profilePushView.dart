import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/postDetail.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/homeUserInfoSection.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileMessagerChat.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

class ProfilePushView extends CommonStatefulWidget {
  final ProfileData userData;

  const ProfilePushView(this.userData, {required Key? key}) : super(key: key);

  @override
  _ProfilePushViewState createState() => _ProfilePushViewState();
}

class _ProfilePushViewState extends State<ProfilePushView> {
  final TextEditingController _controller = TextEditingController();

  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double tapBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 34 : 10) : 10);
  double tapBarHeight = 58;
  double inputFieldHeight = 0;
  double inputFieldpadding = 0;
  double profileShortDetailFieldHeight = 185;
  bool isFollowRequested = false;

  TextStyle ts_1 = TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'SFProText',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      fontSize: globalDataStore.getResponsiveSize(16));

  int onSelectedMedia = -1;
  String onSearchingKeyword = '';
  List<PostData> postRecords = [];

  double getHeightOfView(double precetage) {
    return globalDataStore
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  void doRequestFollow() {
    if (widget.userData.followed == 0) {
      ///TODO : do request
      isFollowRequested = true;
    } else {
      ///TODO : do unfollow
    }

    print('Do request simulation');
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {});
    });
  }

  void pushPrivateMessagePage() {
    Navigator.push(
        context,
        PageTransition(
            child: ProfileMessagerChat(widget.userData,
                key: new Key(new Uuid().toString())),
            type: PageTransitionType.rightToLeft));
  }

  /*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/

  void loadPostRecords() async {
    postRecords.clear();

//TODO : request the search result by server API

//TODO :
    // await widget.getPostDatas().then((value) {
    //   value!.forEach((element) {
    //     postRecords.add(element);
    //   });
    //   setState(() {});
    // });

    //Debug
    int demoAmount = 10;
    if (onSearchingKeyword.length > 0) demoAmount = 0;
    for (var i = 0; i < demoAmount; i++) {
      // postRecords.add();
    }
    setState(() {
      print('user result count' + postRecords.length.toString());
    });
  }

  void loadUserData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String profileID = prefs.getString('selectedProfile') ?? '';
    // List<ProfileData>? datas = await widget.getProfileDatas();

    // Future.forEach(datas!, (element) {
    //   var data = element as ProfileData;
    //   print('stored profile : $data ??' + data.id + ' , ' + data.name);
    //   if (data.id.compareTo(profileID) == 0) {
    //     widget.userData = data;
    //   }
    // });

    isFollowRequested = widget.userData.followed == 1;

    localRecordNeedUpdate();
  }

  void localRecordNeedUpdate() {
    //sim to load albums

    loadPostRecords();
  }

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: HexColor('#F4F4F4'),
            body: Stack(
              children: [
                //Topbar
                Positioned(
                    top: 0,
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        height: globalDataStore
                            .getResponsiveSize(topBarHeight + topBarOffSet),
                        padding: EdgeInsets.only(
                            top: globalDataStore
                                .getResponsiveSize(topBarOffSet)),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Container(
                                width: globalDataStore.getResponsiveSize(30),
                                margin: EdgeInsets.only(
                                    left: globalDataStore.getResponsiveSize(15),
                                    right:
                                        globalDataStore.getResponsiveSize(5)),
                                child: TextButton(
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/icon_arrow_left.png')),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(2)),
                                )),
                            Container(
                              padding: EdgeInsets.only(
                                  left: globalDataStore.getResponsiveSize(15)),
                              child: Text(
                                widget.userData.nickName,
                                style: TextStyle(
                                    fontSize:
                                        globalDataStore.getResponsiveSize(28),
                                    fontFamily: 'SFProText-Bold',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.24),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(
                                  globalDataStore.getResponsiveSize(8)),
                              child: Image(
                                height: globalDataStore.getResponsiveSize(30),
                                image: AssetImage('assets/images/icon_' +
                                    widget.userData.gender.toLowerCase() +
                                    '.png'),
                              ),
                            ),
                            Spacer(),
                            Container(
                                width: globalDataStore.getResponsiveSize(50),
                                child: tapButtonWidget(pushPrivateMessagePage,
                                    'assets/images/icon_message.png')),
                          ],
                        ))),

                //User short info
                Positioned(
                  top: widget
                      .getResponsivePositioning((topBarHeight + topBarOffSet)),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: globalDataStore
                          .getResponsiveSize(profileShortDetailFieldHeight),
                      // decoration: BoxDecoration(color: Colors.amber),
                      child: userShortInfo(
                          profileShortDetailFieldHeight,
                          MediaQuery.of(context).size.width,
                          widget.userData, () {
                        doRequestFollow();
                      }, () {
                        Navigator.pushNamed(context, '/photoAlbum');
                      }, context,
                          isSelfProfile: false,
                          isFollowRequested: isFollowRequested)),
                ),

                //User's all post
                Positioned(
                    top: widget.getResponsivePositioning((topBarHeight +
                        topBarOffSet +
                        inputFieldHeight +
                        profileShortDetailFieldHeight)),
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          globalDataStore.getResponsiveSize(
                              (topBarHeight + topBarOffSet) +
                                  (tapBarHeight + tapBarOffSet) +
                                  inputFieldHeight +
                                  profileShortDetailFieldHeight),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: HexColor('#F4F4F5')),
                      child: (this.widget.userData.followed == 1)
                          ? ListView(
                              padding: EdgeInsets.only(top: 0),
                              children:
                                  List.generate(postRecords.length, (index) {
                                return postBlock(
                                  postRecords[index],
                                  globalDataStore.getResponsiveSize(10),
                                  MediaQuery.of(context).size.width,
                                  (postData) {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: PostDetail(postData,
                                                key: new Key(
                                                    new Uuid().toString())),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  },
                                  (postData) {
                                    widget.pushImageZoomingView(
                                        postData.postMediaLink, context);
                                  },
                                );
                              }),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: globalDataStore.getResponsiveSize(40),
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/icon_contentLocked.png')),
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: globalDataStore
                                            .getResponsiveSize(15)),
                                    child: Text(
                                      'This account is private',
                                      style: TextStyle(
                                          color: Color.fromRGBO(14, 54, 88, 1),
                                          fontFamily: 'SFProText',
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: globalDataStore
                                              .getResponsiveSize(16)),
                                    )),
                                Container(
                                    child: Text(
                                  'Request to follow, you can see their profile\nwhen user approveprivate',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      fontFamily: 'SFProText',
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: globalDataStore
                                          .getResponsiveSize(12)),
                                ))
                              ],
                            ),
                    )),
              ],
            )),
        onWillPop: () async {
          return true;
        });
  }
}
