import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_devbase_v1/component/formInputField.dart';

class CreateAcc extends CommonStatefulWidget {
  const CreateAcc({required Key? key}) : super(key: key);
  @override
  _CreateAccState createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  final FormInputField _forUnitBuilder = FormInputField();
  bool isLoginFormNeed = false;
  bool isRegistrationFormNeed = false;
  String userAcc = "";
  double bottomZoneSize() {
    return 0.35;
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

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: widget.cardView(Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: globalDataStore.getResponsiveSize(15),
                right: globalDataStore.getResponsiveSize(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(
                          top: widget.getResponsivePositioning(50)),
                      height: globalDataStore.getResponsiveSize(60),
                      width: globalDataStore.getResponsiveSize(153),
                      // decoration: BoxDecoration(color: Colors.red),
                      child: Image(
                          image: AssetImage("assets/images/blook_logo.png"))),
                  Container(
                    margin: EdgeInsets.only(
                        top: widget.getResponsivePositioning(16)),
                    child: Text(
                      "Create new account",
                      style: TextStyle(
                          fontFamily: "SFProText-Bold",
                          fontSize: globalDataStore.getResponsiveSize(34),
                          fontWeight: FontWeight.w700,
                          color: HexColor("#F1A387"),
                          letterSpacing: -0.24),
                    ),
                  ),
                  Container(
                      height: getHeightOfView(1 - bottomZoneSize()),
                      // decoration: BoxDecoration(color: Colors.green),
                      child: Column(
                        children: [
                          _forUnitBuilder
                              .fieldEmail((value) => {userAcc = value!}),
                          _forUnitBuilder.callbackButton(
                              "Next", HexColor("#0F3657"), () async {
                            if (await checkLoginUser()) {
                              globalDataStore.isNewDemoAccount = false;
                            } else {
                              globalDataStore.isNewDemoAccount = true;
                              globalDataStore.accountName = userAcc;
                              Navigator.pushNamed(context, '/loginTwoStepAuth');
                            }
                          }),
                          _forUnitBuilder.seperateline(context),
                          _forUnitBuilder.callbackButton(
                              "Facebook Login", HexColor("#3A559F"), () {
                            setState(() {});
                          }),
                        ],
                      )),
                ],
              ),
            ),
            Positioned(
                top: widget.getResponsivePositioning(10),
                left: widget.getResponsivePositioning(10),
                child: Container(
                    width: globalDataStore.getResponsiveSize(38),
                    height: globalDataStore.getResponsiveSize(38),
                    child: TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.popUntil(
                              context, ModalRoute.withName('/welcome'));
                        }
                      },
                      child: Text(""),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ))),
          ],
        )),
        onWillPop: () async {
          return false;
        });
  }
}
