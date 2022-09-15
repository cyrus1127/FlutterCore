import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_devbase_v1/component/formInputField.dart';

class WelcomePage extends CommonStatefulWidget {
  const WelcomePage({required Key? key}) : super(key: key);
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _controller = TextEditingController();
  final FormInputField _forUnitBuilder = FormInputField();
  final _formKey = GlobalKey<FormState>();

  double bottomSessionHeaderTopMargin = 60;

  bool isLoginFormNeed = false;
  bool isRegistrationFormNeed = false;
  bool showInAppReminder = false;
  String userAcc = "";
  double bottomZoneSize() {
    return 0.6;
  }

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  Future<bool> checkLoginUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(userAcc) == true) {
      return Future<bool>.value(true);
    }

    return Future<bool>.value(false);
  }

  void handleLogin() async {
    ///do dismiss the keyboard focus
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (userAcc.length > 0) {
        globalDataStore.accountName = userAcc;
        if (await checkLoginUser()) {
          globalDataStore.isNewDemoAccount = false;
          Navigator.pushNamed(context, '/loginTwoStepAuth');
        } else {
          globalDataStore.isNewDemoAccount = true;
          Navigator.pushNamed(context, '/loginTwoStepAuth');
        }
        setState(() {
          showInAppReminder = false;
        });
        return;
      }
    }

    //different set false
    setState(() {
      showInAppReminder = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final String text = _controller.text.toLowerCase();
      _controller.value = _controller.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    setState(() {});
  }

  Widget build(BuildContext context) => KeyboardDismisser(
      child: Scaffold(
          backgroundColor: HexColor("#E5E5E5"),
          // resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              //App name/Title
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        //Background image with clipping
                        Positioned(
                          top: MediaQuery.of(context).size.height / 2 -
                              (MediaQuery.of(context).size.width /
                                      1125 *
                                      1233) /
                                  1.1, //as the image position have a upper padding
                          left: 0,
                          right: 0,
                          child: Image(
                            isAntiAlias: true,
                            fit: BoxFit.fitWidth,
                            image: AssetImage("assets/images/welcome_bg.png"),
                          ),
                        ),
                        //Header
                        Container(
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      top: widget.getResponsivePositioning(64)),
                                  height: globalDataStore.getResponsiveSize(67),
                                  width: globalDataStore.getResponsiveSize(180),
                                  // decoration: BoxDecoration(color: Colors.red),
                                  child: Image(
                                    image: AssetImage(
                                        "assets/images/blook_logo.png"),
                                  )),
                              Container(
                                margin: EdgeInsets.only(
                                    top: widget.getResponsivePositioning(15)),
                                child: GradientText(
                                    "Connect the world’s babies, mom & dad",
                                    style: TextStyle(
                                        fontFamily: "SFProText-Medium",
                                        fontSize: globalDataStore
                                            .getResponsiveSize(16),
                                        fontWeight: FontWeight.w500,
                                        color: HexColor("#0C3658"),
                                        letterSpacing: -0.24),
                                    gradient: LinearGradient(colors: [
                                      HexColor("#0C3658"),
                                      HexColor("#F1A387"),
                                      HexColor("#0C3658"),
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        // Positioned(
                        //   top: MediaQuery.of(context).size.height * 0.65,
                        //   left: 0,
                        //   right: 0,
                        //   child: Container(
                        //       decoration:
                        //           BoxDecoration(color: HexColor('#F1A387')),
                        //       width: double.maxFinite,
                        //       height: MediaQuery.of(context).size.height * 0.35,
                        //       child: null),
                        // ),

//Vector BG
                        Positioned(
                            top: MediaQuery.of(context).size.height * 0.4,
                            right: 0,
                            left: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width /
                                  375 *
                                  506, //recalue with the actual image size,
                            )),

                        Positioned(
                          // top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child:

                              ///Set the background color
                              Container(
                                  // decoration: BoxDecoration(
                                  //     color: Colors.amber,
                                  //     borderRadius: BorderRadius.only(
                                  //         topLeft: Radius.circular(100),
                                  //         topRight: Radius.circular(100))),
                                  child: Container(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height / 2.2,
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    globalDataStore.getResponsiveSize(20)),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: widget.getResponsivePositioning(
                                          bottomSessionHeaderTopMargin)),
                                  child: Text(
                                    "Sign In / Join us",
                                    style: TextStyle(
                                        fontFamily: "SFProText-Bold",
                                        fontSize: globalDataStore
                                            .getResponsiveSize(30),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.24),
                                  ),
                                ),
                                Container(
                                    height: globalDataStore.getResponsiveSize(
                                        (_forUnitBuilder.basicHeight +
                                                _forUnitBuilder
                                                    .basicTopMarginHeight +
                                                10) *
                                            3),
                                    // decoration: BoxDecoration(color: Colors.green),
                                    child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            _forUnitBuilder.fieldEmailLogin(
                                              (value) => {userAcc = value!},
                                              margin_t: 20,
                                              onSubmit: (value) {
                                                handleLogin();
                                              },
                                            ),
                                            if (showInAppReminder) ...[
                                              _forUnitBuilder.callbackButton(
                                                  'Please enter a valid email address',
                                                  HexColor('#F05757'), () {
                                                setState(() {
                                                  showInAppReminder = false;
                                                });
                                              },
                                                  height: globalDataStore
                                                      .getResponsiveSize(37.5),
                                                  align: TextAlign.center,
                                                  fontSize: globalDataStore
                                                      .getResponsiveSize(14),
                                                  fontWeight: FontWeight.w500)
                                            ],
                                            _forUnitBuilder.callbackImageButton(
                                                "fi_arrow-right.png",
                                                HexColor("#0F3657"),
                                                handleLogin,
                                                margin_t: 20),
                                          ],
                                        ))),
                              ],
                            ),
                          )),
                        ),
                      ],
                    )),
              ),

              ///buttomZoneSize :

              if (showInAppReminder) ...[
                //floating reminder
                // Positioned(
                //     bottom: (Platform.isIOS
                //         ? (window.viewPadding.bottom > 0 ? 30 : 10)
                //         : 10),
                //     child: widget.getInAppReminderBlock(
                //         'Wrong account/password. Please input carefully. If you dont remenber , you can reset it. \n',
                //         context,
                //         needRichText: true,
                //         tapableString: 'Forgot password')),
                // Positioned(
                //     bottom: (Platform.isIOS
                //         ? (window.viewPadding.bottom > 0 ? 130 : 80)
                //         : 80),
                //     right: 10,
                //     child: Container(
                //       width: 25,
                //       height: 25,
                //       child: FloatingActionButton(
                //         backgroundColor: Colors.grey,
                //         child: Icon(Icons.close),
                //         onPressed: () {
                //           setState(() {
                //             showInAppReminder = false;
                //           });
                //         },
                //       ),
                //     ))
              ]
            ],
          )));
}
