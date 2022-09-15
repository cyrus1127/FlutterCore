import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PostCreate extends CommonStatefulWidget {
  const PostCreate({required Key? key}) : super(key: key);

  @override
  _PostCreateState createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  final TextEditingController _controller = TextEditingController();

  double topBarHeight = 45;
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double tapBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 34 : 10) : 10);
  double AssetsBarHeight = 160;
  double userShortInfoBarHeight = 54;
  double textFieldHeight = 208;

  String id = new Uuid().hashCode.toString();
  String contents = '';
  String selectedPhoto = '';

  DateTime selectedDatetime = DateTime.now().toLocal();

  ProfileData myData = ProfileData();

  int onSelectedMedia = -1;

  void changeType(int typeTo) {
    setState(() {});
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileID = prefs.getString('selectedProfile') ?? '';
    List<ProfileData>? datas = await widget.getProfileDatas();

    Future.forEach(datas!, (element) {
      var data = element as ProfileData;
      print('stored profile : $data ??' + data.id + ' , ' + data.name);
      if (data.id.compareTo(profileID) == 0) {
        setState(() {
          myData = data;
        });
      }
    });
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      globalDataStore.changeNotifier.notifyListeners();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  Widget build(BuildContext context) => KeyboardDismisser(
        child: Scaffold(
            // resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  //// Top bar
                  Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(topBarOffSet)),
                      height: globalDataStore
                          .getResponsiveSize(topBarHeight + topBarOffSet),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0),
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(60, 60, 67, 0.3)))),
                      // padding: EdgeInsets.symmetric(
                      //     vertical: globalDataStore.getResponsiveSize(50)),
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
                                    image:
                                        AssetImage('assets/images/fi_x.png')),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.all(2)),
                              )),
                          Center(
                              child: Text(
                            'New Post',
                            style: TextStyle(
                                color: Color.fromRGBO(13, 54, 88, 1),
                                fontFamily: 'SFProText',
                                fontSize: globalDataStore.getResponsiveSize(16),
                                fontStyle: FontStyle.normal,
                                letterSpacing: -0.33,
                                fontWeight: FontWeight.w700),
                          )),
                          Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: globalDataStore.getResponsiveSize(70),
                                child: TextButton(
                                  onPressed: () async {
                                    await widget
                                        .setPostDatas(new PostData(
                                            id: id,
                                            postOwnerID: myData.id,
                                            postOwnerThumbnails:
                                                myData.profilePic,
                                            postContents: contents,
                                            postMediaLink:
                                                widget.getLocalBundledImage()[
                                                    onSelectedMedia],
                                            postDatetime:
                                                DateTime.now().toString(),
                                            likes: 0,
                                            comments: 0))
                                        .then((saveDone) {
                                      if (saveDone) {
                                        onChange();
                                        setState(() {});
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Post',
                                    style: TextStyle(
                                        color: contents.length > 0
                                            ? HexColor('#FFB2B2')
                                            : Color.fromRGBO(
                                                241, 163, 135, 0.5),
                                        fontFamily: 'SFProText-Semibold',
                                        fontStyle: FontStyle.normal,
                                        fontSize: globalDataStore
                                            .getResponsiveSize(14),
                                        fontWeight: FontWeight.w700),
                                  ),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                ),
                              ))
                        ],
                      )),

//// User info
                  Positioned(
                    top: globalDataStore
                        .getResponsiveSize(topBarHeight + topBarOffSet),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: globalDataStore
                          .getResponsiveSize(userShortInfoBarHeight),
                      margin: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(15),
                      ),
                      // decoration: BoxDecoration(
                      //   color: Colors.amber,
                      // ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: globalDataStore.getResponsiveSize(8)),
                            margin: EdgeInsets.only(
                                right: globalDataStore.getResponsiveSize(8)),
                            child: PhysicalModel(
                              shape: BoxShape.rectangle,
                              color: Colors.transparent,
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(
                                  globalDataStore.getResponsiveSize(13)),
                              child: Image(
                                width: globalDataStore
                                    .getResponsivePositioning(32),
                                height: globalDataStore
                                    .getResponsivePositioning(32),
                                fit: BoxFit.cover,
                                image: loadImageAsset(myData.profilePic),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      top: globalDataStore
                                          .getResponsiveSize(10)),
                                  // height: globalDataStore.getResponsiveSize(30),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      myData.name.length > 0
                                          ? myData.name
                                          : "No name",
                                      style: TextStyle(
                                          fontFamily: 'SFProText-Bold',
                                          fontSize: globalDataStore
                                              .getResponsiveSize(14),
                                          fontWeight: FontWeight.w700),
                                    ),
                                  )),
                              Container(
                                  height: globalDataStore.getResponsiveSize(10),
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: Row(
                                      children: [
                                        Text('Followers',
                                            style: TextStyle(
                                                fontFamily: 'SFProText-Medium',
                                                fontSize: globalDataStore
                                                    .getResponsiveSize(10),
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        Image(
                                            width: globalDataStore
                                                .getResponsiveSize(10),
                                            image: AssetImage(
                                                'assets/images/icon_arrow.png')),
                                      ],
                                    ),
                                  ))
                            ],
                          ))
                        ],
                      ),
                    ),
                  ),

//                   /// Text field
                  Positioned(
                    top: globalDataStore.getResponsiveSize(
                        topBarHeight + topBarOffSet + userShortInfoBarHeight),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          globalDataStore.getResponsiveSize(topBarHeight +
                              topBarOffSet +
                              userShortInfoBarHeight +
                              AssetsBarHeight +
                              30),
                      margin: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(15),
                        vertical: globalDataStore.getResponsiveSize(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(10),
                      ),
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write something...\n\n',
                          border:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                        ),
                        style: TextStyle(
                          fontFamily: 'SFProText-Regular',
                          fontSize: globalDataStore.getResponsiveSize(14),
                          fontWeight: FontWeight.w400,
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        onChanged: (value) {
                          setState(() {
                            contents = value;
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            contents = value;
                          });
                        },
                      ),
                    ),
                  ),

// //// Assets selection Block
                  Positioned(
                    bottom: globalDataStore.getResponsiveSize(tapBarOffSet),
                    left: 0,
                    right: 0,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: globalDataStore
                            .getResponsiveSize(AssetsBarHeight + 30),
                        margin: EdgeInsets.symmetric(
                            horizontal: globalDataStore.getResponsiveSize(10)),
                        padding: EdgeInsets.all(
                            globalDataStore.getResponsiveSize(15)),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(
                                globalDataStore.getResponsiveSize(15))),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 0,
                                  blurRadius: 15,
                                  offset: Offset(0, 3),
                                  color: Color.fromRGBO(0, 0, 0, 0.12))
                            ]),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  // left: globalDataStore.getResponsiveSize(15),
                                  bottom:
                                      globalDataStore.getResponsiveSize(10)),
                              height: globalDataStore.getResponsiveSize(14),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Recents',
                                  style: TextStyle(
                                      fontFamily: 'SFProText',
                                      fontStyle: FontStyle.normal,
                                      fontSize:
                                          globalDataStore.getResponsiveSize(12),
                                      letterSpacing: -0.15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Expanded(
                                child: ListView(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                  widget.getLocalBundledImage().length,
                                  (index) {
                                return assetBlock(
                                    globalDataStore.getResponsiveSize(
                                        AssetsBarHeight - 40),
                                    index,
                                    widget.getLocalBundledImage()[index],
                                    onSelectedMedia == index, () {
                                  setState(() {
                                    onSelectedMedia = index;
                                  });
                                });
                              }),
                            ))
                          ],
                        )),
                  )
                ],
              ),
            )),
      );
}

Widget assetBlock(double width, int idx, String resourcePath, bool onSelected,
    VoidCallback onPress) {
  return Container(
    width: width,
    margin: EdgeInsets.only(left: idx == 0 ? 0 : 15),
    // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
        image:
            DecorationImage(image: AssetImage(resourcePath), fit: BoxFit.cover),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border:
            Border.all(width: onSelected ? 3 : 0, color: HexColor('#FFB2B2')),
        color: HexColor('#FFB2B2')),
    child: MaterialButton(
      onPressed: onPress,
    ),
  );
}

class PostData {
  PostData(
      {this.id = '',
      this.postOwnerID = '',
      this.postOwnerThumbnails = '',
      this.postDatetime = '',
      this.postContents = '',
      this.postMediaLink = '',
      this.likes = 0,
      this.comments = 0});
  final String id;
  final String postOwnerID;
  final String postOwnerThumbnails;
  final String postDatetime;
  final String postContents;
  final String postMediaLink;
  final int likes;
  final int comments;

  PostData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        postOwnerID = json['postOwnerID'],
        postOwnerThumbnails = json['postOwnerThumbnails'],
        postDatetime = json['postDatetime'],
        postContents = json['postContents'],
        postMediaLink = json['postMediaLink'],
        likes = json['likes'],
        comments = json['comments'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'postOwnerID': postOwnerID,
        'postOwnerThumbnails': postOwnerThumbnails,
        'postDatetime': postDatetime,
        'postContents': postContents,
        'postMediaLink': postMediaLink,
        'likes': likes,
        'comments': comments
      };
}
