import 'dart:io';
import 'dart:ui';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/formInputField.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/subviews/dailyRecordTimeCounter.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:flutter/material.dart';

import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:page_transition/page_transition.dart';

import 'package:uuid/uuid.dart';

class DailyRecordCreate extends CommonStatefulWidget {
  const DailyRecordCreate(this.myData,
      {required Key? key, this.record, this.isAwakeMarker = false})
      : super(key: key);
  final ProfileData myData;

  DailyRecordCreate.onEdit(this.myData,
      {required Key? key, required this.record, this.isAwakeMarker = false})
      : super(key: key);
  final DailyRecord? record;

  DailyRecordCreate.makeAwake(this.myData,
      {required Key? key, required this.record, this.isAwakeMarker = true})
      : super(key: key);
  final isAwakeMarker;

  static String DATE_FORMAT = 'yyyy:MMM:d(th):HH(hr):mm(min)';
  @override
  _DailyRecordCreateState createState() => _DailyRecordCreateState();
}

class _DailyRecordCreateState extends State<DailyRecordCreate> {
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
  double quaityBarHeight = 32;
  double typeBarHeight = 150;
  double typeBarIitemWidth = 70;
  double typeBarIitemWidthUpScale = 113;
  double typeBarPadding = 50;
  double typeBarMarginBot = 10;

  TextStyle sharedTS_1 = TextStyle(
      fontFamily: 'SFProText',
      fontSize: globalDataStore.getResponsiveSize(12),
      fontWeight: FontWeight.w500,
      letterSpacing: -0.24,
      color: Colors.black);

  /// parameters for
  bool isEditingMode = false;
  DateTime? selectedDatetime_s; // = DateTime.now().toLocal();
  DateTime? selectedDatetime_e; // = DateTime.now().toLocal();
  int selectedDateTimeCounting = 0;
  bool timeStartRollerNeedShow = false;
  bool timeEndRollerNeedShow = false;
  int inputedAmount = 0;
  String quaity_tmp = '';
  String inputedNotes = '';
  int onSelectedTypeIndex = 0; // selection handling use perpa
  String onSelectedType = '';
  ScrollController typeListController = ScrollController();
  TextEditingController? teConAmount;
  TextEditingController? teConNote;

  Map<String, String>? getCurElement() {
    String typeKey = DailyRecord.typesMap.keys.elementAt(onSelectedTypeIndex);
    return DailyRecord.typesMap[typeKey];
  }

  void changeType(int typeTo) {
    onSelectedTypeIndex = typeTo;
    onSelectedType = getCurElement()!['name'] ?? '';

    //Update the Quaity as default first one
    if (getQuaities() != null) {
      quaity_tmp = getQuaities()![0];
    } else {
      quaity_tmp = '';
    }

    setState(() {
      // FocusScope.of(context).unfocus();
    });
  }

  double bottomZoneSize() {
    return 0.35;
  }

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  _scrollListener() {
    int n_index = 0;
    if (typeListController.offset >=
            typeListController.position.maxScrollExtent &&
        !typeListController.position.outOfRange) {
      // print("reach the bottom");
      n_index = DailyRecord.typesMap.length - 1;
    } else if (typeListController.offset <=
            typeListController.position.minScrollExtent &&
        !typeListController.position.outOfRange) {
      // print("reach the top");
      n_index = 0;
    } else {
      var pos = typeListController.offset -
          globalDataStore.getResponsiveSize(
              (typeBarIitemWidthUpScale - typeBarIitemWidth) /
                  2); // onSelecting size  - normal
      n_index =
          (pos / globalDataStore.getResponsiveSize(typeBarIitemWidth)).round();
      // print("scroll pos ? " + typeListController.offset.toString());
    }

    if (n_index != onSelectedTypeIndex) {
      // typeListController.jumpTo(
      //     globalDataStore.getResponsiveSize(typeBarHeight / 1.5) * n_index +
      //         typeBarHeight / 1.5);
      changeType(n_index);
    }
  }

  void timeCounting() {
    if (selectedDatetime_s != null && selectedDatetime_e != null) {
      int hours = selectedDatetime_e!.hour - selectedDatetime_s!.hour;
      int mins = selectedDatetime_e!.minute - selectedDatetime_s!.minute;
      selectedDateTimeCounting = hours * 60 + mins;
    }
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  List<String>? getQuaities() {
    String qt = getCurElement()!['quantity'] ?? '';

    if (qt.length > 0) {
      return qt.split('/');
    }
    return null;
  }

  String getButtonTitle() {
    if (onSelectedTypeIndex == 0 || onSelectedTypeIndex == 1) {
      if (selectedDatetime_s != null || selectedDatetime_e != null) {
        if (timeStartRollerNeedShow || timeEndRollerNeedShow) {
          return timeStartRollerNeedShow ? 'Save Start Time' : 'Save End Time';
        }
        return 'Record ' + (onSelectedTypeIndex == 0 ? 'Nursed' : 'Pumping');
      } else {
        return 'Start ' + (onSelectedTypeIndex == 0 ? 'Nursed' : 'Pumping');
      }
    } else if (selectedDatetime_s != null && timeStartRollerNeedShow) {
      return 'Save ' + onSelectedType + ' Time';
    }

    return isEditingMode ? 'Update Record' : 'Record';
  }

  void amountValueChanged() {
    // inputedAmount = int.parse(teConAmount!.text);
  }

  void SaveRecord() async {
    //Handle the special rule for cases

    if (onSelectedTypeIndex == 0 || onSelectedTypeIndex == 1) {
      //cases : Nursed && Feed
      if (selectedDatetime_s != null || selectedDatetime_e != null) {
        //TODO : close all on showing the picker
        if (timeEndRollerNeedShow || timeStartRollerNeedShow) {
          setState(() {
            timeEndRollerNeedShow = false;
            timeStartRollerNeedShow = false;
          });
          return;
        } else {
          if (selectedDatetime_s != null && selectedDatetime_e != null) {
            //do nothing and save record in common flow
          } else {
            print('start/end time haven\'t set');
            return;
          }
        }
      } else {
        //TODO : push the time Counter view
        print('push time counter view');
        Navigator.pop(context);
        Navigator.push(
            context,
            PageTransition(
                child: DailyRecordTimeCounter(
                    widget.myData,
                    onSelectedTypeIndex,
                    onSelectedType,
                    DailyRecord.typesMap.keys.elementAt(onSelectedTypeIndex),
                    quaity_tmp,
                    key: new Key(new Uuid().toString())),
                type: PageTransitionType.bottomToTop));
        return;
      }
    } else {
      if (timeStartRollerNeedShow) {
        if (onSelectedTypeIndex == 5) {
          //awake
          print('awake time set');
          //TODO : update the datetime duration
          timeCounting();
        }

        setState(() {
          timeStartRollerNeedShow = false;
        });
        return;
      }
    }

    if (widget.isAwakeMarker) {
      DailyRecord nAwakeRecord = new DailyRecord(
          id: new Uuid().hashCode.toString(),
          datetime: selectedDatetime_s.toString(),
          datetimeEnd: selectedDatetime_e.toString(),
          datetimeDuration: selectedDateTimeCounting,
          activityType: onSelectedTypeIndex,
          activityKey: DailyRecord.typesMap.keys.elementAt(onSelectedTypeIndex),
          activity: onSelectedType,
          quanity: quaity_tmp,
          amount: inputedAmount,
          amountMark: getCurElement()!['unit'] as String,
          notes: inputedNotes,
          userID: widget.myData.id);

      //TODO : Update Sleep record
      widget.record!.datetimeEnd = selectedDatetime_e.toString();
      await widget.setDailyDatas(widget.record).then((saveDone) async {
        if (saveDone) {
          //TODO : Add Awake record
          await widget.setDailyDatas(nAwakeRecord).then((saveDone) {
            if (saveDone) {
              onChange();
              setState(() {
                needShowInfoEditingView = false;
                Navigator.pop(context);
              });
            }
          });
        }
      });
    } else if (isEditingMode) {
      //update with existing record
      widget.record!.datetime = selectedDatetime_s.toString();
      widget.record!.datetimeEnd = selectedDatetime_e.toString();
      widget.record!.datetimeDuration = selectedDateTimeCounting;
      widget.record!.quanity = quaity_tmp;
      widget.record!.amount = inputedAmount;
      widget.record!.notes = inputedNotes;

      await widget.setDailyDatas(widget.record).then((saveDone) {
        if (saveDone) {
          onChange();
          setState(() {
            needShowInfoEditingView = false;
            Navigator.pop(context);
          });
        }
      });
    } else {
      //save as new record
      await widget
          .setDailyDatas(new DailyRecord(
              id: new Uuid().hashCode.toString(),
              datetime: selectedDatetime_s.toString(),
              datetimeEnd: selectedDatetime_e.toString(),
              datetimeDuration: selectedDateTimeCounting,
              activityType: onSelectedTypeIndex,
              activityKey:
                  DailyRecord.typesMap.keys.elementAt(onSelectedTypeIndex),
              activity: onSelectedType,
              quanity: quaity_tmp,
              amount: inputedAmount,
              amountMark: getCurElement()!['unit'] as String,
              notes: inputedNotes,
              userID: widget.myData.id))
          .then((saveDone) async {
        if (saveDone) {
          onChange();
          setState(() {
            needShowInfoEditingView = false;
            Navigator.pop(context);
          });
        }
      });
    }
  }

  void deleteRecord() async {
    ///TODO : remove current record
    print('remove current record');
    await widget.deleteDailyDatas(widget.record).then((saveDone) {
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

    typeListController.addListener(_scrollListener);
    isEditingMode = (widget.record != null);

    ///TODO : init with import data
    if (isEditingMode) {
      if (widget.isAwakeMarker) {
        //update sleepRecord
        onSelectedTypeIndex = widget.record!.activityType + 1;
        selectedDatetime_s = DateTime.parse(widget.record!.datetime);
        selectedDatetime_e = DateTime.now();
      } else {
        selectedDatetime_s = DateTime.parse(widget.record!.datetime);
        if (widget.record!.datetimeEnd != 'null') {
          selectedDatetime_e = DateTime.parse(widget.record!.datetimeEnd);
        } else {
          //init with start time with duration
          selectedDatetime_e = selectedDatetime_s;
          selectedDatetime_e!
              .add(Duration(minutes: widget.record!.datetimeDuration));
        }

        onSelectedTypeIndex = widget.record!.activityType;
        quaity_tmp = widget.record!.quanity;
        inputedAmount = widget.record!.amount;
        inputedNotes = widget.record!.notes;

        timeCounting();
      }
    }

    //init controller for textFields
    teConAmount = new TextEditingController(text: inputedAmount.toString());
    teConAmount!.addListener(amountValueChanged);
    teConNote = new TextEditingController(text: inputedNotes);
    teConNote!.addListener(amountValueChanged);

    changeType(onSelectedTypeIndex);
  }

  @override
  void dispose() {
    teConAmount!.dispose();
    teConNote!.dispose();
    typeListController.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) => KeyboardDismisser(
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
          body: Stack(children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.only(bottom: typeBarMarginBot),
                  padding: EdgeInsets.only(
                      top: globalDataStore.getResponsiveSize(typeBarPadding)),
                  decoration: BoxDecoration(
                      border: BorderDirectional(
                          bottom: BorderSide(color: Colors.black, width: 0.2))),
                  child: focusingTypeSwitchBar(
                      MediaQuery.of(context).size.width,
                      globalDataStore.getResponsiveSize(typeBarHeight),
                      globalDataStore.getResponsiveSize(typeBarPadding),
                      typeListController,
                      DailyRecord.typesMap,
                      onSelectedTypeIndex,
                      quaity_tmp,
                      changeType,
                      itemWidthUpScale: typeBarIitemWidthUpScale,
                      isSingleMode: isEditingMode),
                )),

            //Input penal
            Positioned(
                top: globalDataStore.getResponsiveSize(
                    typeBarHeight + typeBarPadding + typeBarMarginBot),
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  // height: MediaQuery.of(context).size.height -
                  //     globalDataStore.getResponsiveSize(
                  //         typeBarHeight + typeBarPadding + typeBarMarginBot),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(191, 191, 191, 1),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: globalDataStore.getResponsiveSize(25),
                            bottom: globalDataStore.getResponsiveSize(20)),
                        child: Stack(
                          children: [
                            Container(
                              height: globalDataStore.getResponsiveSize(30),
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              child: Text(
                                onSelectedType,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontSize:
                                        globalDataStore.getResponsiveSize(16),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.24,
                                    color: Colors.black),
                              ),
                            ),
                            if (isEditingMode) ...[
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    height:
                                        globalDataStore.getResponsiveSize(30),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: deleteRecord,
                                      icon: Icon(Icons.delete),
                                    ),
                                  ))
                            ]
                          ],
                        ),
                      ),
                      Expanded(
                          child: ListView(padding: EdgeInsets.zero, children: [
                        Column(
                          children: [
                            if (onSelectedTypeIndex <= 2 &&
                                getQuaities() != null) ...[
                              segment(
                                  MediaQuery.of(context).size.width,
                                  quaityBarHeight,
                                  getQuaities()!,
                                  quaity_tmp, (strVal) {
                                setState(() {
                                  quaity_tmp = strVal;
                                });
                              }),
                            ],

                            if (onSelectedTypeIndex <= 1) ...[
                              ///Nursed & Pumping

                              // Start time picker
                              timePicker(
                                  'Start',
                                  timeStartRollerNeedShow,
                                  () {
                                    if (selectedDatetime_s == null)
                                      selectedDatetime_s =
                                          DateTime.now().toLocal();
                                    setState(() {
                                      timeStartRollerNeedShow = true;
                                      timeEndRollerNeedShow = false;
                                    });
                                  },
                                  selectedDatetime_s,
                                  (n_DateTime) {
                                    setState(() {
                                      selectedDatetime_s = n_DateTime;
                                      timeCounting();
                                    });
                                  }),

                              // End time picker
                              timePicker(
                                  'End',
                                  timeEndRollerNeedShow,
                                  () {
                                    if (selectedDatetime_e == null)
                                      selectedDatetime_e =
                                          DateTime.now().toLocal();
                                    setState(() {
                                      timeStartRollerNeedShow = false;
                                      timeEndRollerNeedShow = true;
                                    });
                                  },
                                  selectedDatetime_e,
                                  (n_DateTime) {
                                    setState(() {
                                      selectedDatetime_e = n_DateTime;
                                      timeCounting();
                                    });
                                  }),

                              // Time counting for TimePicked
                              Container(
                                  height: globalDataStore.getResponsiveSize(48),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          globalDataStore.getResponsiveSize(15),
                                      vertical:
                                          globalDataStore.getResponsiveSize(5)),
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom: BorderSide(
                                              color: Colors.black,
                                              width: 0.2))),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        'Time',
                                        style: TextStyle(
                                            fontFamily: 'SFProText',
                                            fontSize: globalDataStore
                                                .getResponsiveSize(12),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.24,
                                            color: Colors.black),
                                      )),
                                      Text(selectedDateTimeCounting.toString() +
                                          ' min(s)')
                                    ],
                                  )),
                            ] else ...[
                              if (onSelectedTypeIndex == 5) ...[
                                /// case : Wake
                                timePicker(
                                    'Time',
                                    timeStartRollerNeedShow,
                                    () {
                                      if (selectedDatetime_e == null)
                                        selectedDatetime_e =
                                            DateTime.now().toLocal();
                                      setState(() {
                                        timeStartRollerNeedShow = true;
                                        timeEndRollerNeedShow = false;
                                      });
                                    },
                                    selectedDatetime_e,
                                    (n_DateTime) {
                                      setState(() {
                                        selectedDatetime_e = n_DateTime;
                                        timeCounting();
                                      });
                                    }),
                              ] else ...[
                                timePicker(
                                    'Time',
                                    timeStartRollerNeedShow,
                                    () {
                                      if (selectedDatetime_s == null)
                                        selectedDatetime_s =
                                            DateTime.now().toLocal();
                                      setState(() {
                                        timeStartRollerNeedShow = true;
                                        timeEndRollerNeedShow = false;
                                      });
                                    },
                                    selectedDatetime_s,
                                    (n_DateTime) {
                                      setState(() {
                                        selectedDatetime_s = n_DateTime;
                                        timeCounting();
                                      });
                                    }),
                              ]
                            ],

                            //Amount
                            if ((getCurElement()!['amount'] as String).length >
                                0) ...[
                              Container(
                                  height: globalDataStore.getResponsiveSize(48),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          globalDataStore.getResponsiveSize(15),
                                      vertical:
                                          globalDataStore.getResponsiveSize(5)),
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom: BorderSide(
                                              color: Colors.black,
                                              width: 0.2))),
                                  child: Row(
                                    children: [
                                      Text(
                                        (getCurElement()!['amount'] as String),
                                        style: TextStyle(
                                            fontFamily: 'SFProText',
                                            fontSize: globalDataStore
                                                .getResponsiveSize(12),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.24,
                                            color: Colors.black),
                                      ),
                                      Expanded(
                                          child: TextField(
                                        controller: teConAmount,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText:
                                                '0', //this hint will passively set the input alignment
                                            border: InputBorder.none),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontFamily: 'SFProText',
                                            // fontSize: globalDataStore
                                            //     .getResponsiveSize(12),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.24,
                                            color: Colors.black),
                                        onChanged: (value) {
                                          inputedAmount = int.parse(value);
                                        },
                                      )),
                                      Text(' ' +
                                          (getCurElement()!['unit'] as String))
                                    ],
                                  )),
                            ] else ...[
                              if (getQuaities() != null) ...[
                                segment(
                                    MediaQuery.of(context).size.width,
                                    quaityBarHeight,
                                    getQuaities()!,
                                    quaity_tmp, (strVal) {
                                  setState(() {
                                    quaity_tmp = strVal;
                                  });
                                }),
                              ],
                            ],

                            /// Notes :
                            Container(
                                height: globalDataStore.getResponsiveSize(160),
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      globalDataStore.getResponsiveSize(15),
                                ),
                                decoration: BoxDecoration(
                                    border: BorderDirectional(
                                        bottom: BorderSide(
                                            color: Colors.black, width: 0.2))),
                                // alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Container(
                                      height:
                                          globalDataStore.getResponsiveSize(30),
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          top: globalDataStore
                                              .getResponsiveSize(17)),
                                      child: Text(
                                        'Node (option)',
                                        style: TextStyle(
                                            fontFamily: 'SFProText',
                                            fontSize: globalDataStore
                                                .getResponsiveSize(12),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.15,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Container(
                                          decoration: BoxDecoration(
                                              // color: Colors.purple,
                                              ),
                                          height: globalDataStore
                                              .getResponsiveSize(160 - 35),
                                          child: TextField(
                                            controller: teConNote,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              hintText: 'Type the note ',
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide.none),
                                            ),
                                            style: TextStyle(
                                                fontFamily: 'SFProText',
                                                fontSize: globalDataStore
                                                    .getResponsiveSize(12),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: -0.24,
                                                color: Colors.black),
                                            minLines: 1,
                                            maxLines: 3,
                                            textAlign: TextAlign.left,
                                            onChanged: (value) {
                                              inputedNotes = value;
                                            },
                                            // onSubmitted: (value) {},
                                          ),
                                        )),
                                        Container(
                                          height: globalDataStore
                                              .getResponsiveSize(160 - 35),
                                          width: 35,
                                          padding: EdgeInsets.only(
                                              top: 10, right: 15),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Image(
                                              image: AssetImage(
                                                  'assets/images/icon_upload_image.png'),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )),
                          ],
                        ),
                      ])),
                      Column(children: [
                        //Buttons
                        if ((timeStartRollerNeedShow ||
                                timeEndRollerNeedShow) &&
                            (onSelectedTypeIndex <= 1)) ...[
                          Container(
                              width: double.maxFinite,
                              height: globalDataStore.getResponsiveSize(60),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      globalDataStore.getResponsiveSize(15)),
                              margin: EdgeInsets.only(
                                  bottom:
                                      globalDataStore.getResponsiveSize(15)),
                              child: _formBuilder.callbackButton(
                                  getButtonTitle(),
                                  HexColor('#0F3657'),
                                  SaveRecord)),
                        ] else ...[
                          Container(
                              width: double.maxFinite,
                              height: globalDataStore.getResponsiveSize(60),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      globalDataStore.getResponsiveSize(15)),
                              child: _formBuilder.callbackButton(
                                  getButtonTitle(),
                                  HexColor('#0F3657'),
                                  SaveRecord)),
                          Container(
                              width: double.maxFinite,
                              height: globalDataStore.getResponsiveSize(60),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      globalDataStore.getResponsiveSize(15)),
                              margin: EdgeInsets.only(
                                  bottom:
                                      globalDataStore.getResponsiveSize(15)),
                              child: _formBuilder
                                  .callbackButton('Cancel', Colors.grey, () {
                                setState(() {
                                  // needShowInfoEditingView = false;
                                  Navigator.pop(context);
                                });
                              }))
                        ]
                      ])
                    ],
                  ),
                )),
          ]),
        ),
      );
}

Widget focusingTypeSwitchBar(
    double barWidth,
    double barHeight,
    double padding,
    ScrollController controller,
    Map<String, Map<String, String>> selectionsMapping,
    int onSelectedIdx,
    String onSelectedQt,
    Function(int) onPress,
    {double itemWidth = 70,
    double itemWidthUpScale = 70,
    bool isSingleMode = false}) {
  double maxButtonsOnView = 7;
  double buttonSize = (selectionsMapping.length > 7
      ? 7.5
      : selectionsMapping.length.toDouble());
  double fontSize = 20;

  //special case
  if (isSingleMode) {
    String keyName = selectionsMapping.keys.elementAt(onSelectedIdx);
    String subfix = '.png';
    if (onSelectedIdx == 0) {
      //case for Nursed & pump
      subfix = '_' + onSelectedQt.toLowerCase() + '.png';
    }
    return Container(
      // width:
      //     globalDataStore.getResponsiveSize(itemWidthUpScale),
      margin:
          EdgeInsets.symmetric(horizontal: (barWidth - itemWidthUpScale) / 2),
      height: barHeight,
      // decoration: BoxDecoration(color: Colors.amber),
      child: Image(
        // fit: BoxFit.fitWidth,
        image: AssetImage('assets/images/' + keyName + subfix),
      ),
    );
  }

  //returned widget content
  return Container(
    width: barWidth,
    height: barHeight,
    // decoration: BoxDecoration(color: Colors.amber),
    child: ListView(
      shrinkWrap: false,
      controller: controller,
      padding: EdgeInsets.symmetric(
          horizontal: (barWidth / 2) - (itemWidthUpScale / 2)),
      // shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: List.generate(selectionsMapping.length, (index) {
        //get the name
        String keyName = selectionsMapping.keys.elementAt(index);
        // Map<String, String>? selectedDict = selectionsMapping[keyName];
        // String? displayName = selectedDict!['name'];

        String subfix = '.png';
        if (index == 0) {
          //the uqlit
          //case for Nursed & pump
          if (onSelectedIdx == index) {
            subfix = '_' + onSelectedQt.toLowerCase() + '.png';
          } else {
            subfix = '_both.png';
          }
        }

        if (onSelectedIdx == index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: globalDataStore.getResponsiveSize(itemWidthUpScale),
                  padding: EdgeInsets.symmetric(
                      horizontal: globalDataStore.getResponsiveSize(3)),
                  child: Image(
                    fit: BoxFit.fitWidth,
                    image: AssetImage('assets/images/' + keyName + subfix),
                  )),
              // Container(
              //     width: barHeight / 1.5,
              //     child: Text(
              //       selections[index],
              //       textAlign: TextAlign.center,
              //       style: TextStyle(
              //           fontFamily: 'SFProText-Semibold',
              //           fontSize: globalDataStore.getResponsiveSize(fontSize),
              //           fontWeight: FontWeight.w600,
              //           letterSpacing: -0.24,
              //           color: Colors.white,
              //           decoration: TextDecoration.none),
              //     )),
            ],
          );
        }

        return Container(
            width: globalDataStore.getResponsiveSize(itemWidth),
            padding: EdgeInsets.symmetric(
                horizontal: globalDataStore.getResponsiveSize(3)),
            child: Image(
              fit: BoxFit.fitWidth,
              image: AssetImage('assets/images/' + keyName + subfix),
            ));
      }),
    ),
  );
}

Widget timePicker(String rowName, bool needShow, VoidCallback addButtonPressed,
    DateTime? curValue, Function(DateTime) onChange) {
  String MIN_DATETIME =
      DateTime.now().subtract(Duration(days: 365)).toLocal().toString();
  String MAX_DATETIME =
      DateTime.now().add(Duration(days: 365)).toLocal().toString();

  bool isNullSet = false;
  if (curValue == null) {
    isNullSet = true;
    curValue = DateTime.now().toLocal();
  }

  return Column(children: [
    Container(
        height: globalDataStore.getResponsiveSize(48),
        padding: EdgeInsets.symmetric(
            horizontal: globalDataStore.getResponsiveSize(15),
            vertical: globalDataStore.getResponsiveSize(5)),
        decoration: BoxDecoration(
            border: BorderDirectional(
                bottom: BorderSide(color: Colors.black, width: 0.2))),
        child: Row(
          children: [
            Expanded(
                child: Text(
              rowName,
              style: TextStyle(
                  fontFamily: 'SFProText',
                  fontSize: globalDataStore.getResponsiveSize(12),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.24,
                  color: Colors.black),
            )),
            if (isNullSet) ...[
              Container(
                  width: globalDataStore.getResponsiveSize(32),
                  height: globalDataStore.getResponsiveSize(32),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: addButtonPressed,
                    icon: Icon(Icons.add),
                    color: Colors.white,
                  ))
            ] else ...[
              TextButton(
                  onPressed: addButtonPressed,
                  child: Text(
                    curValue.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero))
            ]
          ],
        )),
    if (needShow) ...[
      Container(
        height: globalDataStore.getResponsiveSize(216), //datetimePickerHeight
        // margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            border: BorderDirectional(
                bottom: BorderSide(color: Colors.black, width: 0.2))),
        child: DateTimePickerWidget(
          minDateTime: DateTime.parse(MIN_DATETIME),
          maxDateTime: DateTime.parse(MAX_DATETIME),
          initDateTime: DateTime.parse(curValue.toString()),
          dateFormat: DailyRecordCreate.DATE_FORMAT,
          minuteDivider: 15,
          pickerTheme: DateTimePickerTheme(
              showTitle: false, backgroundColor: Color.fromRGBO(0, 0, 0, 0)),
          onChange: (dateTime, selectedIndex) {
            onChange(dateTime);
          },
        ),
      ),
    ],
  ]);
}
