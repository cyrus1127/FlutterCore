import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProfileMessagerChat extends CommonStatefulWidget {
  final ProfileData userData;
  const ProfileMessagerChat(this.userData, {required Key? key})
      : super(key: key);

  @override
  _ProfileMessagerChatState createState() => _ProfileMessagerChatState();
}

class _ProfileMessagerChatState extends State<ProfileMessagerChat> {
  final TextEditingController _controller = TextEditingController();

  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double tapBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 34 : 10) : 10);
  double tapBarHeight = 58;
  double inputFieldHeight = 0;
  double inputFieldpadding = 0;
  double profileShortDetailFieldHeight = 0;
  bool needShowtextInputField = false;

  TextStyle ts_1 = TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'SFProText',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      fontSize: globalDataStore.getResponsiveSize(16));

  ProfileData myData = ProfileData();
  List<ChatData> chatRecords = [];
  String inputMsgs = '';
  final ScrollController listViewController = ScrollController();

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

  void SubmitInputtedMessage() {
    if (inputMsgs.length > 0) {
      chatRecords.add(new ChatData(
          id: new Uuid().toString(),
          senderID: myData.id,
          contentText: inputMsgs,
          contentMedia: '',
          dataTime: DateTime.now().millisecond.toString()));
      inputMsgs = '';
    }
    setState(() {
      needShowtextInputField = false;
      listViewController.jumpTo(listViewController.position.maxScrollExtent);
    });
  }
  /*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/

  void loadPostRecords() async {
    chatRecords.clear();

//TODO : request the search result by server API

//TODO :
    // await widget.getPostDatas().then((value) {
    //   value!.forEach((element) {
    //     postRecords.add(element);
    //   });
    //   setState(() {});
    // });

    //Debug
    int demoAmount = 3;
    for (var i = 0; i < demoAmount; i++) {
      chatRecords.add(new ChatData(
          id: new Uuid().toString(),
          senderID: widget.userData.id,
          contentText: i == 2 ? '' : 'demo msgssss',
          contentMedia:
              i == 2 ? 'assets/images/thumbnails/original/b3.jpeg' : '',
          dataTime: '1646421449335'));
    }
    setState(() {
      print('user chat histories count' + chatRecords.length.toString());
    });
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
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                //Topbar
                Positioned(
                    top: 0,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.5,
                                    color: Color.fromRGBO(0, 0, 0, 0.5)))),
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
                              height: globalDataStore.getResponsiveSize(32),
                              margin: EdgeInsets.only(
                                  right: globalDataStore.getResponsiveSize(10)),
                              child: PhysicalModel(
                                  color: Colors.transparent,
                                  shape: BoxShape.rectangle,
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: getThumbRadius(32),
                                  child: getThumbnailImage(
                                      widget.userData.profilePic)),
                            ),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.userData.name,
                                    style: TextStyle(
                                        fontSize: globalDataStore
                                            .getResponsiveSize(16),
                                        fontFamily: 'SFProText-Bold',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.33),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '{online status}',
                                      style: TextStyle(
                                          fontSize: globalDataStore
                                              .getResponsiveSize(10),
                                          fontFamily: 'SFProText',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.1),
                                    ))
                              ],
                            )),
                          ],
                        ))),

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
                                  inputFieldHeight +
                                  profileShortDetailFieldHeight),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.white),
                      child: (chatRecords.length > 0)
                          ? ListView(
                              padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: globalDataStore.getResponsiveSize(
                                      tapBarHeight + tapBarOffSet)),
                              controller: listViewController,
                              children:
                                  List.generate(chatRecords.length, (index) {
                                return chatContentRow(
                                    chatRecords[index]
                                            .senderID
                                            .compareTo(myData.id) ==
                                        0,
                                    chatRecords[index],
                                    widget.userData);
                              }),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: globalDataStore
                                            .getResponsiveSize(15)),
                                    child: Text(
                                      'Do not have any chat histories with this account',
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
                                  'Input something to chat wth your friend',
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

                ///input block
                if (needShowtextInputField) ...[
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: msgInputBlock(
                          MediaQuery.of(context).size.width,
                          globalDataStore.getResponsiveSize(tapBarHeight),
                          globalDataStore.getResponsiveSize(tapBarOffSet),
                          widget.userData,
                          () {},
                          () {
                            print('back/cancel intput');
                            setState(() {
                              needShowtextInputField = false;
                            });
                          },
                          () {
                            SubmitInputtedMessage();
                          },
                          supportDirectInput: true,
                          onChanged: (strVal) {
                            print('onChanged value ? ' + strVal);
                            inputMsgs = strVal;
                          },
                          onSubmitted: (strVal) {
                            SubmitInputtedMessage();
                          })),
                ] else ...[
                  Positioned(
                      top: MediaQuery.of(context).size.height -
                          widget.getResponsivePositioning(
                              tapBarHeight + tapBarOffSet),
                      left: 0,
                      child: msgInputBlock(
                          MediaQuery.of(context).size.width,
                          globalDataStore.getResponsiveSize(tapBarHeight),
                          globalDataStore.getResponsiveSize(tapBarOffSet),
                          widget.userData, () {
                        needShowtextInputField = true;
                        setState(() {});
                      }, () {
                        print('call camera');
                      }, () {
                        print('call system gallery');
                      })),
                ]
              ],
            )),
        onWillPop: () async {
          return true;
        });
  }
}

//chat content widget
Widget chatContentRow(bool sentOutMsg, ChatData data, ProfileData userData) {
  DateTime dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(data.dataTime));
  String formated =
      DateFormat.MMMd().format(dt) + ' ' + DateFormat.Hm().format(dt);
  return Container(
    margin: EdgeInsets.only(top: globalDataStore.getResponsiveSize(10)),
    decoration: BoxDecoration(),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (sentOutMsg) ...[
        Spacer(),
        Container(
          width: globalDataStore.getResponsiveSize(36),
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(
              horizontal: globalDataStore.getResponsiveSize(10)),
          child: Text(
            formated,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: globalDataStore.getResponsiveSize(11)),
          ),
        )
      ] else ...[
        Container(
            margin: EdgeInsets.symmetric(
                horizontal: globalDataStore.getResponsiveSize(10)),
            height: globalDataStore.getResponsiveSize(32),
            child: Image(image: loadImageAsset(userData.profilePic))),
      ],
//content
      Expanded(
          child: Container(
              padding: EdgeInsets.all(globalDataStore.getResponsiveSize(10)),
              margin: EdgeInsets.only(
                  right:
                      globalDataStore.getResponsiveSize(sentOutMsg ? 10 : 0)),
              width: globalDataStore.getResponsiveSize(71),
              decoration: BoxDecoration(
                  borderRadius: sentOutMsg
                      ? BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          topLeft: Radius.circular(15))
                      : BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                  color: HexColor(sentOutMsg ? '#0E3658' : '#FCEDE7')),
              child: Column(children: [
                if (data.contentText.length > 0) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.contentText,
                      style: TextStyle(
                          color: sentOutMsg ? Colors.white : Colors.black,
                          fontFamily: 'SFProText',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          fontSize: globalDataStore.getResponsiveSize(14)),
                    ),
                  )
                ],
                if (data.contentMedia.length > 0) ...[
                  Image(image: AssetImage(data.contentMedia))
                ],
              ]))),

      if (sentOutMsg)
        ...[]
      else ...[
        Container(
          width: globalDataStore.getResponsiveSize(45),
          padding: EdgeInsets.only(top: globalDataStore.getResponsiveSize(10)),
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(
              horizontal: globalDataStore.getResponsiveSize(10)),
          child: Text(
            formated,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: globalDataStore.getResponsiveSize(11)),
          ),
        )
      ],
    ]),
  );
}

Widget msgInputBlock(
    double width,
    double height,
    double padding,
    ProfileData userData,
    VoidCallback btnTextonPressed,
    VoidCallback btn1onPressed,
    VoidCallback btn2onPressed,
    {bool needMediaButton = true,
    bool supportDirectInput = false,
    Function(String)? onChanged,
    Function(String)? onSubmitted}) {
  return //Create new post
      Container(
    width: width,
    height: height,
    // decoration: BoxDecoration(color: Colors.amber),
    child: Container(
      margin: EdgeInsets.symmetric(
          vertical: padding, horizontal: globalDataStore.getResponsiveSize(15)),
      child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                    Radius.circular((height - padding * 2) * 0.3)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      offset: Offset(0, globalDataStore.getResponsiveSize(5)))
                ]),
            child: Row(
              children: [
                if (supportDirectInput) ...[
                  if (needMediaButton) ...[
                    Container(
                      margin: EdgeInsets.only(
                          left: globalDataStore.getResponsiveSize(10)),
                      width: globalDataStore.getResponsiveSize(24),
                      child: TextButton(
                          onPressed: btn1onPressed,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child:
                              Icon(Icons.arrow_back_ios, color: Colors.black)),
                    ),
                  ],
                  Expanded(
                    child: MaterialButton(
                      onPressed: btnTextonPressed,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: supportDirectInput
                            ? TextField(
                                autofocus: true,
                                decoration: InputDecoration(hintText: 'Aa'),
                                style: TextStyle(),
                                textAlign: TextAlign.left,
                                onChanged: onChanged,
                                onSubmitted: onSubmitted,
                              )
                            : Text(
                                'Aa',
                                style: TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                      ),
                    ),
                  ),
                  if (needMediaButton) ...[
                    Container(
                      margin: EdgeInsets.only(
                          right: globalDataStore.getResponsiveSize(10)),
                      width: globalDataStore.getResponsiveSize(24),
                      child: TextButton(
                        onPressed: btn2onPressed,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Image(
                            image: AssetImage(
                                'assets/images/icon_message_send.png')),
                      ),
                    )
                  ],
                ] else ...[
                  if (needMediaButton) ...[
                    Container(
                      margin: EdgeInsets.only(
                          left: globalDataStore.getResponsiveSize(10)),
                      width: globalDataStore.getResponsiveSize(24),
                      child: TextButton(
                        onPressed: btn1onPressed,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Image(
                            image: AssetImage('assets/images/icon_camera.png')),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: globalDataStore.getResponsiveSize(5)),
                      width: globalDataStore.getResponsiveSize(24),
                      child: TextButton(
                        onPressed: btn2onPressed,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Image(
                            image: AssetImage(
                                'assets/images/icon_upload_image.png')),
                      ),
                    )
                  ],
                  Expanded(
                    child: MaterialButton(
                      onPressed: btnTextonPressed,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: supportDirectInput
                            ? TextField(
                                decoration: InputDecoration(hintText: 'Aa'),
                                style: TextStyle(),
                                textAlign: TextAlign.left,
                                onChanged: onChanged,
                              )
                            : Text(
                                'Aa',
                                style: TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                      ),
                    ),
                  )
                ],
              ],
            ),
          )),
        ],
      ),
    ),
  );
}

//=-=-=-=-=-=-=- Data struct -=-=-=-=-=-=-=
class ChatData {
  const ChatData(
      {this.id = '',
      this.senderID = '',
      this.contentText = '',
      this.contentMedia = '',
      this.status = '',
      this.dataTime = ''})
      : super();

  final String id;
  final String senderID;
  final String contentText;
  final String contentMedia;
  final String status;
  final String dataTime;

  ChatData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        senderID = json['senderID'],
        contentText = json['contentText'],
        contentMedia = json['contentMedia'],
        status = json['status'],
        dataTime = json['dataTime'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderID': senderID,
        'contentText': contentText,
        'contentMedia': contentMedia,
        'status': status,
        'dataTime': dataTime
      };
}
