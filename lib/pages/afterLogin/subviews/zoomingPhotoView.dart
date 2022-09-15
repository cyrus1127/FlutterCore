import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:photo_view/photo_view.dart';

class ZoomingPhotoView extends CommonStatefulWidget {
  ZoomingPhotoView.clean(this.imagePath, {this.myData}) : super.clean();

  final String imagePath;
  final ProfileData? myData;
  @override
  _ZoomingPhotoView createState() => _ZoomingPhotoView();
}

class _ZoomingPhotoView extends State<ZoomingPhotoView> {
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double endAnimatedPosition = -40;
  double editingBlockHeight = 565;
  double datetimePickerHeight = 216;
  double quaityBarHeight = 45;

  double layoutMargin = globalDataStore.getResponsiveSize(15); //for builds bar

  bool showAsGallery = false;
  bool needShowPhotoView = false;

  List<PostData> postRecords = [];

  void loadPostRecords() async {
    postRecords.clear();
    await widget.getPostDatas().then((value) {
      value!.forEach((element) {
        postRecords.add(element);
      });
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadPostRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: PhotoView(
                imageProvider: AssetImage(widget.imagePath),
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
                        margin:
                            EdgeInsets.only(left: widget.getResponsiveSize(10)),
                        child: TextButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Image(
                            width: widget.getResponsiveSize(25),
                            image: AssetImage('assets/images/icon_close3.png'),
                          ),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                                    fontSize:
                                        globalDataStore.getResponsiveSize(20),
                                    fontWeight: FontWeight.w600),
                              )),
                        )
                      ]
                    ],
                  ))),

          //Bottom bar with buttons
          if (widget.myData != null) ...[
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
                            horizontal:
                                globalDataStore.getResponsivePositioning(15)),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.myData!.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        globalDataStore.getResponsiveSize(14),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'SFProText-Bold'),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.myData!.formatedDateOfBirth(),
                                  style: TextStyle(
                                      color: HexColor('#C4C4C4'),
                                      fontSize:
                                          globalDataStore.getResponsiveSize(10),
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
                            top: globalDataStore.getResponsivePositioning(8),
                            bottom:
                                globalDataStore.getResponsivePositioning(10)),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.5, color: Colors.white))),
                        child: Row(
                          children: [
                            postSummerWidget(
                                'icon_like_white', postRecords[0].likes,
                                textColor: Colors.white),
                            postSummerWidget(
                                'icon_comment_white', postRecords[0].comments,
                                textColor: Colors.white),
                          ],
                        ),
                      ),
                      //Post action button
                      Container(
                        height: globalDataStore.getResponsiveSize(30),
                        margin: EdgeInsets.symmetric(
                            horizontal: layoutMargin,
                            vertical:
                                globalDataStore.getResponsivePositioning(13)),
                        padding: EdgeInsets.symmetric(horizontal: layoutMargin),
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
      ),
    );
  }
}
