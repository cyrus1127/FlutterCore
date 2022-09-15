import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';

InputDecoration _buildInputDecoration(String hint, String iconPath) {
  return InputDecoration(
      border: UnderlineInputBorder(borderSide: BorderSide.none),
      // focusedBorder: UnderlineInputBorder(
      //     borderSide:
      //         BorderSide(color: Color.fromRGBO(0, 255, 0, 1), width: 0.01)),
      hintText: hint,
      hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
      // enabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(color: Color.fromRGBO(151, 151, 151, 1))),
      icon: iconPath != '' ? Image.asset(iconPath) : null,
      //Cyrus : remove/hidden the error message as the customize style haven't
      errorStyle: TextStyle(
          color: Color.fromRGBO(248, 218, 87, 0), fontSize: 0, height: 0),
      // errorBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))),
      // focusedErrorBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1)))
      fillColor: Color.fromRGBO(0, 0, 0, 0),
      filled: true);
}

@protected
Widget buildCommon(Color mainColor, Widget child,
    {bool bordness = true,
    Color borderColor = Colors.black,
    double height = 50,
    double margin_t = 10}) {
  return Container(
    width: double.maxFinite,
    height: globalDataStore.getResponsiveSize(height),
    margin: EdgeInsets.only(top: globalDataStore.getResponsiveSize(margin_t)),
    child: child,
    padding:
        EdgeInsets.symmetric(horizontal: globalDataStore.getResponsiveSize(15)),
    decoration: BoxDecoration(
      color: mainColor,
      border: bordness
          ? Border.all(width: 0, color: Color.fromRGBO(0, 0, 0, 0))
          : Border.all(width: 1, color: borderColor),
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  );
}

class FormInputField extends StatelessWidget {
  double basicTopMarginHeight = 10;
  double basicHeight = 50;

  Widget fieldEmailLogin(Function(String?) changedVal,
      {Function(String?)? onSubmit, double margin_t = 10}) {
    return fieldEmail(changedVal,
        onSubmit: onSubmit, hints: 'Email', margin_t: margin_t);
  }

  Widget fieldEmail(Function(String?) changedVal,
      {Function(String?)? onSubmit,
      String hints = 'Email',
      bool bordness = true,
      double margin_t = 10}) {
    return fieldTextInput(changedVal,
        onSubmit: onSubmit,
        hints: hints,
        needFieldCheck: true,
        topMargin: margin_t);
  }

  Widget fieldTextInput(Function(String?) changedVal,
      {Function(String?)? onSubmit,
      String hints = '',
      bool bordness = true,
      bool needFieldCheck = false,
      double topMargin = 10,
      Color fieldBG = Colors.white}) {
    return buildCommon(
        // fieldBG,
        HexColor('#E8EBED'),
        TextFormField(
          onChanged: changedVal,
          onFieldSubmitted: onSubmit,
          style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1),
              fontFamily: 'RadikalLight',
              fontSize: 14),
          decoration: _buildInputDecoration(hints, ''),
          validator: needFieldCheck
              ? ((value) => !isEmail(value!)
                  ? "Sorry, we do not recognize this email address"
                  : null)
              : null,
        ),
        bordness: bordness,
        margin_t: topMargin);
  }

  Widget fieldTwoFactorCode({Function(String?)? onSubmit}) {
    return buildCommon(
        HexColor('#E8EBED'),
        TextFormField(
          onFieldSubmitted: onSubmit,
          validator: ((value) => !isFieldHaveValues(value!)
              ? "Sorry, we do not recognize with empty input"
              : null),
          style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1),
              fontFamily: 'RadikalLight',
              fontSize: 14),
          decoration: _buildInputDecoration("6-digit code", ''),
        ));
  }

  Widget buildPassword() {
    return TextFormField(
      obscureText: true,
      // controller: _passwordController,
      validator: (value) => value!.length <= 6
          ? "Password must be 6 or more characters in length"
          : null,
      style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 1), fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("Password", ''),
      // _buildInputDecoration("Password", 'assets/ic_password.png'),
    );
  }

  Widget buildFirstName() {
    return TextFormField(
      validator: (value) =>
          value!.isEmpty ? "First name cannot be empty" : null,
      style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 1), fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration("First name", 'assets/ic_worker.png'),
    );
  }

  Widget callbackImageButton(
      String imagePath, Color bgColor, VoidCallback callback,
      {double height = 50, double margin_t = 10}) {
    return buildCommon(
        bgColor,
        TextButton(
            onPressed: callback,
            child: Image(image: AssetImage('assets/images/$imagePath'))),
        height: height,
        margin_t: margin_t);
  }

  Widget callbackButton(String title, Color bgColor, VoidCallback callback,
      {double height = 50,
      TextAlign align = TextAlign.left,
      double fontSize = 18,
      FontWeight fontWeight = FontWeight.w600}) {
    return buildCommon(
        bgColor,
        TextButton(
            onPressed: callback,
            child: Text(title,
                textAlign: align,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: fontWeight,
                    fontFamily: "SFProText-Semibold",
                    fontSize: fontSize))),
        height: height);
  }

  Widget callbackButtonOutLine(
      String title, Color outLineColor, VoidCallback callback,
      {double height = 50,
      TextAlign align = TextAlign.left,
      double fontSize = 18,
      FontWeight fontWeight = FontWeight.w600}) {
    return buildCommon(
        Colors.transparent,
        TextButton(
            onPressed: callback,
            child: Text(title,
                textAlign: align,
                style: TextStyle(
                    color: outLineColor,
                    fontWeight: fontWeight,
                    fontFamily: "SFProText-Semibold",
                    fontSize: fontSize))),
        bordness: false,
        borderColor: outLineColor,
        height: height);
  }

  Widget seperateline(BuildContext context, {double height = 15}) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        height: height,
        child: Row(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2.3,
                height: 1,
                decoration: BoxDecoration(color: HexColor("#C4C4C4")),
              ),
            ),
            Spacer(),
            Center(
                child: Text(
              "or",
              style: TextStyle(color: HexColor("#C4C4C4"), fontSize: 10),
            )),
            Spacer(),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2.3,
                height: 1,
                decoration: BoxDecoration(color: HexColor("#C4C4C4")),
              ),
            ),
          ],
        ));
  }

  bool isEmail(String value) {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(regex);

    return isFieldHaveValues(value) && regExp.hasMatch(value);
  }

  bool isFieldHaveValues(String value) {
    return value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

//text styles
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
