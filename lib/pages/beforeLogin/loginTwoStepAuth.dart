import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/formInputField.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class LoginTwoStepAuth extends CommonStatefulWidget {
  const LoginTwoStepAuth({required Key? key}) : super(key: key);

  @override
  _LoginTwoStepAuthState createState() => _LoginTwoStepAuthState();
}

class _LoginTwoStepAuthState extends State<LoginTwoStepAuth> {
  final FormInputField _forUnitBuilder = FormInputField();
  final _formKey = GlobalKey<FormState>();
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.top > 0 ? 49 : 39) : 39);
  double topBarHeight = 45;
  bool showInAppReminder = false;
  List<ProfileData> datas = [];

  void handleInput() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (await preferences.setBool(globalDataStore.accountName, true)) {
        showInAppReminder = false;

        Navigator.pushNamedAndRemoveUntil(
            context, '/profiles', ModalRoute.withName('/welcome'));
        return;
      }
    }

    //diffault set show
    setState(() {
      //TODO : show error
      showInAppReminder = true;
    });
  }

  void getData() async {
    await widget.getProfileDatas().then((value) {
      value!.forEach((element) {
        datas.add(element);
      });

      setState(() {});
    });
  }

  void initDemoDatas() async {
//Do for demo app
    ///TODO : remove it if server exist
    List<PostData>? postRecords = await widget.getPostDatas();
    if (postRecords!.length == 0) {
      for (int index = 0; index < 5; index++) {
        widget.setPostDatas(new PostData(
            id: new Uuid().toString(),
            postOwnerID: new Uuid().toString(),
            postOwnerThumbnails: '',
            postContents:
                'Text text text text text text text text text text text tex text text text text text text text text text text #hashtag  #hashtag  #hashtag  #hashtag  #hashtag',
            postMediaLink: widget.getLocalBundledImage()[index],
            postDatetime: DateTime.now().toString(),
            likes: 0,
            comments: 0));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (!globalDataStore.isNewDemoAccount) {
      getData();
    }
    initDemoDatas();
  }

  @override
  Widget build(BuildContext context) => KeyboardDismisser(
        child: WillPopScope(
            child: Scaffold(
                // backgroundColor: Color.fromRGBO(0, 0, 0, 0.0), //HexColor("#F4F4F5"),
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.width /
                              375 *
                              200, //recalue with the actual image size
                        )),

                    //// Top bar ( back button + Logo )
                    Positioned(
                      top: topBarOffSet,
                      left: 0,
                      right: 0,
                      child: Container(
                          height:
                              globalDataStore.getResponsiveSize(topBarHeight) +
                                  topBarOffSet,
                          decoration:
                              BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0)),
                          // padding: EdgeInsets.symmetric(
                          //     vertical: globalDataStore.getResponsiveSize(50)),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      width:
                                          globalDataStore.getResponsiveSize(30),
                                      margin: EdgeInsets.only(
                                          left: globalDataStore
                                              .getResponsiveSize(15),
                                          right: globalDataStore
                                              .getResponsiveSize(5)),
                                      child: TextButton(
                                        onPressed: () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Image(
                                            image: AssetImage(
                                                'assets/images/fi_chevron-left.png')),
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.all(2)),
                                      )),
                                  Expanded(
                                      child: Text(
                                    '',
                                    style: TextStyle(
                                        fontFamily: 'SFProText-Semibold',
                                        fontSize: globalDataStore
                                            .getResponsiveSize(18),
                                        fontWeight: FontWeight.w600),
                                  )),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Image(
                                    height:
                                        globalDataStore.getResponsiveSize(40),
                                    image: AssetImage(
                                        "assets/images/blook_TopBarLogo.png")),
                              )
                            ],
                          )),
                    ),

                    /// Content session ( Text + TextInputField + Profile Icon )
                    Positioned(
                        top: globalDataStore.getResponsivePositioning(180),
                        left: 0,
                        right: 0,
                        child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    globalDataStore.getResponsiveSize(20)),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Profile Icon
                                      if (!globalDataStore
                                          .isNewDemoAccount) ...[
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: globalDataStore
                                                    .getResponsivePositioning(
                                                        10)),
                                            height: globalDataStore
                                                .getResponsiveSize(116),
                                            width: double.maxFinite,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                getProfilePic(datas.first),
                                                if (datas.length > 1) ...[
                                                  getProfilePic(datas[1])
                                                ]
                                              ],
                                            ))
                                      ],

                                      ///Text & TextFields
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: widget
                                                .getResponsivePositioning(20)),
                                        child: Text(
                                          (globalDataStore.isNewDemoAccount
                                              ? "Welcome to Blook's family. We sent a code"
                                              : "One more step to go... We sent a code"),
                                          style: TextStyle(
                                              fontFamily: "SFProText-Medium",
                                              fontSize: globalDataStore
                                                  .getResponsiveSize(18),
                                              fontWeight: FontWeight.w500,
                                              color: HexColor("#0E3658"),
                                              letterSpacing: -0.24),
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: widget
                                                  .getResponsivePositioning(5)),
                                          child: Row(
                                            children: [
                                              Text(
                                                "to your email ",
                                                style: TextStyle(
                                                    fontFamily:
                                                        "SFProText-Medium",
                                                    fontSize: globalDataStore
                                                        .getResponsiveSize(18),
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    color: HexColor("#0E3658"),
                                                    letterSpacing: -0.24),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  globalDataStore.accountName,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          "SFProText-bold",
                                                      fontSize: globalDataStore
                                                          .getResponsiveSize(
                                                              18),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color:
                                                          HexColor("#0E3658"),
                                                      letterSpacing: -0.24),
                                                ),
                                              )
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: widget
                                                .getResponsivePositioning(28)),
                                        child: Text(
                                          "Enter the 6-digit verification code sent to your email.",
                                          style: TextStyle(
                                              fontFamily: "SFProText-Medium",
                                              fontStyle: FontStyle.normal,
                                              fontSize: globalDataStore
                                                  .getResponsiveSize(15.5),
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              letterSpacing: -0.24),
                                        ),
                                      ),
                                      _forUnitBuilder.fieldTwoFactorCode(
                                          onSubmit: (value) => {handleInput()}),
                                      if (showInAppReminder) ...[
                                        _forUnitBuilder.callbackButton(
                                            'Incorrect verification code. Please try again or you can re-enter your email.',
                                            HexColor('#F05757'), () {
                                          setState(() {
                                            showInAppReminder = false;
                                          });
                                        },
                                            height: globalDataStore
                                                .getResponsiveSize(54),
                                            align: TextAlign.center,
                                            fontSize: globalDataStore
                                                .getResponsiveSize(14),
                                            fontWeight: FontWeight.w500),
                                      ],
                                      _forUnitBuilder.callbackButton(
                                          (globalDataStore.isNewDemoAccount
                                              ? "Sign Up"
                                              : "Sign In"),
                                          HexColor("#0F3657"), () {
                                        handleInput();
                                      }),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: widget
                                                  .getResponsivePositioning(
                                                      28)),
                                          child: RichText(
                                              text: TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      height: 1.5),
                                                  children: [
                                                TextSpan(
                                                    style: TextStyle(
                                                        color:
                                                            HexColor("#0F3657"),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.19,
                                                        decoration:
                                                            TextDecoration
                                                                .underline),
                                                    text: "Resend code",
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            //to call API
                                                            //TODO : show alert
                                                          }),
                                                TextSpan(
                                                    text:
                                                        " or if you don’t see the email in your inbox. Please check you spam folder."),
                                              ]))),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: widget
                                                  .getResponsivePositioning(
                                                      28)),
                                          child: RichText(
                                              text: TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      height: 1.5,
                                                      fontFamily:
                                                          "SFProText-Semibold"),
                                                  children: [
                                                TextSpan(
                                                    text:
                                                        "Incorrect email address entered? "),
                                                TextSpan(
                                                    style: TextStyle(
                                                        color:
                                                            HexColor("#0F3657"),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.19,
                                                        decoration:
                                                            TextDecoration
                                                                .underline),
                                                    text: "Re-enter",
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            String url =
                                                                "https://www.google.com";
                                                            if (await canLaunch(
                                                                url)) {
                                                              await launch(url);
                                                            } else {
                                                              throw 'Could not launch $url';
                                                            }
                                                          }),
                                              ]))),
                                    ])))),
                    // Positioned(
                    //     top: widget.getResponsivePositioning(10),
                    //     left: widget.getResponsivePositioning(10),
                    //     child: Container(
                    //         width: globalDataStore.getResponsiveSize(38),
                    //         height: globalDataStore.getResponsiveSize(38),
                    //         child: TextButton(
                    //           onPressed: () {
                    //             if (Navigator.canPop(context)) {
                    //               Navigator.popUntil(
                    //                   context, ModalRoute.withName('/welcome'));
                    //             }
                    //           },
                    //           child: Text(
                    //               'assets/svg/btn_add_new_close.svg'),
                    //           style: TextButton.styleFrom(
                    //               padding: EdgeInsets.zero),
                    //         ))),
                  ],
                )),
            onWillPop: () async {
              return false;
            }),
      );
}

Widget getProfilePic(ProfileData data) {
  return Container(
    margin: EdgeInsets.symmetric(
        horizontal: globalDataStore.getResponsivePositioning(10)),
    width: globalDataStore.getResponsiveSize(116),
    decoration: BoxDecoration(
      image: DecorationImage(
          image: loadImageAsset(data.profilePic), fit: BoxFit.cover),
      borderRadius: BorderRadius.all(
          Radius.circular(globalDataStore.getResponsiveSize(116) * 0.45)),
    ),
  );
}
