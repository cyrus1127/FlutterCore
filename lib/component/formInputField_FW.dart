import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/formInputField.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

InputDecoration _buildInputDecoration(String hint, String iconPath) {
  return InputDecoration(
    border: UnderlineInputBorder(borderSide: BorderSide.none),
    hintText: hint,
    hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
    icon: iconPath != '' ? Image.asset(iconPath) : null,
  );
}

@protected
Widget buildCommon(Widget child,
    {double cellHeight = 48,
    Color mainColor = Colors.white,
    double topMargin = 10,
    double padding = 15}) {
  return Container(
    width: double.maxFinite,
    height: cellHeight,
    margin: EdgeInsets.only(top: topMargin),
    child: child,
    padding: EdgeInsets.symmetric(
        horizontal: globalDataStore.getResponsiveSize(padding)),
    decoration: BoxDecoration(
      color: mainColor,
      // border: Border.all(width: 0, color: Colors.white),
      // borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );
}

class ProfileFormInputField extends StatelessWidget {
  TextStyle ts_1 = TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'SFProText',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: globalDataStore.getResponsiveSize(12));
  TextStyle ts_2 = TextStyle(
      color: Color.fromRGBO(14, 54, 88, 1),
      fontFamily: 'SFProText',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: globalDataStore.getResponsiveSize(16));
  double commonCellHeight = 48;

  Widget fieldEmail(Function(String?) changedVal) {
    return buildCommon(TextFormField(
      onChanged: changedVal,
      validator: (value) => !isEmail(value!)
          ? "Sorry, we do not recognize this email address"
          : null,
      style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 1),
          fontFamily: 'RadikalLight',
          fontSize: globalDataStore.getResponsiveSize(14)),
      decoration: _buildInputDecoration("Email / Mobile", ''),
    ));
  }

  Widget fieldTwoFactorCode() {
    return buildCommon(TextFormField(
      validator: (value) => !isEmail(value!)
          ? "Sorry, we do not recognize this email address"
          : null,
      style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 1),
          fontFamily: 'RadikalLight',
          fontSize: globalDataStore.getResponsiveSize(14)),
      decoration: _buildInputDecoration("6-digit code", ''),
    ));
  }

  // Widget buildPassword() {
  //   return TextFormField(
  //     obscureText: true,
  //     // controller: _passwordController,
  //     validator: (value) => value!.length <= 6
  //         ? "Password must be 6 or more characters in length"
  //         : null,
  //     style: TextStyle(
  //         color: Color.fromRGBO(0, 0, 0, 1), fontFamily: 'RadikalLight'),
  //     decoration: _buildInputDecoration("Password", ''),
  //     // _buildInputDecoration("Password", 'assets/ic_password.png'),
  //   );
  // }

  Widget buildRowAccPicture(String header, String imagePath,
      {bool showHeaderOnEdit = true,
      VoidCallback? imageOnPress,
      bool onDisplay = false}) {
    double cellSize = globalDataStore.getResponsiveSize(146);
    if (onDisplay || !showHeaderOnEdit)
      cellSize = globalDataStore.getResponsiveSize(115);

    PhysicalModel pmImage = PhysicalModel(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Image(
          height: globalDataStore.getResponsiveSize(95),
          width: globalDataStore.getResponsiveSize(95),
          fit: BoxFit.cover,
          image: loadImageAsset(imagePath)),
      // shape: BoxShape.circle,
      borderRadius:
          BorderRadius.circular(globalDataStore.getResponsiveSize(40)),
    );

    if (onDisplay) {
      return buildCommon(
          Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: globalDataStore.getResponsiveSize(10)),
                height: globalDataStore.getResponsiveSize(95),
                child: pmImage,
              ),
            ],
          ),
          cellHeight: cellSize);
    } else if (!onDisplay && !showHeaderOnEdit) {
      return buildCommon(
          Stack(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: globalDataStore.getResponsiveSize(10)),
                  height: globalDataStore.getResponsiveSize(95),
                  child: pmImage,
                ),
              ),
              Center(
                child: Container(
                  height: globalDataStore.getResponsiveSize(95),
                  width: globalDataStore.getResponsiveSize(95),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                      borderRadius: BorderRadius.circular(
                          globalDataStore.getResponsiveSize(40))),
                  child: TextButton(
                    onPressed: imageOnPress,
                    child: Image(
                        height: globalDataStore.getResponsiveSize(24),
                        image: AssetImage(
                            'assets/images/icon_upload_image_w.png')),
                    style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                  ),
                ),
              )
            ],
          ),
          cellHeight: cellSize);
    }

//Default
    return buildCommon(
        Column(
          children: [
            Container(
              margin:
                  EdgeInsets.only(top: globalDataStore.getResponsiveSize(10)),
              height: globalDataStore.getResponsiveSize(95),
              child: TextButton(
                onPressed: imageOnPress,
                child: pmImage,
                style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                header,
                style: TextStyle(
                    color: Color.fromRGBO(247, 163, 135, 1),
                    fontFamily: 'SFProText',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: globalDataStore.getResponsiveSize(12)),
              ),
            ))
          ],
        ),
        cellHeight: cellSize);
  }

  Widget buildRowFullButton(
      String header, String hint, VoidCallback onPressed, BuildContext context,
      {bool onDisplay = false, Widget? optionExtraLineUnderTitle}) {
    Stack stackCon = Stack(
      children: [
        Positioned(
            top: 0,
            child: Container(
                height: commonCellHeight,
                width: MediaQuery.of(context).size.width * 0.4,
                alignment: Alignment.centerLeft,
                child: optionExtraLineUnderTitle != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              header,
                              style: ts_1,
                            ),
                          ),
                          optionExtraLineUnderTitle
                        ],
                      )
                    : Text(
                        header,
                        style: ts_1,
                      ))),
        Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              height: commonCellHeight,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  hint,
                  style: ts_2,
                ),
              ),
            ))
      ],
    );

    return buildCommon(
      Container(
        width: double.maxFinite,
        child: onDisplay
            ? stackCon
            : TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                onPressed: onPressed,
                child: stackCon),
      ),
    );
  }

  Widget buildRowTextField(
    String header,
    String hint,
    Function(String) onSubmitted,
    BuildContext context, {
    bool onDisplay = false,
    Widget? optionExtraLineUnderTitle,
    String iconPathRight = '',
    String iconPathR = '',
  }) {
    return buildCommon(
      Stack(
        children: [
          Positioned(
              top: 0,
              child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.4,
                  alignment: Alignment.centerLeft,
                  child: optionExtraLineUnderTitle != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                header,
                                style: ts_1,
                              ),
                            ),
                            optionExtraLineUnderTitle
                          ],
                        )
                      : Text(
                          header,
                          style: ts_1,
                        ))),
          if (onDisplay) ...[
            Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.5,
                  alignment: Alignment.centerRight,
                  child: Text(
                    hint,
                    style: ts_2,
                  ),
                ))
          ] else ...[
            Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    // validator: (value) =>
                    //     value!.isEmpty ? "First name cannot be empty" : null,
                    onChanged: onSubmitted,
                    onSubmitted: onSubmitted,
                    textAlign: TextAlign.right,
                    style: ts_2,
                    decoration: _buildInputDecoration(hint, ''),
                  ),
                ))
          ]
        ],
      ),
    );
  }

  Widget buildRowSwitch(
      String header,
      String option1,
      String option2,
      bool currentState,
      Function(String) onSelectedOption,
      BuildContext context,
      {bool onDisplay = false,
      Widget? optionExtraLineUnderTitle}) {
    //the custom button
    Widget innerBtn(VoidCallback onChose,
        {bool isChoosing = false, bool isGirl = false}) {
      String text = isGirl ? 'Girl' : 'Boy';
      String subfix = isChoosing ? '_on.png' : '_off.png';
      Color color_gen = isGirl ? HexColor('#F0727E') : HexColor('#30BDBB');
      Color color_onChose = isChoosing ? HexColor('#C4C3C3') : Colors.white;
      Color color_base = Color.fromRGBO(196, 195, 195, 1);

      return TextButton(
          onPressed: onChose,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: globalDataStore.getResponsiveSize(5)),
            width: globalDataStore.getResponsiveSize(68),
            height: globalDataStore.getResponsiveSize(28),
            padding: EdgeInsets.symmetric(
                horizontal: globalDataStore.getResponsiveSize(12),
                vertical: globalDataStore.getResponsiveSize(4)),
            decoration: BoxDecoration(
                color: isChoosing ? color_gen : Colors.white,
                border: Border.all(
                    color: isChoosing ? Colors.transparent : color_base),
                borderRadius: BorderRadius.circular(
                    globalDataStore.getResponsiveSize(6.93))),
            child: Row(
              children: [
                Image(
                  fit: BoxFit.fitHeight,
                  width: globalDataStore.getResponsiveSize(20),
                  height: globalDataStore.getResponsiveSize(20),
                  image: AssetImage(
                      'assets/images/icon_' + text.toLowerCase() + subfix),
                ),
                Text(text,
                    style: TextStyle(
                        color: isChoosing ? Colors.white : color_base,
                        fontFamily: 'SFProText',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        fontSize: globalDataStore.getResponsiveSize(12))),
              ],
            ),
          ));
    }

    return buildCommon(Stack(
      children: [
        Positioned(
            top: 0,
            child: Container(
                height: commonCellHeight,
                width: MediaQuery.of(context).size.width * 0.4,
                alignment: Alignment.centerLeft,
                child: optionExtraLineUnderTitle != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              header,
                              style: ts_1,
                            ),
                          ),
                          optionExtraLineUnderTitle
                        ],
                      )
                    : Text(
                        header,
                        style: ts_1,
                      ))),
        if (onDisplay && optionExtraLineUnderTitle == null) ...[
          Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width * 0.4,
              child: Container(
                height: commonCellHeight,
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.centerRight,
                child: Text(
                  currentState ? 'Girl' : 'Boy',
                  style: ts_2,
                ),
              ))
        ] else ...[
          Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width * 0.4,
              right: 0,
              child: Container(
                  height: commonCellHeight,
                  // width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.only(
                      right: globalDataStore.getResponsiveSize(11)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      innerBtn(() {
                        onSelectedOption(option1);
                      }, isChoosing: currentState, isGirl: true),
                      innerBtn(() {
                        onSelectedOption(option2);
                      }, isChoosing: !currentState, isGirl: false)
                    ],
                  )))
        ]
      ],
    ));
  }

  Widget buildRowActionSheet(String header, String hint,
      List<BottomSheetAction> choices, BuildContext context,
      {bool onDisplay = false, Widget? optionExtraLineUnderTitle}) {
    return buildCommon(
      Stack(
        children: [
          Positioned(
              top: 0,
              child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.4,
                  alignment: Alignment.centerLeft,
                  child: optionExtraLineUnderTitle != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                header,
                                style: ts_1,
                              ),
                            ),
                            optionExtraLineUnderTitle
                          ],
                        )
                      : Text(
                          header,
                          style: ts_1,
                        ))),
          if (onDisplay) ...[
            Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.5,
                  alignment: Alignment.centerRight,
                  child: Text(
                    hint,
                    textAlign: TextAlign.right,
                    style: ts_2,
                  ),
                ))
          ] else ...[
            Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextButton(
                      onPressed: () {
                        showAdaptiveActionSheet(
                            context: context,
                            actions: choices,
                            title: Text(header),
                            cancelAction: CancelAction(
                              title: Text("Cancel"),
                              onPressed: (context) {
                                Navigator.pop(context);
                              },
                            ));
                      },
                      child: Container(
                          width: double.maxFinite,
                          child: Text(
                            hint,
                            textAlign: TextAlign.right,
                            style: ts_2,
                          )),
                      style: TextButton.styleFrom(padding: EdgeInsets.all(0))),
                ))
          ]
        ],
      ),
    );
  }

  Widget buildRowDateTimePicker(String header, String hint,
      BuildContext context, Function(String) onConfirmed,
      {bool onDisplay = false,
      Widget? optionExtraLineUnderTitle,
      bool showBornButton = false,
      VoidCallback? bornButtonOnPress}) {
    String birth = hint;
    if (hint.length > 0) {
      DateTime? bDay = DateTime.tryParse(hint);
      if (bDay != null) {
        birth = DateFormat.yMMMd().format(bDay).replaceAll(',', '');
      }
    }

    return buildCommon(
        Stack(
          children: [
            Positioned(
                top: 0,
                child: Container(
                    height: commonCellHeight,
                    width: MediaQuery.of(context).size.width * 0.4,
                    alignment: Alignment.centerLeft,
                    child: optionExtraLineUnderTitle != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  header,
                                  style: ts_1,
                                ),
                              ),
                              optionExtraLineUnderTitle
                            ],
                          )
                        : Text(
                            header,
                            style: ts_1,
                          ))),
            if (onDisplay) ...[
              Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: Container(
                    height: commonCellHeight,
                    width: MediaQuery.of(context).size.width * 0.5,
                    alignment: Alignment.centerRight,
                    child: Text(
                      birth,
                      textAlign: TextAlign.right,
                      style: ts_2,
                      // decoration: _buildInputDecoration(hint, ''),
                    ),
                  ))
            ] else ...[
              Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: Container(
                    height: commonCellHeight,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                        // validator: (value) =>
                        //     value!.isEmpty ? "First name cannot be empty" : null,
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2000, 1, 1),
                              maxTime: DateTime(2030, 12, 31),
                              onChanged: (date) {
                            // print('change $date');
                          }, onConfirm: (date) {
                            String y = _fourDigits(date.year);
                            String m = _twoDigits(date.month);
                            String d = _twoDigits(date.day);
                            onConfirmed('$y-$m-$d');
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.zh);
                        },
                        child: Container(
                          width: double.maxFinite,
                          child: Text(
                            birth,
                            textAlign: TextAlign.right,
                            style: ts_2,
                            // decoration: _buildInputDecoration(hint, ''),
                          ),
                        ),
                        style:
                            TextButton.styleFrom(padding: EdgeInsets.all(0))),
                  ))
            ],
            if (showBornButton) ...[
              Positioned(
                  bottom: 17,
                  left: 0,
                  right: 0,
                  child: Container(
                      height: commonCellHeight,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(14, 54, 88, 1),
                          borderRadius: BorderRadius.circular(15)),
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: bornButtonOnPress,
                        child: Text(
                          'Baby Was Born',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: "SF Pro",
                              fontSize: globalDataStore.getResponsiveSize(18)),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                      ))),
            ]
          ],
        ),
        cellHeight: showBornButton ? 119 : 48);
  }

  Widget buildRowPicker(String header, String hint, BuildContext context,
      Function(String) onConfirmed) {
    return buildCommon(
      Stack(
        children: [
          Positioned(
              top: 0,
              child: Container(
                  height: commonCellHeight,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        header,
                        style: ts_1,
                      )))),
          Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width * 0.4,
              child: Container(
                height: commonCellHeight,
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextButton(
                  // validator: (value) =>
                  //     value!.isEmpty ? "First name cannot be empty" : null,
                  onPressed: () {
                    // DatePicker.showPicker(context,
                    //     showTitleActions: true,
                    //     minTime: DateTime(2018, 3, 5),
                    //     maxTime: DateTime(2019, 6, 7), onChanged: (date) {
                    //   print('change $date');
                    // }, onConfirm: (date) {
                    //   print('confirm $date');
                    // }, currentTime: DateTime.now(), locale: LocaleType.zh);
                  },
                  child: Text(
                    hint,
                    textAlign: TextAlign.right,
                    style: ts_2,
                    // decoration: _buildInputDecoration(hint, ''),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget buildInputWithButtonBlock(String header, Function(String) inputValue,
      VoidCallback onConfirmed, BuildContext context,
      {String inputFieldHint = '',
      String buttonTitle = 'OK',
      Color buttonColor = Colors.blueGrey,
      bool needFieldCheck = false,
      double cellHeight = 167,
      double topMargin = 10,
      double topMargin_header = 10}) {
    FormInputField _formBuilder = FormInputField();
    return buildCommon(
        Container(
            child: Column(
          children: [
            if (header.length > 0) ...[
              Container(
                height: 20,
                margin: EdgeInsets.only(
                    top: globalDataStore.getResponsiveSize(topMargin_header)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      header,
                      style: ts_1,
                    )),
              ),
            ],
            _formBuilder.fieldTextInput((changedVal) {
              inputValue(changedVal!);
            },
                bordness: true,
                hints: inputFieldHint,
                needFieldCheck: needFieldCheck),
            if (buttonTitle.length > 0) ...[
              _formBuilder.callbackButton(buttonTitle, buttonColor, onConfirmed)
            ]
          ],
        )),
        cellHeight: cellHeight,
        topMargin: topMargin);
  }

  bool isEmail(String value) {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(regex);

    return value.isNotEmpty && regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

//text styles
// class GradientText extends StatelessWidget {
//   const GradientText(
//     this.text, {
//     required this.gradient,
//     this.style,
//   });

//   final String text;
//   final TextStyle? style;
//   final Gradient gradient;

//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => gradient.createShader(
//         Rect.fromLTWH(0, 0, bounds.width, bounds.height),
//       ),
//       child: Text(text, style: style),
//     );
//   }
// }

String _fourDigits(int n) {
  int absN = n.abs();
  String sign = n < 0 ? "-" : "";
  if (absN >= 1000) return "$n";
  if (absN >= 100) return "${sign}0$absN";
  if (absN >= 10) return "${sign}00$absN";
  return "${sign}000$absN";
}

// String _sixDigits(int n) {
//   assert(n < -9999 || n > 9999);
//   int absN = n.abs();
//   String sign = n < 0 ? "-" : "+";
//   if (absN >= 100000) return "$sign$absN";
//   return "${sign}0$absN";
// }

// String _threeDigits(int n) {
//   if (n >= 100) return "${n}";
//   if (n >= 10) return "0${n}";
//   return "00${n}";
// }

String _twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}

Widget titleExtraLine(BuildContext context,
    {String title = '',
    String contentCur = '',
    List<String>? choices,
    Function(String)? onChanged}) {
  List<BottomSheetAction> _choices = [];
  for (var item in choices!) {
    _choices.add(BottomSheetAction(
        title: Text(item),
        onPressed: (context) {
          Navigator.pop(context);
          if (onChanged != null) onChanged(item);
        }));
  }

  return Container(
    height: globalDataStore.getResponsiveSize(15),
    child: Row(
      children: [
        Text(title,
            style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontFamily: 'SF Pro',
                fontSize: globalDataStore.getResponsiveSize(11))),
        if (choices != null && choices.length > 1) ...[
          Container(
            // width: globalDataStore.getResponsiveSize(20),
            margin: EdgeInsets.only(
                left: globalDataStore.getResponsiveSize(0),
                right: globalDataStore.getResponsiveSize(5)),
            child: TextButton(
                onPressed: () {
                  print('show the action sheet with choices');
                  showAdaptiveActionSheet(
                      context: context,
                      actions: _choices,
                      title: Text('Change the right'),
                      cancelAction: CancelAction(
                        title: Text("Cancel"),
                        onPressed: (context) {
                          Navigator.pop(context);
                        },
                      ));
                },
                child: Row(
                  children: [
                    Text(contentCur,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF Pro',
                          fontSize: globalDataStore.getResponsiveSize(11),
                        )),
                    Image(
                        height: globalDataStore.getResponsiveSize(10),
                        image: AssetImage('assets/images/u_angle-down.png'))
                  ],
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero)),
          ),
        ] else ...[
          Container(
            margin: EdgeInsets.only(left: globalDataStore.getResponsiveSize(3)),
            child: Text(contentCur,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: globalDataStore.getResponsiveSize(11),
                )),
          )
        ]
      ],
    ),
  );
}
