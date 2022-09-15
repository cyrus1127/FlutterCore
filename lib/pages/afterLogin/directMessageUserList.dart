import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileMessagerChat.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

class DirectMessageUserList extends CommonStatefulWidget {
  const DirectMessageUserList({required Key? key}) : super(key: key);

  @override
  _DirectMessageUserListState createState() => _DirectMessageUserListState();
}

class _DirectMessageUserListState extends State<DirectMessageUserList> {
  final TextEditingController _controller = TextEditingController();

  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double segmentWidgetHeight = 35;
  double endAnimatedPosition = -40;
  double editingBlockHeight = 565;
  double datetimePickerHeight = 216;
  double quaityBarHeight = 45;
  double searchingBarHeight = 82;
  double waitingListTopMargin = 10;
  double waitingListSegmentBottomPadding = 15;
  double listHeaderHeight = 25;
  double layoutMargin = globalDataStore.getResponsiveSize(15); //for builds bar

  String titleName = 'Message';
  TextStyle ts_1 = TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'SFProText',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      fontSize: globalDataStore.getResponsiveSize(16));
  TextStyle ts_noRecord = TextStyle(
      fontFamily: 'SFProText',
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      letterSpacing: -0.15,
      fontSize: globalDataStore.getResponsiveSize(16),
      color: Color.fromRGBO(14, 54, 88, 1));

  final String segmentAll = 'All';
  String segmentOnSelected = 'All';

  int onSelectedMedia = -1;
  String onSearchingKeyword = '';
  ProfileData myData = ProfileData();
  List<ProfileData> users = [];
  List<ProfileData> waitingUsers = [];
  List<String> requestedUsers = [];

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  bool isSearchList() {
    return segmentOnSelected.compareTo(segmentAll) == 0;
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  void onSegmentChanged(strVal) {
    print('segment button pressed , val ? ' + strVal);
    segmentOnSelected = strVal;

    // isSearchList() ? loadSearchRecords() : loadRequestRecords();

    setState(() {});
  }

  void pushPrivateMessagePage(ProfileData onSelectedUserData) {
    Navigator.push(
        context,
        PageTransition(
            child: ProfileMessagerChat(onSelectedUserData,
                key: new Key(new Uuid().toString())),
            type: PageTransitionType.rightToLeft));
  }

  void rejectRequest(String userId) {
    print('reject follower request : userID ? ' + userId);
  }

  /*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/
  void loadRequestRecords() async {
    waitingUsers.clear();
//TODO : request the request result by server API

//Debug
    int demoAmount = 2;
    for (var i = 0; i < demoAmount; i++) {
      waitingUsers.add(new ProfileData(
          id: Uuid().hashCode.toString(),
          birthday: '2020-01-08',
          name: 'Demo' + i.toString(),
          nickName: 'Demo' + i.toString(),
          gender: 'Girl',
          parentKind: 'Mum',
          parentEmail: 'email',
          bloodType: 'A',
          profilePic: '',
          borned: 1));
    }
    setState(() {
      print('user waiting count' + waitingUsers.length.toString());
    });
  }

  void loadSearchRecords() async {
    users.clear();
//TODO : request the search result by server API

//TODO :
    // await widget.getPostDatas().then((value) {
    //   value!.forEach((element) {
    // users.add(element);
    //   });
    //   setState(() {});
    // });

    //Debug
    int demoAmount = 10;
    if (onSearchingKeyword.length > 0) demoAmount = 0;
    for (var i = 0; i < demoAmount; i++) {
      users.add(new ProfileData(
          id: Uuid().hashCode.toString(),
          birthday: '2020-01-08',
          name: 'Demo' + i.toString(),
          nickName: 'Demo' + i.toString(),
          gender: 'Girl',
          parentKind: 'Mum',
          parentEmail: 'email',
          bloodType: 'A',
          profilePic: '',
          borned: 1));
    }
    setState(() {
      print('user result count' + users.length.toString());
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
    //     myData = data;
    //   }
    // });

    localRecordNeedUpdate();
  }

  void localRecordNeedUpdate() {
    //sim to load albums

    loadSearchRecords();
    loadRequestRecords();
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
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(topBarOffSet)),
                      width: MediaQuery.of(context).size.width,
                      height: globalDataStore
                          .getResponsiveSize(topBarHeight + topBarOffSet),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Stack(
                        children: [
                          Container(
                              width: globalDataStore.getResponsiveSize(30),
                              margin: EdgeInsets.only(
                                  left: globalDataStore.getResponsiveSize(15),
                                  right: globalDataStore.getResponsiveSize(5)),
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
                            width: double.maxFinite,
                            height: double.maxFinite,
                            alignment: Alignment.center,
                            child: Text(titleName,
                                style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontStyle: FontStyle.normal,
                                    fontSize:
                                        globalDataStore.getResponsiveSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromRGBO(13, 54, 88, 1))),
                          )
                        ],
                      ),
                    )),
                //segment buttons
                Positioned(
                  top: globalDataStore
                      .getResponsiveSize(topBarHeight + topBarOffSet),
                  child: Container(
                      padding: EdgeInsets.only(
                          bottom: globalDataStore.getResponsiveSize(
                              isSearchList()
                                  ? 0
                                  : waitingListSegmentBottomPadding)),
                      decoration: BoxDecoration(color: Colors.white),
                      child: segment(
                          MediaQuery.of(context).size.width,
                          segmentWidgetHeight,
                          [
                            segmentAll,
                            waitingUsers.length.toString() + ' Request(s)'
                          ],
                          segmentOnSelected,
                          onSegmentChanged,
                          needBorder: false)),
                ),

                //Searching block
                if (isSearchList()) ...[
                  Positioned(
                      top: globalDataStore.getResponsiveSize(topBarHeight +
                          topBarOffSet +
                          (segmentWidgetHeight + 16)),
                      child: SearchingBlock(
                        MediaQuery.of(context).size.width,
                        globalDataStore.getResponsiveSize(searchingBarHeight),
                        globalDataStore.getResponsiveSize(16),
                        () {},
                        onChanged: (inputVal) {
                          print('on Change >> ' + inputVal);
                          onSearchingKeyword = inputVal;
                        },
                        onSubmitted: (submittedVal) {
                          loadSearchRecords();
                        },
                      )),
                ],

                //contents
                if (isSearchList()) ...[
                  Positioned(
                    top: globalDataStore.getResponsiveSize(topBarHeight +
                        topBarOffSet +
                        searchingBarHeight +
                        (segmentWidgetHeight + 16)),
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          globalDataStore.getResponsiveSize(topBarHeight +
                              topBarOffSet +
                              searchingBarHeight +
                              (segmentWidgetHeight + 16)),
                      width: MediaQuery.of(context).size.width -
                          globalDataStore.getResponsiveSize(0),
                      // padding: EdgeInsets.symmetric(
                      //     horizontal: globalDataStore.getResponsiveSize(15)),
                      // decoration: BoxDecoration(color: Colors.white),
                      child: (users.length > 0)
                          ? ListView(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      globalDataStore.getResponsiveSize(5)),
                              children: List.generate(users.length, (index) {
                                return assetBlock(index, (onclickedIndex) {
                                  print('should push [' +
                                      onclickedIndex.toString() +
                                      '] user info');
                                  pushPrivateMessagePage(users[onclickedIndex]);
                                }, (strVal) {},
                                    data: users[index],
                                    isRequested: requestedUsers
                                        .contains(users[index].id));
                              }),
                            )
                          : Center(
                              child:
                                  Text('No user was found', style: ts_noRecord),
                            ),
                    ),
                  ),
                ] else ...[
                  Positioned(
                    top: globalDataStore.getResponsiveSize(topBarHeight +
                        topBarOffSet +
                        (segmentWidgetHeight + 16) +
                        waitingListTopMargin),
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          globalDataStore.getResponsiveSize(topBarHeight +
                              topBarOffSet +
                              segmentWidgetHeight +
                              waitingListTopMargin +
                              waitingListSegmentBottomPadding),
                      width: MediaQuery.of(context).size.width -
                          globalDataStore.getResponsiveSize(0),
                      margin: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(10)),
                      // decoration: BoxDecoration(color: Colors.amber),
                      child: (waitingUsers.length > 0)
                          ? ListView(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      globalDataStore.getResponsiveSize(5)),
                              children:
                                  List.generate(waitingUsers.length, (index) {
                                return messagefollowerRequestBlock(index,
                                    (onclickedIndex) {
                                  print('should push [' +
                                      onclickedIndex.toString() +
                                      '] user info');
                                  pushPrivateMessagePage(
                                      waitingUsers[onclickedIndex]);
                                }, (strVal) {
                                  print(
                                      'Waiting User accept button pressed : ?? ' +
                                          strVal);
                                }, rejectRequest, data: waitingUsers[index]);
                              }),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height:
                                        globalDataStore.getResponsiveSize(48),
                                    margin: EdgeInsets.only(
                                        bottom: globalDataStore
                                            .getResponsiveSize(10)),
                                    child: Image(
                                      image: AssetImage(
                                          'assets/images/icon_message.png'),
                                    ),
                                  ),
                                  Text('No Message Request', style: ts_noRecord)
                                ],
                              ),
                            ),
                    ),
                  ),
                ]
              ],
            )),
        onWillPop: () async {
          return true;
        });
  }
}

Widget assetBlock(
    int idx, Function(int) onPress, Function(String) followOnPressed,
    {String mediaSetName = '',
    int totalMedias = 0,
    bool isRequested = false,
    ProfileData data = const ProfileData()}) {
  const double iconSize = 32;

  return Container(
    // width: width,
    // height: globalDataStore.getResponsiveSize(235),
    margin: EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(5)),
    padding:
        EdgeInsets.symmetric(horizontal: globalDataStore.getResponsiveSize(20)),
    decoration: BoxDecoration(color: Colors.white),
    child: TextButton(
      onPressed: () {
        onPress(idx);
      },
      child: Row(
        children: [
          Container(
            width: globalDataStore.getResponsiveSize(iconSize),
            height: globalDataStore.getResponsiveSize(iconSize),
            margin: EdgeInsets.only(
                right: globalDataStore.getResponsivePositioning(10)),
            decoration: BoxDecoration(
                color: HexColor('#F4F4F5'),
                image: DecorationImage(
                    image: loadImageAsset(data.profilePic), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(
                    globalDataStore.getResponsiveSize(13))),
            child: null,
          ),

          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  height: globalDataStore.getResponsiveSize(16),
                  child: Text(
                    (data.id.length > 0 ? data.nickName : "New Kid"),
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'SFProText-Bold',
                        fontSize: globalDataStore.getResponsiveSize(12),
                        letterSpacing: -0.24,
                        fontWeight: FontWeight.w500),
                  )),
              Container(
                  height: globalDataStore.getResponsiveSize(16),
                  child: Text(
                    '{online status}',
                    style: TextStyle(
                        color: Color.fromRGBO(13, 54, 88, 1),
                        fontFamily: 'SFProText-Bold',
                        fontSize: globalDataStore.getResponsiveSize(11),
                        letterSpacing: -0.24,
                        fontWeight: FontWeight.w400),
                  )),
            ],
          )),

          // User Nickname

          // indicator
          Container(
            width: globalDataStore.getResponsiveSize(24),
            height: globalDataStore.getResponsiveSize(24),
            margin: EdgeInsets.symmetric(
                vertical: globalDataStore.getResponsiveSize(5)),
            decoration: BoxDecoration(
                color: HexColor('#FF3B30'),
                borderRadius: getThumbRadius(iconSize)),
            alignment: Alignment.center,
            child: Text(
              '1',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFProText-Bold',
                  fontSize: globalDataStore.getResponsiveSize(15),
                  letterSpacing: -0.24,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    ),
  );
}

Widget messagefollowerRequestBlock(int idx, Function(int) onPress,
    Function(String) followOnPressed, Function(String) rejectOnPressed,
    {String mediaSetName = '',
    int totalMedias = 0,
    ProfileData data = const ProfileData()}) {
  const double iconSize = 32;

  return Container(
    // width: width,
    // height: globalDataStore.getResponsiveSize(235),
    margin: EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(5)),
    padding:
        EdgeInsets.symmetric(horizontal: globalDataStore.getResponsiveSize(20)),
    decoration: BoxDecoration(color: Colors.white),
    child: TextButton(
      onPressed: () {
        onPress(idx);
      },
      child: Row(
        children: [
          Container(
            width: globalDataStore.getResponsiveSize(iconSize),
            height: globalDataStore.getResponsiveSize(iconSize),
            margin: EdgeInsets.only(
                right: globalDataStore.getResponsivePositioning(10)),
            decoration: BoxDecoration(
                color: HexColor('#F4F4F5'),
                image: DecorationImage(
                    image: loadImageAsset(data.profilePic), fit: BoxFit.cover),
                borderRadius: getThumbRadius(iconSize)),
            child: null,
          ),

          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  height: globalDataStore.getResponsiveSize(16),
                  // margin: EdgeInsets.symmetric(
                  //     vertical: globalDataStore.getResponsiveSize(5)),
                  child: Text(
                    (data.id.length > 0 ? data.nickName : "New Kid"),
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'SFProText-Bold',
                        fontSize: globalDataStore.getResponsiveSize(12),
                        letterSpacing: -0.24,
                        fontWeight: FontWeight.w500),
                  )),
              Container(
                  height: globalDataStore.getResponsiveSize(16),
                  child: Text(
                    '{online status}',
                    style: TextStyle(
                        color: Color.fromRGBO(13, 54, 88, 1),
                        fontFamily: 'SFProText-Bold',
                        fontSize: globalDataStore.getResponsiveSize(11),
                        letterSpacing: -0.24,
                        fontWeight: FontWeight.w400),
                  )),
            ],
          )),

          // User Nickname

          // button allow
          Container(
            height: globalDataStore.getResponsiveSize(28),
            width: globalDataStore.getResponsiveSize(74),
            margin:
                EdgeInsets.only(right: globalDataStore.getResponsiveSize(10)),
            padding: EdgeInsets.symmetric(
                horizontal: globalDataStore.getResponsiveSize(5)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    globalDataStore.getResponsiveSize(28 * 0.2)),
                border: Border.all(width: 0.5, color: Colors.black),
                color: Colors.white),
            child: TextButton(
              onPressed: () {
                followOnPressed(data.id);
              },
              style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
              child: Text(
                'Accept',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'SFProText',
                  fontSize: globalDataStore.getResponsiveSize(11),
                  letterSpacing: -0.15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // button reject
          Container(
              width: globalDataStore.getResponsiveSize(24),
              height: globalDataStore.getResponsiveSize(24),
              margin: EdgeInsets.symmetric(
                  vertical: globalDataStore.getResponsiveSize(5)),
              child: IconButton(
                onPressed: () {
                  rejectOnPressed(data.id);
                },
                icon: Icon(
                  Icons.cancel_outlined,
                  color: Colors.grey,
                ),
                padding: EdgeInsets.zero,
              )),
        ],
      ),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    ),
  );
}
