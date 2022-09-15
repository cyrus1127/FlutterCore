import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/formInputField.dart';
import 'package:app_devbase_v1/component/formInputField_FW.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProfileEditing extends CommonStatefulWidget {
  const ProfileEditing({required Key? key, this.notBorn = false, this.record})
      : super(key: key);
  final bool notBorn;

  const ProfileEditing.eixit(this.record,
      {required Key? key, this.notBorn = false})
      : super(key: key);
  final ProfileData? record;

  @override
  _ProfileEditingState createState() => _ProfileEditingState();
}

class _ProfileEditingState extends State<ProfileEditing> {
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  final ProfileFormInputField _forUnitBuilder = ProfileFormInputField();
  final FormInputField _formBuilder = FormInputField();
  List<ProfileData> datas = [];
  List<String> bloodTypes = [
    'Type A',
    'Type B',
    'Type AB',
    'Type O',
  ];

  bool editable = true;
  bool isLoginFormNeed = false;
  bool isRegistrationFormNeed = false;
  bool needShowWelcomeAlert = false;
  bool needShowParentInfoView = false;
  double endAnimatedPosition = -40;
  String id = new Uuid().hashCode.toString();
  String name = ''; //'BB\'s Name';
  String nickName = ''; //'BB\'s NameNick';
  String birthDate = ''; //'BB\'s Birth date';
  String gender = 'Girl';
  String bloodType = ''; //'Which type';
  String parentKind = 'Mum / Dad';
  String parentKind_tmp = 'Mum'; //default select "Mum"
  String parentName = '';
  String parentName_tmp = '';
  String parentEmail = '';
  String coOwnParentEmail = '';
  String thumbnail = 'assets/images/profile_default.png';
  double bottomZoneSize() {
    return 0.35;
  }

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  bool isDisplayMode() {
    return widget.record != null && !editable;
  }

  List<BottomSheetAction> getBloodTypeLists() {
    List<BottomSheetAction> _n = [];
    for (var item in bloodTypes) {
      _n.add(BottomSheetAction(
          title: Text(item),
          onPressed: (context) {
            Navigator.pop(context);
            setState(() {
              bloodType = item;
            });
          }));
    }
    return _n;
  }

  void getData() async {}

  Widget? doShowEdit({bool isBirthday = false}) {
    List<String> _choices = ['Only me', 'Followers'];
    String _title = 'Audience is';
    String _contentCur = _choices[1];

    if (isBirthday) {
      _choices = ['Year, month & day'];
      _title = 'Display';
      _contentCur = _choices[0];
    }

    if (widget.record != null && editable) {
      return titleExtraLine(
        context,
        title: _title,
        contentCur: _contentCur,
        choices: _choices,
        onChanged: (strVal) {
          widget.showFunctionWillProvideSoon(context);
        },
      );
    }
    return null;
  }

  void saveFormData() async {
    if (widget.record != null) {
      //update record
      widget
          .setProfileDatas(new ProfileData(
              id: id,
              birthday: birthDate,
              name: name,
              nickName: nickName,
              gender: gender,
              parentKind: parentKind,
              parentName: parentName,
              parentNameCo: '',
              parentEmail: parentEmail,
              bloodType: bloodType,
              profilePic: thumbnail,
              borned: this.widget.notBorn ? 0 : 1))
          .then((saveDone) {
        if (saveDone) {
          widget.setSelectedProfile(id).then((saveIDDone) {
            if (saveIDDone) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', ModalRoute.withName('/welcome'));
            } else {
              print('Save profile failed');
            }
          });
        }
      });
    } else {
      //new record
      widget
          .setProfileDatas(new ProfileData(
              id: id,
              birthday: birthDate,
              name: name,
              nickName: nickName,
              gender: gender,
              parentKind: parentKind,
              parentName: parentName,
              parentNameCo: '',
              parentEmail: parentEmail,
              bloodType: bloodType,
              profilePic: thumbnail,
              borned: this.widget.notBorn ? 0 : 1))
          .then((saveDone) {
        if (saveDone) {
          widget.setSelectedProfile(id).then((saveIDDone) {
            if (saveIDDone) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', ModalRoute.withName('/welcome'));
            } else {
              print('Save profile failed');
            }
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.record != null) {
      id = widget.record!.id;
      name = widget.record!.name;
      nickName = widget.record!.nickName;
      birthDate = widget.record!.birthday;
      gender = widget.record!.gender;
      bloodType = widget.record!.bloodType;
      parentKind = widget.record!.parentKind;
      parentName = widget.record!.parentName;
      parentEmail = widget.record!.parentEmail;
      thumbnail = widget.record!.profilePic;
      editable = false;
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            // backgroundColor:
            //     Color.fromRGBO(0, 0, 0, 0.0), //HexColor("#F4F4F5"),
            // resizeToAvoidBottomInset: false,
            body: Stack(
          children: [
            //title bar
            Container(
                padding: EdgeInsets.only(
                    top: widget.getResponsivePositioning(topBarOffSet)),
                height: globalDataStore.getResponsiveSize(50 + topBarOffSet),
                decoration: BoxDecoration(color: Colors.white),
                child: Stack(
                  children: [
                    Container(
                        width: globalDataStore.getResponsiveSize(30),
                        margin: EdgeInsets.only(
                            left: globalDataStore.getResponsiveSize(15),
                            right: globalDataStore.getResponsiveSize(5)),
                        child: TextButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Image(
                              image: AssetImage(
                                  'assets/images/icon_arrow_left.png')),
                          style:
                              TextButton.styleFrom(padding: EdgeInsets.all(2)),
                        )),
                    Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child: Text(
                          (widget.record != null
                              ? 'Profile'
                              : 'Create Kid Profile'),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SFProText-Semibold',
                              fontStyle: FontStyle.normal,
                              fontSize: globalDataStore.getResponsiveSize(16),
                              color: Color.fromRGBO(13, 54, 88, 1))),
                    ),
                    if (widget.record != null) ...[
                      Positioned(
                        right: globalDataStore.getResponsiveSize(20),
                        top: 0,
                        bottom: 0,
                        child: Container(
                            width: globalDataStore.getResponsiveSize(24),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  editable = true;
                                });
                              },
                              child: Image(
                                  height: globalDataStore.getResponsiveSize(24),
                                  image:
                                      AssetImage('assets/images/fi_edit.png')),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(2)),
                            )),
                      )
                    ]
                  ],
                )),
            Container(
                margin: EdgeInsets.only(
                  top: globalDataStore.getResponsiveSize(50 + topBarOffSet),
                ),
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _forUnitBuilder.buildRowAccPicture(
                            'Create Profile Photo', thumbnail,
                            imageOnPress: () async {
                          PickedFile? pickedFile = await ImagePicker()
                              .getImage(source: ImageSource.gallery);

                          if (pickedFile != null) {
                            print('Pressed : ' + pickedFile.path);
                            setState(() {
                              //set the
                              thumbnail = pickedFile.path;
                            });
                          }
                        },
                            onDisplay: isDisplayMode(),
                            showHeaderOnEdit:
                                !(widget.record != null && editable)),

                        ///Case for 'not yet Born'
                        if (this.widget.notBorn) ...[
                          _forUnitBuilder
                              .buildRowTextField('Nickname', nickName, (value) {
                            setState(() {
                              nickName = value;
                            });
                          }, context,
                                  onDisplay: isDisplayMode(),
                                  optionExtraLineUnderTitle: doShowEdit()),
                          _forUnitBuilder.buildRowDateTimePicker(
                              'Due date',
                              birthDate,
                              context,
                              (dateStr) {
                                // print('$date');
                                setState(() {
                                  birthDate = dateStr;
                                });
                              },
                              onDisplay: isDisplayMode(),
                              showBornButton: (isDisplayMode() &&
                                  widget.record!.borned == 0),
                              bornButtonOnPress: () {
                                print('bornButtonOnPress');
                              }),
                        ] else ...[
                          ///Case for 'Born'
                          _forUnitBuilder.buildRowTextField('Kid\'s Name', name,
                              (value) {
                            setState(() {
                              name = value;
                            });
                          }, context,
                              onDisplay: isDisplayMode(),
                              optionExtraLineUnderTitle: doShowEdit()),
                          _forUnitBuilder
                              .buildRowTextField('Nickname', nickName, (value) {
                            setState(() {
                              nickName = value;
                            });
                          }, context, onDisplay: isDisplayMode()),
                          _forUnitBuilder.buildRowDateTimePicker(
                              'Birth Date', birthDate, context, (dateStr) {
                            // print('$date');
                            setState(() {
                              birthDate = dateStr;
                            });
                          },
                              onDisplay: isDisplayMode(),
                              optionExtraLineUnderTitle:
                                  doShowEdit(isBirthday: true)),
                          if (widget.record != null) ...[
                            //Zodiac
                            _forUnitBuilder.buildRowTextField('Zodiac',
                                widget.record!.zodiac(), (value) {}, context,
                                onDisplay: true),
                          ],
                          _forUnitBuilder.buildRowSwitch('Gender', 'Girl',
                              'Boy', gender.compareTo('Girl') == 0, (selected) {
                            setState(() {
                              gender = selected;
                            });
                          }, context,
                              onDisplay: isDisplayMode(),
                              optionExtraLineUnderTitle: doShowEdit()),
                          _forUnitBuilder.buildRowActionSheet('Blood Type',
                              bloodType, getBloodTypeLists(), context,
                              onDisplay: isDisplayMode(),
                              optionExtraLineUnderTitle: doShowEdit()),
                        ],
                        _forUnitBuilder.buildRowFullButton(
                            'I am Kid\'s $parentKind', parentName, () {
                          setState(() {
                            needShowParentInfoView = true;
                          });
                        }, context, onDisplay: isDisplayMode()),
                        _forUnitBuilder.buildRowTextField(
                            (parentKind.compareTo('Mum / Dad') == 0
                                ? 'Mum / Dad\'s Email'
                                : '$parentKind\'s email'),
                            parentEmail, (value) {
                          setState(() {
                            parentEmail = value;
                          });
                        }, context,
                            onDisplay: isDisplayMode(),
                            optionExtraLineUnderTitle: doShowEdit()),
                        _forUnitBuilder.buildInputWithButtonBlock(
                          'Invite Mum / Dad to Co-own Kid’s Profile',
                          (inputValue) {
                            coOwnParentEmail = inputValue;
                          },
                          () {},
                          context,
                          buttonTitle: 'Invite',
                          buttonColor: HexColor("#F1A387"),
                          inputFieldHint: 'Email',
                          needFieldCheck: true,
                        ),

                        /// Create new profile
                        if (widget.record != null) ...[
                          if (isDisplayMode())
                            ...[]
                          else ...[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 15, right: 15, top: 0, bottom: 20),
                              child: _formBuilder.callbackButton(
                                  'save', HexColor('#0F3657'), saveFormData),
                            )
                          ]
                        ] else ...[
                          Container(
                            margin: EdgeInsets.only(
                                left: 15, right: 15, top: 0, bottom: 20),
                            child: _formBuilder.callbackButton(
                                'Create', HexColor('#0F3657'), saveFormData),
                          )
                        ]
                      ],
                    ),
                  ],
                )),
            if (needShowWelcomeAlert) ...[
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                onEnd: () {
                  if (needShowWelcomeAlert) {
                    setState(() {
                      needShowWelcomeAlert = false;
                    });
                  }
                },
                top: endAnimatedPosition,
                child: widget.getInAppNotificationBlock(
                    'Yeah! You’re completed the sign up process. You can create your babies profile now.',
                    context),
              )
            ],

            //// ParentInfo block
            if (needShowParentInfoView) ...[
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.4,
                      ),
                    ),
                    child: Column(children: [
                      Spacer(),
                      Container(
                        height: globalDataStore.getResponsiveSize(326 + 20),
                        padding: EdgeInsets.only(
                            top: globalDataStore.getResponsiveSize(15)),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    globalDataStore.getResponsiveSize(16)),
                                topRight: Radius.circular(
                                    globalDataStore.getResponsiveSize(16)))),
                        child: Column(
                          children: [
                            //floating block title
                            Container(
                              height: globalDataStore.getResponsiveSize(20),
                              margin: EdgeInsets.only(
                                  left: globalDataStore
                                      .getResponsivePositioning(15),
                                  right: globalDataStore
                                      .getResponsivePositioning(15),
                                  bottom: globalDataStore.getResponsiveSize(5)),
                              padding: EdgeInsets.only(),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'I am Kid\'s',
                                  style: TextStyle(
                                      fontFamily: 'SFProText',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.15,
                                      fontSize: globalDataStore
                                          .getResponsiveSize(12)),
                                ),
                              ),
                            ),

                            //segment buttons
                            segment(MediaQuery.of(context).size.width, 35,
                                ['Mum', 'Dad'], parentKind_tmp, (strVal) {
                              setState(() {
                                parentKind_tmp = strVal;
                              });
                            }),

                            //Others
                            _forUnitBuilder.buildInputWithButtonBlock('',
                                (inputValue) {
                              parentName_tmp = inputValue;
                            }, () {
                              setState(() {
                                needShowParentInfoView = false;
                              });
                            }, context,
                                buttonColor: HexColor('#0F3657'),
                                inputFieldHint: 'Name',
                                buttonTitle: '',
                                cellHeight:
                                    globalDataStore.getResponsiveSize(80),
                                topMargin: 5),
                            Container(
                              width: double.maxFinite,
                              height: 1,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.1,
                                          color:
                                              Color.fromRGBO(0, 0, 0, 0.5)))),
                            ),
                            _forUnitBuilder.buildInputWithButtonBlock(
                                'My Email', (inputValue) {
                              parentEmail = inputValue;
                            }, () {
                              setState(() {
                                parentKind = parentKind_tmp;
                                parentName = parentName_tmp;
                                needShowParentInfoView = false;
                              });
                            }, context,
                                buttonColor: HexColor('#0F3657'),
                                inputFieldHint: 'Email',
                                cellHeight:
                                    globalDataStore.getResponsiveSize(145),
                                topMargin_header: 0),
                          ],
                        ),
                      )
                    ]),
                  ))
            ]
          ],
        )),
        onWillPop: () async {
          return false;
        });
  }
}

class ProfileData {
  const ProfileData(
      {this.id = '',
      this.age = -1,
      this.name = '',
      this.nickName = '',
      this.birthday = '',
      this.gender = '',
      this.bloodType = '',
      this.parentKind = '',
      this.parentName = '',
      this.parentNameCo = '',
      this.parentEmail = '',
      this.profilePic = '',
      this.borned = 1,
      this.followed = 0})
      : super();

  final String id;
  final int age;
  final String name;
  final String nickName;
  final String birthday;
  final String gender;
  final String bloodType;
  final String parentKind;
  final String parentName;
  final String parentNameCo;
  final String parentEmail;
  final String profilePic;
  final int borned;
  final int followed;

  ProfileData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        age = json['age'],
        name = json['name'],
        nickName = json['nickName'],
        birthday = json['birthday'],
        gender = json['gender'],
        bloodType = json['bloodType'],
        parentKind = json['parentKind'],
        parentEmail = json['parentEmail'],
        parentName = json['parentName'],
        parentNameCo = json['parentNameCo'],
        profilePic = json['profilePic'],
        borned = json['borned'],
        followed = json['followed'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'age': age,
        'name': name,
        'nickName': nickName,
        'birthday': birthday,
        'gender': gender,
        'bloodType': bloodType,
        'parentKind': parentKind,
        'parentName': parentName,
        'parentNameCo': parentNameCo,
        'parentEmail': parentEmail,
        'profilePic': profilePic,
        'borned': borned,
        'followed': followed
      };

  int yearsOfAge() {
    return 0;
  }

  int monthsOfAge() {
    return 0;
  }

  int daysOfAge() {
    int days = -1;
    try {
      DateTime birthDate = DateTime.parse(this.birthday);
      days = DateTime.now().difference(birthDate).inDays;
    } catch (error) {
      days = 0;
      print('error');
    }
    return days;
  }

  String daysStrOfAge({bool withSpacing = false}) {
    int totalDays = daysOfAge();
    int days = totalDays % 30;
    int month = ((totalDays / 30) % 12).toInt();
    // ignore: division_optimization
    int year = (totalDays / 356).toInt();

    if (borned == 0) {
      int week = 41 + totalDays ~/ 7;
      days = totalDays % 7;
      return '$week\w$days\d';
    }

    if (withSpacing) {
      return '$year\Y $month\M $days\d';
    }
    return '$year\Y$month\M$days\d';
  }

  String formatedDateOfBirth() {
    DateTime birthDate = DateTime.parse(this.birthday);
    String formated = DateFormat.yMMMd().format(birthDate);
    String dayAge = daysStrOfAge();

    return '$formated ($dayAge)';
  }

  int calculateAge() {
    DateTime birthDate = DateTime.parse(this.birthday);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  int calculateWeekForPregnancyStage(DateTime currentDate) {
    int weeks = 0;
    final int week_max = 41; // this is total week in pregnancy stage
    if (borned == 0) {
      DateTime birthDate = DateTime.parse(this.birthday);
      if (currentDate.isBefore(birthDate)) {
        Duration diff = birthDate.difference(currentDate);
        int week_cal = diff.inDays ~/ 7;

        if (week_cal <= week_max && week_cal >= 0) {
          weeks = week_max - week_cal;
        }
      }
    }

    return weeks;
  }

  Color colorOfGender() {
    if (borned == 0) return Color.fromRGBO(241, 163, 135, 1);

    return gender.compareTo('Girl') == 0
        ? Color.fromRGBO(240, 114, 126, 1)
        : Color.fromRGBO(48, 189, 187, 1);
  }

  String zodiac() {
    List<String> zodiacs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces'
    ];
    DateTime birthDate = DateTime.parse(this.birthday);
    return zodiacs[birthDate.month - 1];
  }
}
