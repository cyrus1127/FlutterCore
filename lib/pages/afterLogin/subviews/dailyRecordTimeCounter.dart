import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/formInputField.dart';
import 'package:app_devbase_v1/component/formInputField_FW.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:flutter/material.dart';



import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import 'package:uuid/uuid.dart';

class DailyRecordTimeCounter extends CommonStatefulWidget {
  const DailyRecordTimeCounter(this.myData, this.index, this.recordTypeName,
      this.recordType, this.quaity_tmp,
      {required Key? key})
      : super(key: key);
  final ProfileData myData;
  final int index;
  final String recordTypeName;
  final String recordType;
  final String quaity_tmp;

  static String DATE_FORMAT = 'yyyy:MMM:d(th):HH(hr):mm(min)';
  @override
  _DailyRecordTimeCounterState createState() => _DailyRecordTimeCounterState();
}

class _DailyRecordTimeCounterState extends State<DailyRecordTimeCounter> {
  final TextEditingController _controller = TextEditingController();
  final ProfileFormInputField _forUnitBuilder = ProfileFormInputField();
  final FormInputField _formBuilder = FormInputField();
  List<DailyRecord> datas = [];
  bool isLoginFormNeed = false;
  bool isRegistrationFormNeed = false;
  bool needShowWelcomeAlert = false;
  bool needShowInfoEditingView = false;

  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double endAnimatedPosition = -40;
  double editingBlockHeight = 565;
  double datetimePickerHeight = 216;
  double quaityBarHeight = 50;

  String id = new Uuid().hashCode.toString();

  DateTime? selectedDatetime_s; // = DateTime.now().toLocal();
  DateTime? selectedDatetime_e; // = DateTime.now().toLocal();
  int selectedDateTimeCounting = 0;
  bool timeStartRollerNeedShow = false;
  bool timeEndRollerNeedShow = false;

  int inputedAmount = 0;
  String amountUnit = 'ml';

  double typeBarHeight = 150;
  double typeBarPadding = 50;
  double typeBarMarginBot = 10;

  double timeCounting = 0;
  Timer? myTimer;
  String onDisplayTimestamp = '00:00';
  String onDisplayTimestamp_sec = '00';
  bool viewPoped = false;

  void changeType(int typeTo) {
    setState(() {});
  }

  double bottomZoneSize() {
    return 0.35;
  }

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  //// -=-=-=-=-=-=-=-=-  Timer handling -=-=-=-=-=-=-=-=-////
  void startCounting() {
    if (myTimer == null) {
      //Start timer and repeating with every second
      myTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        timeCounting++;
        double hrs = timeCounting / 60 / 12;
        double mins = timeCounting / 60;
        double sec = (timeCounting % 60);

        onDisplayTimestamp = hrs.toInt().toString().padLeft(2, '0') +
            ':' +
            mins.toInt().toString().padLeft(2, '0');
        onDisplayTimestamp_sec = sec.toInt().toString().padLeft(2, '0');
        setState(() {});
      });
    } else {}
  }

  void pauseCounting() {
    if (myTimer != null && myTimer!.isActive) {
      //TODO : pause timeCounting
      myTimer!.cancel();
      myTimer = null;
    }
  }

  void resumeCounting() {
    if (timeCounting > 0) {
      //Do resume
      startCounting();
    }
  }

  //// -=-=-=-=-=-=-=-=-  Other handling -=-=-=-=-=-=-=-=-////

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  void SaveRecord() async {
    String imgName = widget.recordType;
    if (widget.index == 0) {
      imgName = widget.recordType + '_' + widget.quaity_tmp;
    } else if (widget.index == 1) {
      // imgName = widget.recordType;
    }

    //stop the timer
    pauseCounting();

    //If no rules , save as new record
    await widget
        .setDailyDatas(DailyRecord(
            id: new Uuid().hashCode.toString(),
            datetime: selectedDatetime_s.toString(),
            datetimeEnd: selectedDatetime_e.toString(),
            datetimeDuration: selectedDateTimeCounting,
            activityType: widget.index,
            activityKey: widget.recordType,
            activity: widget.recordTypeName,
            quanity: widget.quaity_tmp,
            amountMark: 'ml',
            notes: '',
            userID: widget.myData.id))
        .then((saveDone) {
      if (saveDone) {
        onChange();
        setState(() {
          needShowInfoEditingView = false;
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDatetime_s = DateTime.now().toLocal();

    //init the timer
    timeCounting = 0;
    startCounting();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) => KeyboardDismisser(
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          backgroundColor: Color.fromRGBO(241, 163, 135, 1),
          body: Column(
            children: [
              Container(
                height: globalDataStore.getResponsiveSize(138),
                // margin: EdgeInsets.only(
                //     top: globalDataStore.getResponsiveSize(25),
                //     bottom: globalDataStore.getResponsiveSize(20)),
                child: Center(
                  child: Text(
                    widget.recordTypeName,
                    style: TextStyle(
                        fontFamily: 'SFProText',
                        fontSize: globalDataStore.getResponsiveSize(16),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.24,
                        color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                  child: ListView(padding: EdgeInsets.zero, children: [
                Column(
                  children: [
                    Center(
                      child: Text(
                        widget.quaity_tmp,
                        style: TextStyle(
                            fontFamily: 'SFProText',
                            fontSize: globalDataStore.getResponsiveSize(30),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.24,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      child: Text(
                        widget.index == 0 ? 'Feeding Time' : 'Pumping Time',
                        style: TextStyle(
                            fontFamily: 'SFProText',
                            fontSize: globalDataStore.getResponsiveSize(16),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.24,
                            color: Colors.white),
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: globalDataStore.getResponsiveSize(15)),
                    ),
                    getIcon(widget.recordType, widget.quaity_tmp, widget.index),
                    Container(
                      height: globalDataStore.getResponsiveSize(94),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            onDisplayTimestamp,
                            style: TextStyle(
                                fontFamily: 'SFProText',
                                fontSize: globalDataStore.getResponsiveSize(60),
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.24,
                                color: HexColor('#0F3657')),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: globalDataStore.getResponsiveSize(20)),
                            child: Text(
                              onDisplayTimestamp_sec,
                              style: TextStyle(
                                  fontFamily: 'SFProText',
                                  fontSize:
                                      globalDataStore.getResponsiveSize(30),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.24,
                                  color: HexColor('#0F3657')),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Start time picker
                    Container(
                        height: globalDataStore.getResponsiveSize(48),
                        padding: EdgeInsets.symmetric(
                            vertical: globalDataStore.getResponsiveSize(5)),
                        margin: EdgeInsets.symmetric(
                            horizontal: globalDataStore.getResponsiveSize(15),
                            vertical: globalDataStore.getResponsiveSize(15)),
                        decoration: BoxDecoration(
                            border: BorderDirectional(
                                bottom: BorderSide(
                                    color: Colors.white, width: 0.2))),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              'Start',
                              style: TextStyle(color: Colors.white),
                            )),
                            Text(
                              selectedDatetime_s.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )),

                    Container(
                        width: double.maxFinite,
                        height: globalDataStore.getResponsiveSize(60),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: _formBuilder.callbackButton('Finish & Record',
                            HexColor('#0F3657'), SaveRecord)),
                    Container(
                        width: double.maxFinite,
                        height: globalDataStore.getResponsiveSize(60),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: _formBuilder.callbackButtonOutLine(
                            timeCounting > 0 && myTimer == null
                                ? 'Resume'
                                : 'Pause',
                            HexColor('#0F3657'),
                            pauseCounting)),
                    Container(
                        width: double.maxFinite,
                        height: globalDataStore.getResponsiveSize(60),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        margin: EdgeInsets.only(bottom: 15),
                        child: TextButton(
                            onPressed: () {
                              pauseCounting();
                              if (Navigator.canPop(context)) {
                                viewPoped = true;
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            )))
                  ],
                ),
              ])),
            ],
          ),
        ),
      );
}

Widget getIcon(String typeName, String qt, int typeIndex) {
  String imgPath = 'assets/images/' + typeName.toLowerCase() + '_edit.png';
  if (typeIndex == 0) {
    imgPath = 'assets/images/' +
        typeName.toLowerCase() +
        '_' +
        qt.toLowerCase() +
        '_edit.png';
  }

  return Container(
      width: 116,
      child: Image(
        fit: BoxFit.fitWidth,
        image: AssetImage(imgPath),
      ));
}
