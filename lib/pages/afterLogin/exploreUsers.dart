import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/profilePushView.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

class ExploreUsers extends CommonStatefulWidget {
  const ExploreUsers({required Key? key}) : super(key: key);

  @override
  _ExploreUsersState createState() => _ExploreUsersState();
}

class _ExploreUsersState extends State<ExploreUsers> {
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double endAnimatedPosition = -40;
  double editingBlockHeight = 565;
  double datetimePickerHeight = 216;
  double quaityBarHeight = 45;
  double searchingBarHeight = 82;
  double listHeaderMargin = 10;
  double listHeaderPadding = 20;
  double listHeaderHeight = 25;

  double layoutMargin = globalDataStore.getResponsiveSize(15); //for builds bar

  // bool showAsGallery = false;
  // bool needShowPhotoView = false;
  String titleName = 'Explore Buddies';
  TextStyle ts_1 = TextStyle(
      color: Color.fromRGBO(13, 54, 88, 1),
      fontFamily: 'SFProText',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      fontSize: globalDataStore.getResponsiveSize(16));

  int onSelectedMedia = -1;
  String onSearchingKeyword = '';
  ProfileData myData = ProfileData();
  List<ProfileData> users = [];
  List<String> requestedUsers = [];

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  void pushUserProfilePage(ProfileData onSelectedUserData) {
    Navigator.push(
        context,
        PageTransition(
            child: ProfilePushView(onSelectedUserData,
                key: new Key(new Uuid().toString())),
            type: PageTransitionType.rightToLeft));
  }

  void makeFollowRequest(String userId) {
    print('user follow button on click user ID ? ' + userId);

    //local logic
    for (ProfileData data in users) {
      if (!requestedUsers.contains(userId)) {
        requestedUsers.add(userId);
      }

      print('Do request simulation');
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        setState(() {});
      });
    }

    //TODO : integrated with server API
  }

  /*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/

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
                            child: Text(titleName, style: ts_1),
                          )
                        ],
                      ),
                    )),

                //Searching block
                Positioned(
                    top: globalDataStore
                        .getResponsiveSize(topBarHeight + topBarOffSet),
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

                //contents-header
                Positioned(
                    top: globalDataStore.getResponsiveSize(
                        topBarHeight + topBarOffSet + searchingBarHeight),
                    child: Container(
                      margin: EdgeInsets.only(
                        top:
                            globalDataStore.getResponsiveSize(listHeaderMargin),
                      ),
                      padding: EdgeInsets.only(
                        top: globalDataStore
                            .getResponsiveSize(listHeaderPadding),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: globalDataStore.getResponsiveSize(
                          listHeaderPadding + listHeaderHeight),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Text(
                        (onSearchingKeyword.length > 0
                            ? 'Results for ' + onSearchingKeyword
                            : 'Born on the same day as Kavis'),
                        style: ts_1,
                      ),
                    )),

                //contents
                Positioned(
                  top: globalDataStore.getResponsiveSize(topBarHeight +
                      topBarOffSet +
                      searchingBarHeight +
                      (listHeaderHeight +
                          listHeaderMargin +
                          listHeaderPadding)),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore.getResponsiveSize(topBarHeight +
                            topBarOffSet +
                            searchingBarHeight +
                            (listHeaderHeight +
                                listHeaderMargin +
                                listHeaderPadding)),
                    width: MediaQuery.of(context).size.width -
                        globalDataStore.getResponsiveSize(0),
                    padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(15)),
                    decoration: BoxDecoration(color: Colors.white),
                    child: (users.length > 0)
                        ? GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing:
                                globalDataStore.getResponsiveSize(10),
                            mainAxisSpacing:
                                globalDataStore.getResponsiveSize(10),
                            childAspectRatio:
                                (globalDataStore.getResponsiveSize(162.5) /
                                    globalDataStore.getResponsiveSize(235)),
                            padding: EdgeInsets.symmetric(
                                vertical: globalDataStore.getResponsiveSize(5)),
                            children: List.generate(users.length, (index) {
                              return assetBlock(index, (onclickedIndex) {
                                print('should push [' +
                                    onclickedIndex.toString() +
                                    '] user info');
                                pushUserProfilePage(users[onclickedIndex]);
                              }, makeFollowRequest,
                                  data: users[index],
                                  isRequested:
                                      requestedUsers.contains(users[index].id));
                            }),
                          )
                        : Center(
                            child: Text('No user was found'),
                          ),
                  ),
                ),
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
  const double iconSize = 95;

  double width;
  String resourcePath;
  bool onSelected;

  bool showAlbumeTitle = mediaSetName.length > 0;
  String photoAmontText = '$totalMedias Photo' + (totalMedias > 1 ? 's' : '');

  return Container(
    // width: width,
    // height: globalDataStore.getResponsiveSize(235),
    margin: EdgeInsets.all(globalDataStore.getResponsiveSize(3)),
    // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
        // image:
        //     DecorationImage(image: AssetImage(resourcePath), fit: BoxFit.cover),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        // border:
        //     Border.all(width: onSelected ? 3 : 0, color: HexColor('#FFB2B2')),
        boxShadow: [
          BoxShadow(
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(0, 2),
              color: Color.fromRGBO(0, 0, 0, 0.4))
        ],
        color: Colors.white),
    child: TextButton(
        onPressed: () {
          onPress(idx);
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
                        top: globalDataStore.getResponsivePositioning(14),
                        bottom: globalDataStore.getResponsivePositioning(10)),
                    padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(22)),
                    decoration: BoxDecoration(
                        color: HexColor('#F4F4F5'),
                        image: DecorationImage(
                            image: loadImageAsset(data.profilePic),
                            fit: BoxFit.cover),
                        borderRadius: getThumbRadius(iconSize)),
                    child: null,
                  ),
                  if (data.id.length > 0) ...[
                    Positioned(
                        bottom: globalDataStore.getResponsiveSize(10),
                        right: 0,
                        child: Container(
                          width: 25,
                          child: data.borned == 1
                              ? Image(
                                  image: AssetImage('assets/images/icon_' +
                                      data.gender.toLowerCase() +
                                      '.png'),
                                )
                              : null,
                        ))
                  ]
                ],
              ),
            ),

            // User Nickname
            Container(
                height: globalDataStore.getResponsiveSize(18),
                margin: EdgeInsets.symmetric(
                    vertical: globalDataStore.getResponsiveSize(5)),
                child: Text(
                  (data.id.length > 0 ? data.nickName : "New Kid"),
                  style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'SFProText-Bold',
                      fontSize: globalDataStore.getResponsiveSize(15),
                      letterSpacing: -0.24,
                      fontWeight: FontWeight.w700),
                )),

            // address
            Container(
              height: globalDataStore.getResponsiveSize(18),
              margin: EdgeInsets.symmetric(
                  vertical: globalDataStore.getResponsiveSize(5)),
              alignment: Alignment.center,
              child: Text(
                '{ Address/location }',
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    fontFamily: 'SFProText-Bold',
                    fontSize: globalDataStore.getResponsiveSize(11),
                    letterSpacing: -0.24,
                    fontWeight: FontWeight.w700),
              ),
            ),

            // following linkage
            Container(
              height: globalDataStore.getResponsiveSize(24),
              margin:
                  EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (data.id.length > 0) ...[
                    Image(image: AssetImage('assets/images/icon_link.png')),
                  ],
                  Text(
                    data.id.length > 0 ? '{ babies count }' : '',
                    style: TextStyle(
                        color: HexColor('#F1A387'),
                        fontFamily: 'SFProText',
                        fontSize: globalDataStore.getResponsiveSize(11),
                        letterSpacing: -0.1,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),

            //Follow button
            if (data.followed != 1) ...[
              Container(
                height: globalDataStore.getResponsiveSize(28),
                width: globalDataStore.getResponsiveSize(74),
                margin:
                    EdgeInsets.only(top: globalDataStore.getResponsiveSize(10)),
                padding: EdgeInsets.symmetric(
                    horizontal: globalDataStore.getResponsiveSize(5)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        globalDataStore.getResponsiveSize(28 * 0.2)),
                    border: Border.all(
                        width: 0.5,
                        color: isRequested ? Colors.white : Colors.black),
                    color: isRequested
                        ? Color.fromRGBO(151, 151, 151, 1)
                        : Colors.white),
                child: TextButton(
                  onPressed: () {
                    followOnPressed(data.id);
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                  child: Text(
                    isRequested ? 'Requested' : 'Follow',
                    style: TextStyle(
                      color: isRequested ? Colors.white : Colors.black,
                      fontFamily: 'SFProText',
                      fontSize: globalDataStore.getResponsiveSize(11),
                      letterSpacing: -0.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ]
          ],
        )),
  );
}
