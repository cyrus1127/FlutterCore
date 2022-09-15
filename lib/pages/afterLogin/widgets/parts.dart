import 'dart:async';
import 'dart:io';
//Widget button for bar on the top & bottom
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app_devbase_v1/component/dataObjects/notification.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';

Widget tapButtonWidget(VoidCallback onPress, String iconAssestPath,
    {bool clip = false,
    double padding = 10,
    bool fitHeight = true,
    bool onSelected = false}) {
  ImageProvider<Object> assetObj = loadImageAsset(iconAssestPath);

  return Container(
    padding: EdgeInsets.symmetric(
        vertical: globalDataStore.getResponsiveSize(padding)),
    child: TextButton(
      onPressed: onPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PhysicalModel(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(clip ? 13 : 0),
              child: Image(
                width: globalDataStore.getResponsivePositioning(32),
                height: globalDataStore.getResponsivePositioning(32),
                fit: fitHeight ? BoxFit.fitHeight : BoxFit.cover,
                image: assetObj,
              )),
          if (onSelected) ...[
            Container(
              width: globalDataStore.getResponsivePositioning(32),
              height: globalDataStore.getResponsivePositioning(32),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(clip ? 13 : 0),
                  border: Border.all(
                      width: 2, color: Color.fromRGBO(241, 163, 135, 1))),
            ),
          ],
        ],
      ),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    ),
  );
}

Widget postSummerWidget(String iconAssestPath, int count,
    {Color textColor = Colors.black, bool fixedPreTextWidth = true}) {
  return TextButton(
    onPressed: () {},
    child: Row(
      children: [
        Image(
          image: AssetImage('assets/images/$iconAssestPath.png'),
        ),
        Container(
          margin: EdgeInsets.only(left: globalDataStore.getResponsiveSize(10)),
          width:
              fixedPreTextWidth ? globalDataStore.getResponsiveSize(40) : null,
          child: Text(
            '$count',
            style: TextStyle(
                fontFamily: 'SFProText-Bold',
                color: textColor,
                fontSize: globalDataStore.getResponsiveSize(12),
                fontWeight: FontWeight.w700),
          ),
        )
      ],
    ),
    style: TextButton.styleFrom(padding: EdgeInsets.only(top: 0, bottom: 0)),
  );
}

//Widget button for bar on the top & bottom
Widget postActionButtonWidget(
  VoidCallback onPress,
  String iconAssestPath,
  String header, {
  Color textColor = Colors.black,
}) {
  return TextButton(
    onPressed: onPress,
    child: Row(
      children: [
        Image(
          image: AssetImage('assets/images/$iconAssestPath.png'),
        ),
        Container(
          margin: EdgeInsets.only(left: globalDataStore.getResponsiveSize(10)),
          child: Text(
            '$header',
            style: TextStyle(
                fontFamily: 'SFProText-Bold',
                color: textColor,
                fontSize: globalDataStore.getResponsiveSize(12),
                fontWeight: FontWeight.w700),
          ),
        )
      ],
    ),
    style: TextButton.styleFrom(padding: EdgeInsets.only(top: 0, bottom: 0)),
  );
}

//A horizontal bar and can be stack up over than 7 buttons. scrollable
Widget typeSwitchBar(double barWidth, double barHeight, double fontSize,
    List<String> selections, int onSelectedIdx, Function(int) onPress) {
  double maxButtonsOnView = 7;
  double buttonSize =
      (selections.length > 7 ? 7.5 : selections.length.toDouble());
  return Container(
    height: barHeight,
    width: barWidth,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(selections.length, (index) {
        return Container(
            width: barWidth / buttonSize,
            child: TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5)),
                onPressed: () {
                  onPress(index);
                },
                child: Image(
                  image: AssetImage('assets/images/' +
                      selections[index].toLowerCase() +
                      (onSelectedIdx == index ? '.png' : '.png')),
                )));
      }),
    ),
  );
}

//For view Explore , Message  and other need
Widget SearchingBlock(
    double width, double height, double padding, VoidCallback onPressed,
    {bool needMediaButton = true,
    bool supportDirectInput = false,
    double innerTextFieldHeight = 44,
    Function(String)? onChanged,
    Function(String)? onSubmitted}) {
  InputDecoration _buildInputDecoration(String hint, String iconPath) {
    return InputDecoration(
      border: UnderlineInputBorder(borderSide: BorderSide.none),
      hintText: hint,
      hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
      icon: iconPath != '' ? Image.asset(iconPath) : null,
    );
  }

  return //Create new post
      Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: Colors.white),
    child: Container(
      margin: EdgeInsets.symmetric(
          vertical: padding, horizontal: globalDataStore.getResponsiveSize(15)),
      child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              color: HexColor('#E8EBED'),
              borderRadius: BorderRadius.circular(
                  globalDataStore.getResponsivePositioning(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      top: globalDataStore.getResponsiveSize(10),
                      bottom: globalDataStore.getResponsiveSize(10),
                      left: globalDataStore
                          .getResponsiveSize(10)), //layout padding
                  child: Image(
                      height: globalDataStore.getResponsiveSize(24),
                      image: AssetImage('assets/images/icon_search.png')),
                ),
                Expanded(
                  child: MaterialButton(
                    padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(5)),
                    onPressed: onPressed,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        decoration: _buildInputDecoration('Search', ''),
                        style: TextStyle(),
                        textAlign: TextAlign.left,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
        ],
      ),
    ),
  );
}

Widget segment(double width, double height, List<String> options,
    String curValue, Function(String) onPress,
    {double padding_v = 8,
    double inner_padding = 2,
    bool needBorder = true,
    Color backgroundColor = Colors.transparent}) {
  return Container(
      height: globalDataStore
          .getResponsiveSize(height + (padding_v + inner_padding) * 2),
      padding: EdgeInsets.symmetric(
          vertical: globalDataStore.getResponsiveSize(padding_v),
          horizontal: globalDataStore.getResponsiveSize(15)),
      decoration: BoxDecoration(
          color: backgroundColor,
          border: BorderDirectional(
              bottom: BorderSide(
                  color: needBorder
                      ? Color.fromRGBO(0, 0, 0, 0.5)
                      : Colors.transparent,
                  width: 0.2))),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(225, 225, 225, 1),
            borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
            vertical: globalDataStore.getResponsiveSize(2),
            horizontal: globalDataStore.getResponsiveSize(2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(options.length, (index) {
            bool isMyType = curValue.compareTo(options[index]) == 0;
            return Container(
              width: (width - globalDataStore.getResponsiveSize(30) - (2 * 2)) /
                  (options.length),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    if (isMyType) ...[
                      BoxShadow(
                          blurRadius: 5,
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          offset:
                              Offset(0, globalDataStore.getResponsiveSize(1)))
                    ]
                  ],
                  color: (isMyType ? HexColor('#0E3658') : Colors.transparent)),
              child: TextButton(
                onPressed: () {
                  onPress(options[index]);
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(options[index],
                    style: TextStyle(
                        fontFamily: 'SFProText-Medium',
                        fontSize: globalDataStore.getResponsiveSize(15),
                        fontWeight: FontWeight.w500,
                        color:
                            (isMyType ? HexColor('#F1A387') : Colors.black))),
              ),
            );
          }),
        ),
      ));
}

//for home & postDetail contents
Widget createNewPostBlock(double width, double height, double padding,
    ProfileData userData, VoidCallback onPressed,
    {bool needMediaButton = true,
    bool supportDirectInput = false,
    Function(String)? onChanged}) {
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
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: globalDataStore.getResponsiveSize(10)),
            width: globalDataStore.getResponsiveSize(40),
            height: globalDataStore.getResponsiveSize(40),
            child: PhysicalModel(
              shape: BoxShape.rectangle,
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: getThumbRadius(height / 2),
              child: getThumbnailImage(userData.profilePic),
            ),
          ),
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
                Expanded(
                  child: MaterialButton(
                    onPressed: onPressed,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: supportDirectInput
                          ? TextField(
                              decoration: InputDecoration(
                                  hintText: 'Write something.....'),
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                              onChanged: onChanged,
                            )
                          : Text(
                              'Write something.....',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.left,
                            ),
                    ),
                  ),
                ),
                if (needMediaButton) ...[
                  Container(
                      height: globalDataStore.getResponsiveSize(height * 0.6),
                      child: TextButton(
                        onPressed: onPressed,
                        child: Image(
                            image: AssetImage(
                                'assets/images/icon_upload_image.png')),
                      ))
                ]
              ],
            ),
          )),
        ],
      ),
    ),
  );
}

//for home contents
Widget postBlock(PostData data, double layoutMargin, double blockWidth,
    Function(PostData) commentPressed, Function(PostData) mediaPressed) {
  String ownerName = 'No name';
  if (data.postOwnerID.length > 0) {
    ownerName = data.postOwnerID;
  }

  String postDatePassed = 'current';
  if (data.postDatetime.length > 0) {
    postDatePassed = globalDataStore.getTimeDiff(data.postDatetime);
  }

  int imageCount = 1;

  return Container(
      margin:
          EdgeInsets.only(bottom: globalDataStore.getResponsivePositioning(15)),
      decoration: BoxDecoration(color: Colors.white),
      child: MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            commentPressed(data);
          },
          child: Column(
            children: [
              Container(
                height: globalDataStore.getResponsiveSize(32),
                margin: EdgeInsets.only(
                    left: layoutMargin,
                    right: layoutMargin,
                    top: globalDataStore.getResponsivePositioning(10),
                    bottom: 0),
                child: Row(
                  children: [
                    Container(
                      width: globalDataStore.getResponsiveSize(32),
                      margin: EdgeInsets.only(
                          right: globalDataStore.getResponsivePositioning(10)),
                      child: PhysicalModel(
                          color: Colors.transparent,
                          shape: BoxShape.rectangle,
                          clipBehavior: Clip.antiAlias,
                          borderRadius: getThumbRadius(32),
                          child: Image(
                            height: globalDataStore.getResponsiveSize(32),
                            fit: BoxFit.cover,
                            image: loadImageAsset(data.postOwnerThumbnails),
                          )),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            ownerName,
                            style: TextStyle(
                                fontFamily: 'SFProText-Bold',
                                color: HexColor('#000000'),
                                fontSize: globalDataStore.getResponsiveSize(12),
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            postDatePassed,
                            style: TextStyle(
                                fontFamily: 'SFProText-Medium',
                                color: HexColor('#C4C4C4'),
                                fontSize: globalDataStore.getResponsiveSize(11),
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // height: globalDataStore.getResponsiveSize(60),
                margin: EdgeInsets.symmetric(horizontal: layoutMargin),
                padding: EdgeInsets.only(
                    top: globalDataStore.getResponsiveSize(20),
                    bottom: globalDataStore.getResponsiveSize(16)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      data.postContents.length > 0
                          ? data.postContents
                          : 'Text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text  te... see more',
                      style: TextStyle(
                          fontFamily: 'SFProText-Medium',
                          fontSize: globalDataStore.getResponsiveSize(14),
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ),
              ),

              //Post image
              Container(
                  height: globalDataStore.getResponsiveSize(210),
                  width: blockWidth,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: AssetImage(data.postMediaLink.length > 0
                              ? data.postMediaLink
                              : 'assets/images/thumbnails/original/f1.jpeg'))),
                  child: MaterialButton(onPressed: () {
                    print('Image on pressed, should open full view');
                    mediaPressed(data);
                  })),

              //Post short Summer
              Container(
                height: globalDataStore.getResponsiveSize(46),
                margin: EdgeInsets.symmetric(horizontal: layoutMargin),
                padding: EdgeInsets.only(
                    top: globalDataStore.getResponsivePositioning(10),
                    bottom: globalDataStore.getResponsivePositioning(12)),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  width: 0.5,
                ))),
                child: Row(
                  children: [
                    postSummerWidget('icon_like', data.likes),
                    postSummerWidget('icon_comment', data.comments),
                    Spacer(),
                    if (imageCount > 1) ...[
                      ///TODO : so the pageing dot
                    ]
                  ],
                ),
              ),
              //Post action button
              Container(
                height: globalDataStore.getResponsiveSize(24),
                margin: EdgeInsets.symmetric(
                    horizontal: layoutMargin,
                    vertical: globalDataStore.getResponsivePositioning(13)),
                padding: EdgeInsets.symmetric(horizontal: layoutMargin),
                child: Row(
                  children: [
                    postActionButtonWidget(() {}, 'icon_like2', 'Like'),
                    Spacer(),
                    postActionButtonWidget(() {
                      commentPressed(data);
                    }, 'icon_comment2', 'Comment'),
                    Spacer(),
                    postActionButtonWidget(() {}, 'icon_share2', 'Share'),
                  ],
                ),
              )
            ],
          )));
}

Widget createDailyRecordButton(VoidCallback onPressed,
    {double paddingWidth = 20}) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
            horizontal: globalDataStore.getResponsiveSize(paddingWidth))),
    child: Container(
      width: double.maxFinite,
      height: globalDataStore.getResponsiveSize(44),
      padding:
          EdgeInsets.symmetric(vertical: globalDataStore.getResponsiveSize(10)),
      decoration: BoxDecoration(
          color: Color.fromRGBO(14, 54, 88, 1),
          borderRadius:
              BorderRadius.circular(globalDataStore.getResponsiveSize(15))),
      child: Image(
        // height: globalDataStore.getResponsiveSize(24),
        image: AssetImage('assets/images/fi_plus.png'),
      ),
    ),
  );
}

Widget notificationRecordBlk(
    AppPushInfo data, Function(AppPushInfo) buttonPressed) {
  bool needActionButton = data.typeWillShowButtonAction();
  String postDatePassed = globalDataStore.getTimeDiff(data.postDatetime);
  double paddingV = 10;
  double blockHeight = needActionButton ? 72 : 52;

  Color buttonColor = Color.fromRGBO(14, 54, 88, 1);
  if (data.type == AppPushInfo.types[2]) {
    buttonColor = Color.fromRGBO(151, 151, 151, 1);
  }

  return Container(
    margin: EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(5)),
    padding: EdgeInsets.symmetric(
        horizontal: globalDataStore.getResponsiveSize(20),
        vertical: globalDataStore.getResponsiveSize(paddingV)),
    height: blockHeight + paddingV,
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: globalDataStore.getResponsiveSize(32),
            margin: EdgeInsets.only(
                right: globalDataStore.getResponsivePositioning(10)),
            child: PhysicalModel(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                clipBehavior: Clip.antiAlias,
                borderRadius: getThumbRadius(32),
                child: Image(
                  height: globalDataStore.getResponsiveSize(32),
                  fit: BoxFit.cover,
                  image: loadImageAsset(data.thumbnails),
                )),
          ),
        ),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  data.content,
                  style: TextStyle(
                      fontSize: globalDataStore.getResponsiveSize(12),
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            if (needActionButton) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: globalDataStore.getResponsiveSize(28),
                  width: globalDataStore.getResponsiveSize(162.5),
                  margin: EdgeInsets.only(
                      bottom: globalDataStore.getResponsiveSize(0)),
                  padding: EdgeInsets.symmetric(
                      vertical: globalDataStore.getResponsiveSize(4)),
                  decoration: BoxDecoration(
                      color: data.typeIndex() == 0 ? Colors.white : buttonColor,
                      border: Border.all(
                          color: data.typeIndex() == 0
                              ? buttonColor
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(
                          globalDataStore.getResponsiveSize(6.93))),
                  child: MaterialButton(
                    onPressed: () {
                      buttonPressed(data);
                    },
                    child: Text(
                      data.type,
                      style: TextStyle(
                          color: data.typeIndex() == 0
                              ? buttonColor
                              : Colors.white,
                          fontSize: globalDataStore.getResponsiveSize(12),
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            ]
          ],
        )),
        Container(
          width: 30,
          child: Column(
            children: [
              Spacer(),
              Text(
                postDatePassed,
                style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'SFProText-Medium',
                    color: HexColor('#C4C4C4'),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Image(
                  image: AssetImage('assets/images/icon_more.png'),
                ),
              ),
              Spacer(
                flex: 3,
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget dateTimeSwitchBar(double barWidth, double barHeight, double fontSize,
    String dateString, VoidCallback leftOnPress, VoidCallback rightOnPress) {
  double button_padding = 10;
  return Container(
    height: barHeight,
    width: barWidth,
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: globalDataStore.getResponsiveSize(button_padding))),
          onPressed: leftOnPress,
          child: Image(image: AssetImage('assets/images/icon_arrow_left.png')),
        ),
        Expanded(
            child: Text(
          dateString,
          style: TextStyle(
              fontFamily: 'SFProText-Medium',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.19),
          textAlign: TextAlign.center,
        )),
        TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: globalDataStore.getResponsiveSize(button_padding))),
          onPressed: rightOnPress,
          child: Image(image: AssetImage('assets/images/icon_arrow_right.png')),
        ),
      ],
    ),
  );
}

Widget filterSwitchBar(double barWidth, double barHeight, double fontSize,
    List<String> selections, int onSelectedIdx, Function(int) onPress) {
  return Container(
    height: barHeight,
    width: barWidth,
    padding:
        EdgeInsets.symmetric(horizontal: globalDataStore.getResponsiveSize(10)),
    decoration: BoxDecoration(color: HexColor('#F1A387')),
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(selections.length, (index) {
        return MaterialButton(
          onPressed: () {
            onPress(index);
          },
          minWidth: 0,
          padding: EdgeInsets.symmetric(
              horizontal: globalDataStore.getResponsiveSize(8)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text(
            selections[index],
            style: TextStyle(
              color: onSelectedIdx == index ? Colors.black : Colors.white,
              fontFamily: 'SFProText-Medium',
              fontSize: fontSize,
              letterSpacing: -0.19,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    ),
  );
}

//=-=-=-=-=-= Image loader =-=-=-=-=-=

ImageProvider<Object> loadImageAsset(String imagePath,
    {String defaultImage = 'assets/images/profile_default.png'}) {
  ImageProvider<Object> assetImg;
  if (imagePath.length == 0) {
    return AssetImage(defaultImage); //do default
  }

  //// Case check
  if (!imagePath.contains('assets/images/')) {
    ///other path
    if (imagePath.contains('http')) {
      //case : web link
      assetImg = NetworkImage(imagePath);
    } else if (imagePath.contains('user') ||
        imagePath.contains('private/var/')) {
      //case : device local files
      File imageFile = File(imagePath);
      assetImg = FileImage(imageFile);
    } else {
      if (!imagePath.contains("/") ||
          imagePath.compareTo("profile_default.png") == 0) {
        assetImg = AssetImage(defaultImage); //do default
      } else {
        assetImg = AssetImage(imagePath);
      }
    }
  } else {
    //Path for bundled images
    assetImg = AssetImage(imagePath);
  }
  return assetImg;
}

Image getThumbnailImage(String imagePath) {
  return Image(
    image: loadImageAsset(imagePath),
    fit: BoxFit.cover,
  );
}

BorderRadius getThumbRadius(double size_h) {
  return BorderRadius.all(
      Radius.circular(globalDataStore.getResponsiveSize(size_h) * 0.406));
}
