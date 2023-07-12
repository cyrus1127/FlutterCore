import 'dart:io';
import 'dart:ui';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/formInputField.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:flutter/material.dart';



import 'package:image_picker/image_picker.dart';

import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:uuid/uuid.dart';

class PregnancyRecordCreate extends CommonStatefulWidget {
  final ProfileData myData;
  final PregnancyDailyRecord? record;
  final DateTime? recordDate;

  const PregnancyRecordCreate(this.myData,
      {required Key? key, this.record, required this.recordDate})
      : super(key: key);

  PregnancyRecordCreate.onEdit(this.myData,
      {required Key? key, required this.record, this.recordDate})
      : super(key: key);

  static String DATE_FORMAT = 'yyyy:MMM:d(th):HH(hr):mm(min)';
  @override
  _PregnancyRecordCreateState createState() => _PregnancyRecordCreateState();
}

class _PregnancyRecordCreateState extends State<PregnancyRecordCreate> {
  final FormInputField _formBuilder = FormInputField();

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
  double typeBarHeight = 92;
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

  bool timeStartRollerNeedShow = false;
  bool timeEndRollerNeedShow = false;
  double inputedAmount_crl = 0;
  double inputedAmount_bpd = 0;
  double inputedAmount_hc = 0;
  double inputedAmount_fl = 0;
  double inputedAmount_ac = 0;
  String inputedNotes = '';
  String recordImage = '';
  ScrollController typeListController = ScrollController();
  TextEditingController? teConAmount_crl;
  TextEditingController? teConAmount_bpd;
  TextEditingController? teConAmount_hc;
  TextEditingController? teConAmount_fl;
  TextEditingController? teConAmount_ac;
  TextEditingController? teConNote;

  Map<String, String>? getCurElement() {
    return null;
  }

  void changeType(int typeTo) {
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
    return isEditingMode ? 'Update Record' : 'Record';
  }

  void amountValueChanged() {
    // inputedAmount = int.parse(teConAmount!.text);
  }

  void SaveRecord() async {
    //Handle the special rule for cases

    if (isEditingMode) {
      //update with existing record
      widget.record!.photoPath = recordImage;
      widget.record!.crl = inputedAmount_crl;
      widget.record!.bpd = inputedAmount_bpd;
      widget.record!.hc = inputedAmount_hc;
      widget.record!.fl = inputedAmount_fl;
      widget.record!.ac = inputedAmount_ac;
      widget.record!.notes = inputedNotes;

      await widget.setPregnancyData(widget.record).then((saveDone) {
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
          .setPregnancyData(new PregnancyDailyRecord(
              id: new Uuid().hashCode.toString(),
              datetime: selectedDatetime_s.toString(),
              photoPath: recordImage,
              crl: inputedAmount_crl,
              bpd: inputedAmount_bpd,
              hc: inputedAmount_hc,
              fl: inputedAmount_fl,
              ac: inputedAmount_ac,
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
    await widget.deletePregnancyDatas(widget.record).then((saveDone) {
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

    isEditingMode = (widget.record != null);

    ///TODO : init with import data
    if (isEditingMode) {
      {
        selectedDatetime_s = DateTime.parse(widget.record!.datetime);
        inputedNotes = widget.record!.notes;
        recordImage = widget.record!.photoPath;
        inputedAmount_crl = widget.record!.crl;
        inputedAmount_bpd = widget.record!.bpd;
        inputedAmount_hc = widget.record!.hc;
        inputedAmount_fl = widget.record!.fl;
        inputedAmount_ac = widget.record!.ac;
        teConAmount_crl =
            new TextEditingController(text: widget.record!.crl.toString());
        teConAmount_bpd =
            new TextEditingController(text: widget.record!.bpd.toString());
        teConAmount_hc =
            new TextEditingController(text: widget.record!.hc.toString());
        teConAmount_fl =
            new TextEditingController(text: widget.record!.fl.toString());
        teConAmount_ac =
            new TextEditingController(text: widget.record!.ac.toString());
      }
    } else {
      if (widget.recordDate != null) {
        selectedDatetime_s = widget.recordDate;
      }
      teConAmount_crl =
          new TextEditingController(text: inputedAmount_crl.toString());
      teConAmount_bpd =
          new TextEditingController(text: inputedAmount_bpd.toString());
      teConAmount_hc =
          new TextEditingController(text: inputedAmount_hc.toString());
      teConAmount_fl =
          new TextEditingController(text: inputedAmount_fl.toString());
      teConAmount_ac =
          new TextEditingController(text: inputedAmount_ac.toString());
    }

    //init controller for textFields
    teConAmount_crl!.addListener(amountValueChanged);
    teConAmount_bpd!.addListener(amountValueChanged);
    teConAmount_hc!.addListener(amountValueChanged);
    teConAmount_fl!.addListener(amountValueChanged);
    teConAmount_ac!.addListener(amountValueChanged);

    teConNote = new TextEditingController(text: inputedNotes);
    teConNote!.addListener(amountValueChanged);
  }

  @override
  void dispose() {
    teConAmount_crl!.dispose();
    teConAmount_bpd!.dispose();
    teConAmount_hc!.dispose();
    teConAmount_fl!.dispose();
    teConAmount_ac!.dispose();
    teConNote!.dispose();
    typeListController.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) => KeyboardDismisser(
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
          body: Stack(children: [
            //Input penal
            Positioned(
                top: globalDataStore.getResponsiveSize(typeBarHeight),
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
                                'Record a Moment',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'SFProText',
                                    fontSize:
                                        globalDataStore.getResponsiveSize(16),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.24,
                                    fontStyle: FontStyle.normal,
                                    color: Color.fromRGBO(13, 54, 88, 1)),
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
                            // Date
                            Container(
                                height: globalDataStore.getResponsiveSize(48),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        globalDataStore.getResponsiveSize(15),
                                    vertical:
                                        globalDataStore.getResponsiveSize(5)),
                                // decoration: BoxDecoration(
                                //     border: BorderDirectional(
                                //         bottom: BorderSide(
                                //             color: Colors.black,
                                //             width: 0.2))),
                                alignment: Alignment.center,
                                child: Text(
                                  globalDataStore.getCustomFormatDateTime(
                                      selectedDatetime_s!),
                                  style: TextStyle(
                                      fontFamily: 'SFProText',
                                      fontSize:
                                          globalDataStore.getResponsiveSize(15),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.5,
                                      color: Color.fromRGBO(13, 54, 88, 1)),
                                )),

                            // Record's image
                            if (recordImage.length > 0) ...[
                              MaterialButton(
                                onPressed: () async {
                                  PickedFile? pickedFile = await ImagePicker()
                                      .getImage(source: ImageSource.gallery);

                                  if (pickedFile != null) {
                                    print('Pressed : ' + pickedFile.path);
                                    setState(() {
                                      //set the
                                      recordImage = pickedFile.path;
                                    });
                                  }
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  height:
                                      globalDataStore.getResponsiveSize(258),
                                  width: double.maxFinite,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: globalDataStore
                                          .getResponsiveSize(15)),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          globalDataStore
                                              .getResponsiveSize(15)),
                                      color:
                                          Color.fromRGBO(255, 255, 255, 0.5)),
                                  alignment: Alignment.center,
                                  child: PhysicalModel(
                                    clipBehavior: Clip.antiAlias,
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(
                                        globalDataStore.getResponsiveSize(15)),
                                    child: Image(
                                      width: double.maxFinite,
                                      fit: BoxFit.fitWidth,
                                      image: loadImageAsset(recordImage),
                                    ),
                                  ),
                                ),
                              )
                            ] else ...[
                              MaterialButton(
                                onPressed: () async {
                                  PickedFile? pickedFile = await ImagePicker()
                                      .getImage(source: ImageSource.gallery);

                                  if (pickedFile != null) {
                                    print('Pressed : ' + pickedFile.path);
                                    setState(() {
                                      //set the
                                      recordImage = pickedFile.path;
                                    });
                                  }
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  height:
                                      globalDataStore.getResponsiveSize(258),
                                  width: double.maxFinite,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: globalDataStore
                                          .getResponsiveSize(15)),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          globalDataStore
                                              .getResponsiveSize(15)),
                                      color:
                                          Color.fromRGBO(255, 255, 255, 0.5)),
                                  alignment: Alignment.center,
                                  child: Image(
                                    height:
                                        globalDataStore.getResponsiveSize(48),
                                    image: AssetImage(
                                        'assets/images/icon_upload_image.png'),
                                  ),
                                ),
                              )
                            ],

                            //Amounts
                            amountRow(
                                'CRL, Cephalo-rump Length', teConAmount_crl,
                                (value) {
                              inputedAmount_crl = double.parse(value);
                            }),
                            amountRow(
                                'BPD, Biparietal Diameter', teConAmount_bpd,
                                (value) {
                              inputedAmount_bpd = double.parse(value);
                            }),
                            amountRow('HC, Head Circumference', teConAmount_hc,
                                (value) {
                              inputedAmount_hc = double.parse(value);
                            }),
                            amountRow('FL, Femer Length', teConAmount_fl,
                                (value) {
                              inputedAmount_fl = double.parse(value);
                            }),
                            amountRow(
                                'AC, Abdominal Circumference', teConAmount_ac,
                                (value) {
                              inputedAmount_ac = double.parse(value);
                            }),

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
                                      padding: EdgeInsets.only(
                                          top: globalDataStore
                                              .getResponsiveSize(17)),
                                      alignment: Alignment.centerLeft,
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
                                      ],
                                    )
                                  ],
                                )),
                          ],
                        ),
                      ])),
                      Column(children: [
                        //Buttons

                        Container(
                            width: double.maxFinite,
                            height: globalDataStore.getResponsiveSize(60),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    globalDataStore.getResponsiveSize(15)),
                            child: _formBuilder.callbackButton(getButtonTitle(),
                                HexColor('#0F3657'), SaveRecord)),
                        Container(
                            width: double.maxFinite,
                            height: globalDataStore.getResponsiveSize(60),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    globalDataStore.getResponsiveSize(15)),
                            margin: EdgeInsets.only(
                                bottom: globalDataStore.getResponsiveSize(15)),
                            child: _formBuilder
                                .callbackButton('Cancel', Colors.grey, () {
                              setState(() {
                                // needShowInfoEditingView = false;
                                Navigator.pop(context);
                              });
                            }))
                      ])
                    ],
                  ),
                )),
          ]),
        ),
      );
}

Widget amountRow(
    String name, TextEditingController? controller, Function(String) onChange) {
  return Container(
      height: globalDataStore.getResponsiveSize(48),
      padding: EdgeInsets.symmetric(
          horizontal: globalDataStore.getResponsiveSize(15),
          vertical: globalDataStore.getResponsiveSize(5)),
      decoration: BoxDecoration(
          border: BorderDirectional(
              bottom: BorderSide(color: Colors.black, width: 0.2))),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
                fontFamily: 'SFProText',
                fontSize: globalDataStore.getResponsiveSize(12),
                fontWeight: FontWeight.w500,
                letterSpacing: -0.15,
                color: Colors.black),
          ),
          Expanded(
              child: TextField(
            controller: controller,
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
            onChanged: onChange,
          )),
          Text('cm')
        ],
      ));
}

class PregnancyDailyRecord {
  PregnancyDailyRecord(
      {this.id = '',
      this.datetime = '',
      this.crl = 0,
      this.bpd = 0,
      this.hc = 0,
      this.fl = 0,
      this.ac = 0,
      this.photoPath = '',
      this.notes = '',
      this.userID = ''});
  final String id;
  final String datetime;
  late double crl;
  late double bpd;
  late double hc;
  late double fl;
  late double ac;
  late String notes;
  late String photoPath;
  final String userID;

  PregnancyDailyRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        datetime = json['datetime'],
        crl = json['crl'],
        bpd = json['bpd'],
        hc = json['hc'],
        fl = json['fl'],
        ac = json['ac'],
        notes = json['notes'],
        photoPath = json['photoPath'],
        userID = json['userID'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'datetime': datetime,
        'crl': crl,
        'bpd': bpd,
        'hc': hc,
        'fl': fl,
        'ac': ac,
        'photoPath': photoPath,
        'notes': notes,
        'userID': userID
      };
}
