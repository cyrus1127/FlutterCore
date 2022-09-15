import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetail extends CommonStatefulWidget {
  const PostDetail(this.postData, {required Key? key}) : super(key: key);
  final PostData postData;

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double endAnimatedPosition = -40;
  double editingBlockHeight = 565;
  double datetimePickerHeight = 216;
  double quaityBarHeight = 45;
  double inputFieldHeight = 80;

  double layoutMargin = globalDataStore.getResponsiveSize(15); //for builds bar

  bool showAsGallery = false;
  bool needShowPhotoView = false;
  String selectedPhotoAsset = '';

  var rand = new Random(Random().nextInt(1000));

  int onSelectedMedia = -1;

  ProfileData myData = ProfileData();
  List<PostComment> commentRecords = [];

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  void showPhotoView(String resourcePath) {
    setState(() {
      needShowPhotoView = true;
      selectedPhotoAsset = resourcePath;
    });
  }

  void showPhotoGalaryView(String resourcePath) {
    setState(() {
      needShowPhotoView = true;
      showAsGallery = true;
      selectedPhotoAsset = resourcePath;
    });
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  void makeNewComment(String onChangeValue) {
    print('');
  }

  /*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/

  void loadPostRecords() async {
    // postRecords.clear();
    // await widget.getPostDatas().then((value) {
    //   value!.forEach((element) {
    //     postRecords.add(element);
    //   });
    //   setState(() {});
    // });
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileID = prefs.getString('selectedProfile') ?? '';
    List<ProfileData>? datas = await widget.getProfileDatas();

    Future.forEach(datas!, (element) {
      var data = element as ProfileData;
      print('stored profile : $data ??' + data.id + ' , ' + data.name);
      if (data.id.compareTo(profileID) == 0) {
        myData = data;
      }
    });

    localRecordNeedUpdate();
  }

  void localRecordNeedUpdate() {
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
                // Topbar
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
                          Center(
                            child: Text('Comment',
                                style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontStyle: FontStyle.normal,
                                    fontSize:
                                        globalDataStore.getResponsiveSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromRGBO(13, 54, 88, 1))),
                          ),
                        ],
                      ),
                    )),

                // PostBlock
                Positioned(
                  top: globalDataStore
                      .getResponsiveSize(topBarHeight + topBarOffSet),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore
                            .getResponsiveSize(topBarHeight + topBarOffSet),
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(5),
                          bottom: globalDataStore
                              .getResponsivePositioning(inputFieldHeight)),
                      children: List.generate(5 + 1, (index) {
                        if (index == 0) {
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: globalDataStore.getResponsiveSize(10),
                            ),
                            // decoration: BoxDecoration(color: Colors.amber),
                            child: postBlock(
                              widget.postData,
                              globalDataStore.getResponsiveSize(10),
                              MediaQuery.of(context).size.width,
                              (postData) {},
                              (postData) {
                                widget.pushImageZoomingView(
                                    postData.postMediaLink, context);
                              },
                            ),
                          );
                        }
                        //else show
                        return commentBlock(
                            MediaQuery.of(context).size.width,
                            PostComment(
                                ownerName: 'Name',
                                content:
                                    'Text text text text text text text text text text text text'));
                      }),
                    ),
                  ),
                ),

                //Create new post
                Positioned(
                    bottom: 0,
                    child: createNewPostBlock(
                        MediaQuery.of(context).size.width,
                        globalDataStore.getResponsiveSize(inputFieldHeight),
                        globalDataStore.getResponsiveSize(15),
                        myData,
                        () {},
                        needMediaButton: false,
                        supportDirectInput: true,
                        onChanged: makeNewComment)),

                if (needShowPhotoView) ...[
                  Positioned(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: PhotoView(
                        imageProvider: AssetImage(selectedPhotoAsset),
                        onTapUp: (context, details, controllerValue) {
                          print('on tap Up');
                        },
                      ),
                    ),
                  ),

                  //Top bar controller  with close buttons & progressing
                  Positioned(
                      top: topBarOffSet,
                      child: Container(
                          height: globalDataStore.getResponsiveSize(25),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              //Close button
                              Container(
                                width: widget.getResponsiveSize(25),
                                margin: EdgeInsets.only(
                                    left: widget.getResponsiveSize(10)),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      needShowPhotoView = false;
                                      showAsGallery = false;
                                    });
                                  },
                                  child: Image(
                                    width: widget.getResponsiveSize(25),
                                    image: AssetImage(
                                        'assets/images/icon_close3.png'),
                                  ),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                ),
                              ),
                              // viewing progress
                              if (showAsGallery) ...[
                                Expanded(
                                  child: Container(
                                      // decoration:
                                      //     BoxDecoration(color: Colors.amber),
                                      padding: EdgeInsets.only(
                                          right: globalDataStore
                                              .getResponsiveSize(25 + 10)),
                                      child: Text(
                                        '5 of 1,032',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: HexColor('#F2A488'),
                                            fontFamily: 'SFProText-Semibold',
                                            fontSize: globalDataStore
                                                .getResponsiveSize(20),
                                            fontWeight: FontWeight.w600),
                                      )),
                                )
                              ]
                            ],
                          ))),

                  //Bottom bar with buttons
                  Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            //
                            Container(
                              height: globalDataStore.getResponsiveSize(35),
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: globalDataStore
                                      .getResponsivePositioning(15)),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      myData.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: globalDataStore
                                              .getResponsiveSize(14),
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'SFProText-Bold'),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        myData.formatedDateOfBirth(),
                                        style: TextStyle(
                                            color: HexColor('#C4C4C4'),
                                            fontSize: globalDataStore
                                                .getResponsiveSize(10),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'SFProText-Medium',
                                            letterSpacing: -0.24),
                                      )),
                                ],
                              ),
                            ),

                            //Post short Summer
                            Container(
                              height: globalDataStore.getResponsiveSize(40),
                              margin: EdgeInsets.only(
                                  left: layoutMargin, right: layoutMargin),
                              padding: EdgeInsets.only(
                                  top: globalDataStore
                                      .getResponsivePositioning(8),
                                  bottom: globalDataStore
                                      .getResponsivePositioning(10)),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.white))),
                              child: Row(
                                children: [
                                  postSummerWidget(
                                      'icon_like_white', widget.postData.likes,
                                      textColor: Colors.white),
                                  postSummerWidget('icon_comment_white',
                                      widget.postData.comments,
                                      textColor: Colors.white),
                                ],
                              ),
                            ),
                            //Post action button
                            Container(
                              height: globalDataStore.getResponsiveSize(30),
                              margin: EdgeInsets.symmetric(
                                  horizontal: layoutMargin,
                                  vertical: globalDataStore
                                      .getResponsivePositioning(13)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: layoutMargin),
                              child: Row(
                                children: [
                                  postActionButtonWidget(
                                      () {}, 'icon_like_white', 'Like',
                                      textColor: Colors.white),
                                  Spacer(),
                                  postActionButtonWidget(
                                      () {}, 'icon_comment_white', 'Comment',
                                      textColor: Colors.white),
                                  Spacer(),
                                  postActionButtonWidget(
                                      () {}, 'icon_share_white', 'Share',
                                      textColor: Colors.white),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                ]
              ],
            )),
        onWillPop: () async {
          return false;
        });
  }
}

class PostComment {
  PostComment(
      {this.id = '',
      this.ownerName = '',
      this.content = '',
      this.datetime = '',
      this.likes = 0});
  final String id;
  final String ownerName;
  final String content;
  final String datetime;
  final int likes;

  PostComment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        ownerName = json['ownerName'],
        content = json['content'],
        datetime = json['datetime'],
        likes = json['likes'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerName': ownerName,
        'content': content,
        'datetime': datetime,
        'likes': likes
      };
}

Widget commentBlock(double width, PostComment data) {
  String postDatePassed = 'current';
  if (data.datetime.length > 0) {
    postDatePassed = globalDataStore.getTimeDiff(data.datetime);
  }

  return Container(
    height: globalDataStore.getResponsiveSize(115),
    width: width,
    child: Row(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(
                top: globalDataStore.getResponsivePositioning(5),
                left: globalDataStore.getResponsivePositioning(15),
                right: globalDataStore.getResponsivePositioning(5)),
            width: globalDataStore.getResponsiveSize(32),
            child: Image(
              image: AssetImage('assets/images/profile_default.png'),
            ),
          ),
        ),
        Container(
          width: width - globalDataStore.getResponsiveSize(32 + 30),
          padding: EdgeInsets.symmetric(
              horizontal: globalDataStore.getResponsivePositioning(5),
              vertical: globalDataStore.getResponsivePositioning(5)),
          decoration: BoxDecoration(
              // color: Colors.amber,
              ),
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                height: globalDataStore.getResponsiveSize(79),
                padding: EdgeInsets.symmetric(
                    horizontal: globalDataStore.getResponsivePositioning(10),
                    vertical: globalDataStore.getResponsivePositioning(10)),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(242, 164, 136, 0.2),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                            globalDataStore.getResponsiveSize(14)),
                        bottomLeft: Radius.circular(
                            globalDataStore.getResponsiveSize(14)),
                        bottomRight: Radius.circular(
                            globalDataStore.getResponsiveSize(14)))),
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      height: globalDataStore.getResponsiveSize(25),
                      child: Row(
                        children: [
                          Text(data.ownerName,
                              style: TextStyle(
                                fontSize: globalDataStore.getResponsiveSize(14),
                                fontFamily: 'SFProText-Bold',
                                fontWeight: FontWeight.w700,
                              )),
                          Spacer(),
                          Text(
                            postDatePassed,
                            style: TextStyle(
                                fontSize: globalDataStore.getResponsiveSize(10),
                                fontFamily: 'SFProText-Medium',
                                fontWeight: FontWeight.w500,
                                color: HexColor('#C4C4C4')),
                          ),
                          Container(
                            width: globalDataStore.getResponsiveSize(25),
                            margin: EdgeInsets.only(
                                left: globalDataStore.getResponsiveSize(10)),
                            child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                child: Image(
                                    image: AssetImage(
                                        'assets/images/icon_more.png'))),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      child: Text(data.content,
                          style: TextStyle(
                            fontSize: globalDataStore.getResponsiveSize(14),
                            fontFamily: 'SFProText-Regular',
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.maxFinite,
                height: globalDataStore.getResponsiveSize(20),
                margin: EdgeInsets.symmetric(
                    vertical: globalDataStore.getResponsivePositioning(3),
                    horizontal: globalDataStore.getResponsivePositioning(10)),
                child: Row(
                  children: [
                    Text('Likes',
                        style: TextStyle(
                            fontSize: globalDataStore.getResponsiveSize(10),
                            fontFamily: 'SFProText-Semibold',
                            fontWeight: FontWeight.w600,
                            color: HexColor('#0C3658'))),
                    Container(
                      margin: EdgeInsets.only(
                          left: globalDataStore.getResponsivePositioning(5)),
                      child: Text('Reply',
                          style: TextStyle(
                              fontSize: globalDataStore.getResponsiveSize(10),
                              fontFamily: 'SFProText-Semibold',
                              fontWeight: FontWeight.w600,
                              color: HexColor('#0C3658'))),
                    ),
                    Spacer(),
                    postSummerWidget('icon_like_on', 1234,
                        fixedPreTextWidth: false)
                  ],
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
}
