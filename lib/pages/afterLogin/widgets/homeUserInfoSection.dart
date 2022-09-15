import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

Widget userShortInfo(
    double profileShortDetailFieldHeight,
    double contextWidth,
    ProfileData myData,
    VoidCallback followPressed,
    VoidCallback photoAlbumPressed,
    BuildContext context,
    {bool isSelfProfile = true,
    bool isFollowRequested = false}) {
  TextStyle t1 = TextStyle(
      color: Color.fromRGBO(14, 54, 88, 1),
      fontSize: globalDataStore.getResponsiveSize(16),
      fontFamily: 'SF Pro',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700);

  TextStyle t2 = TextStyle(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      fontSize: globalDataStore.getResponsiveSize(11),
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w500);

  TextStyle t3 = TextStyle(
      fontSize: globalDataStore.getResponsiveSize(14),
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w700);

  DateTime bDay = DateTime.parse(myData.birthday);
  String birth = DateFormat.yMMMd().format(bDay).replaceAll(',', '');

  return Container(
      padding: EdgeInsets.only(
          left: globalDataStore.getResponsiveSize(15),
          right: globalDataStore.getResponsiveSize(15),
          bottom: globalDataStore.getResponsiveSize(15)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Stack(
        children: [
          Container(
            height: globalDataStore
                .getResponsiveSize(profileShortDetailFieldHeight * 0.75),
            child: Row(
              children: [
                Container(
                  width: globalDataStore.getResponsiveSize(75),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        height: globalDataStore.getResponsiveSize(70),
                        width: globalDataStore.getResponsiveSize(70),
                        child: PhysicalModel(
                            color: Color.fromRGBO(232, 235, 237, 1),
                            shape: BoxShape.rectangle,
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.circular(
                                globalDataStore.getResponsiveSize(30)),
                            child: getThumbnailImage(myData.profilePic)),
                      ),
                      Text(
                        myData.nickName,
                        style: TextStyle(
                            fontSize: globalDataStore.getResponsiveSize(16),
                            fontFamily: 'SFProText-Bold',
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      //Date birth
                      Container(
                        height: globalDataStore.getResponsiveSize(24),
                        margin: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: globalDataStore.getResponsiveSize(5)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: globalDataStore.getResponsiveSize(0)),
                        child: Row(
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Image(
                                    height:
                                        globalDataStore.getResponsiveSize(24),
                                    image: AssetImage(
                                        'assets/images/icon_birth.png'))),
                            if (myData.borned == 1) ...[
                              Container(
                                margin: EdgeInsets.only(
                                    top: globalDataStore
                                        .getResponsivePositioning(2),
                                    left: 5),
                                width: globalDataStore.getResponsiveSize(120),
                                child: Text(birth,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: globalDataStore
                                            .getResponsiveSize(16),
                                        fontFamily: 'SF Pro',
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1),
                                    textAlign: TextAlign.left),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Image(
                                      height:
                                          globalDataStore.getResponsiveSize(24),
                                      image: AssetImage(
                                          'assets/images/icon_zodiac_aries.png'))),
                              Expanded(
                                child: Text('(' + myData.daysStrOfAge() + ')',
                                    style: TextStyle(
                                        color: myData.colorOfGender(),
                                        fontSize: globalDataStore
                                            .getResponsiveSize(16),
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left),
                              ),
                            ] else ...[
                              Container(
                                margin: EdgeInsets.only(
                                    top: globalDataStore
                                        .getResponsivePositioning(2),
                                    left: 5),
                                child: Text(birth,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: globalDataStore
                                            .getResponsiveSize(16),
                                        fontFamily: 'SF Pro',
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1),
                                    textAlign: TextAlign.left),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      top: globalDataStore
                                          .getResponsivePositioning(2),
                                      left: 5),
                                  width: globalDataStore.getResponsiveSize(120),
                                  child: Text('(' + myData.daysStrOfAge() + ')',
                                      style: TextStyle(
                                          color: myData.colorOfGender(),
                                          fontSize: globalDataStore
                                              .getResponsiveSize(16),
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.left)),
                            ]
                          ],
                        ),
                      ),
                      //weight & height
                      if (myData.borned == 1) ...[
                        Container(
                          height: globalDataStore.getResponsiveSize(24),
                          margin: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: globalDataStore.getResponsiveSize(5)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: globalDataStore.getResponsiveSize(0)),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/icon_height.png'))),
                              Container(
                                width: globalDataStore.getResponsiveSize(85),
                                child: Text('NAN' + '(cm)',
                                    style: t3, textAlign: TextAlign.left),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/icon_weight.png'))),
                              Expanded(
                                child: Text('NAN' + '(kg)',
                                    style: t3, textAlign: TextAlign.left),
                              ),
                              // Image(
                              //     image: AssetImage(
                              //         'assets/images/icon_chart_h_weight.png')),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                            height: globalDataStore.getResponsiveSize(28),
                            margin: EdgeInsets.symmetric(
                                vertical: globalDataStore.getResponsiveSize(5)),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    globalDataStore.getResponsiveSize(5)),
                            child: Row(children: [
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: Text(
                                                'Really!? It’s very Excited!'),
                                            content: Text(
                                                'We are really excited that your baby has arrived safe and sound!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Navigator.pop(context);
                                                  // Navigator.push(
                                                  //     context,
                                                  //     PageTransition(
                                                  //         child: BabyWasBorn(
                                                  //             myData,
                                                  //             key: new Key(
                                                  //                 new Uuid()
                                                  //                     .toString())),
                                                  //         type:
                                                  //             PageTransitionType
                                                  //                 .bottomToTop));
                                                },
                                                child: const Text(
                                                    'Yes, Baby Was Born'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'late'),
                                                child: const Text('late'),
                                              ),
                                            ],
                                          ));
                                },
                                child: Container(
                                  height: globalDataStore.getResponsiveSize(28),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: globalDataStore
                                          .getResponsiveSize(20)),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          globalDataStore
                                              .getResponsiveSize(6.93)),
                                      color: Color.fromRGBO(14, 54, 88, 1)),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Baby Was Born',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                              )
                            ]))
                      ],

                      /// Followers & Following row
                      Container(
                        height: globalDataStore.getResponsiveSize(35),
                        margin: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: globalDataStore.getResponsiveSize(5)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: globalDataStore.getResponsiveSize(0)),
                        child: Row(
                          children: [
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                print(
                                    'friendsFollowers page called by following button pressed');
                                Navigator.pushNamed(
                                    context, '/friendsFollowersList');
                              },
                              child: Container(
                                  width: globalDataStore.getResponsiveSize(120),
                                  child: Container(
                                      child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('20', style: t1),
                                      Text('Followers', style: t2),
                                    ],
                                  ))),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                            ),
                            TextButton(
                              onPressed: () {
                                print(
                                    'friendsFollowers page called by following button pressed');
                                Navigator.pushNamed(
                                    context, '/friendsFollowersList');
                              },
                              child: Container(
                                width: globalDataStore.getResponsiveSize(120),
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              color: HexColor('#C4C4C4'),
                                              width: 0.5)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('20', style: t1),
                                        Text('Following', style: t2),
                                      ],
                                    )),
                              ),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// button row : Following & Photos
          Positioned(
              bottom: globalDataStore.getResponsiveSize(6),
              right: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.only(top: 0),
                child: isSelfProfile
                    ? defaultFollowingPhotosRow(
                        contextWidth, followPressed, photoAlbumPressed)
                    : otherUserProfileFollowingPhotosRow(contextWidth, myData,
                        isFollowRequested, followPressed, photoAlbumPressed),
              ))
        ],
      ));
}

Widget defaultFollowingPhotosRow(double contextWidth,
    VoidCallback followPressed, VoidCallback photoAlbumPressed) {
  Color leftButtonColor = Color.fromRGBO(14, 54, 88, 1);
  return Row(
    children: [
      Container(
        width: contextWidth / 2.3,
        height: globalDataStore.getResponsiveSize(28),
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(globalDataStore.getResponsiveSize(6.93)),
            border: Border.all(color: leftButtonColor)),
        child: TextButton(
            onPressed: followPressed,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              children: [
                Spacer(),
                Text(
                  'Profile',
                  style: TextStyle(
                      color: leftButtonColor,
                      fontFamily: 'SFProText-Semibold',
                      fontSize: globalDataStore.getResponsiveSize(15),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600),
                ),
                Spacer(),
              ],
            )),
      ),
      Container(
        width: contextWidth / 2.3,
        height: globalDataStore.getResponsiveSize(28),
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: HexColor('#F2A488'),
            borderRadius:
                BorderRadius.circular(globalDataStore.getResponsiveSize(6.93))),
        child: TextButton(
          onPressed: photoAlbumPressed,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            'Photos',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFProText-Semibold',
                fontSize: globalDataStore.getResponsiveSize(15),
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );
}

Widget otherUserProfileFollowingPhotosRow(
    double contextWidth,
    ProfileData userData,
    bool isFollowRequested,
    VoidCallback followPressed,
    VoidCallback photoAlbumPressed) {
  return Row(
    children: [
      // Following
      Container(
        width:
            userData.followed == 1 ? (contextWidth / 2.3) : contextWidth * 0.9,
        height: globalDataStore.getResponsiveSize(28),
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: userData.followed == 1
                ? HexColor('#0E3658')
                : (!isFollowRequested
                    ? HexColor('#0E3658')
                    : HexColor('#C4C4C4')),
            borderRadius:
                BorderRadius.circular(globalDataStore.getResponsiveSize(6.93))),
        child: TextButton(
            onPressed: followPressed,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userData.followed == 1
                      ? 'Unfollow'
                      : (!isFollowRequested ? 'Follow' : 'Request Sent'),
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFProText-Semibold',
                      fontSize: globalDataStore.getResponsiveSize(15),
                      fontWeight: FontWeight.w600),
                ),
                if (userData.followed == 1) ...[
                  Container(
                    margin: EdgeInsets.only(
                        left: globalDataStore.getResponsiveSize(5)),
                    height: globalDataStore.getResponsiveSize(6),
                    child: Image(
                        image: AssetImage('assets/images/icon_arrow_w.png')),
                  ),
                ]
              ],
            )),
      ),

      /// Photos
      if (userData.followed == 1) ...[
        Container(
          width: contextWidth / 2.3,
          height: globalDataStore.getResponsiveSize(28),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
              color: HexColor('#F2A488'),
              borderRadius: BorderRadius.circular(
                  globalDataStore.getResponsiveSize(6.93))),
          child: TextButton(
            onPressed: photoAlbumPressed,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              'Photos',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFProText-Semibold',
                  fontSize: globalDataStore.getResponsiveSize(15),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]
    ],
  );
}
