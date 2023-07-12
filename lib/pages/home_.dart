import 'dart:io';
import 'dart:ui';

import 'package:app_devbase_v1/component/chartViews.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/dataObjects/notification.dart';
import 'package:app_devbase_v1/component/dataObjects/pregnancy.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/dailyRecordCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/postDetail.dart';
import 'package:app_devbase_v1/pages/afterLogin/pregnancyRecordCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profilePushView.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/homeDailySection.dart';
import 'package:app_devbase_v1/pages/beforeLogin/profiles.dart';

import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';

import 'afterLogin/widgets/homeUserInfoSection.dart';

class Home extends CommonStatefulWidget {
  const Home({required Key? key}) : super(key: key);

  // @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double tapBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 34 : 10) : 10);
  double tapBarHeight = 58;
  double tapBarPadding = 10;
  bool tapBarOnShow = true;
  double inputFieldHeight = 80;
  double inputFieldpadding = 10;
  double dailyMonthBarHeight = 45;
  double dailyTypeBarHeight = 44;
  double dailyFloatingButtonSize = 80;
  double chartAmountAxieLabelOffset = 16;
  double chartAmountAxieLabelHeight = 25;
  double chatMonthBarHeight = 45;
  double chatTypeBarHeight = 44;
  double chatModeSwitchBarHeight = 34;
  double profileShortDetailFieldHeight = 180;
  bool needShowProfileListView = false;
  double profileListViewHeight = 530;

  ScrollController mainContentListController = ScrollController();

  ProfileData myData = ProfileData();
  List<ProfileData> profiledatas = [];
  List<Map<String, ProfileData>> dataConSolid = [];

  DateTime curDailyDate = DateTime.now();
  DateTime curChatDate = DateTime.now();
  int curSectionIdx = 0;

  int onSelectedIndex = 0;
  List<String> filters = [
    'All',
    'Nurse',
    'Pumping',
    'Pumping / Formula Feed',
    'Solids Food',
    'Sleep',
    'Wake',
    'Pee',
    'Poop',
    'Both pee & poop',
    'Bath',
    'Temperature',
    'Height',
    'Weight',
  ];
  int onSelectedChartIndex = 0;
  List<String> filtersChart = [
    'Nurse',
    'Pumping',
    'Pumping / Formula Feed',
    'Solids Food',
    'Sleep', // grouped with [Sleep, Wake ]
    'Pee/Poop', // grouped with [Pee, Poopm Both pee & poop]
    'Bath',
    'Height',
    'Weight',
  ];
  List<String> filtersChartNotBore = [
    'Crown-rump Length',
    'Biparietal Diameter',
    'Head Circumference',
    'Femer Length',
    'Abdominal Circumference',
  ];

  String onSelectedChartMode = 'Time';
  List<String> chartMode = [
    'Time',
    'Amount',
  ];

  List<PostData> postRecords = [];
  List<PostData> postRecordsFiltered = [];

  List<DailyRecord> records = [];
  List<DailyRecord> recordsFiltered = [];
  List<ChildChartGuid> childChartGuids = [];

  List<PregnancyGuid> pregnancyGuids = [];
  List<PregnancyChartGuid> pregnancyChartGuids = [];
  List<PregnancyDailyRecord> pregnancyRecords = [];
  List<PregnancyDailyRecord> pregnancyRecordsFiltered = [];

  List<AppPushInfo> appPushList = [];

  void updateFilteringRecords() {
    ///Do filtering
    if (curSectionIdx == 1 || curSectionIdx == 2) {
      recordsFiltered.clear();
      records.forEach((record) {
        if (record.datetime != 'null') {
          DateTime rdt = DateTime.parse(record.datetime);

          if (curSectionIdx == 1) {
            //daily
            if (record.activityType + 1 == onSelectedIndex ||
                onSelectedIndex == 0) {
              if (curDailyDate.year == rdt.year &&
                  curDailyDate.month == rdt.month &&
                  curDailyDate.day == rdt.day) {
                recordsFiltered.add(record);
              }
            }
          } else {
            //chart
            int minR = onSelectedChartIndex, maxR = onSelectedChartIndex;
            switch (onSelectedChartIndex) {
              case 4: //sleep/wake
                minR = 4;
                maxR = 5; //do group a range of records
                break;
              case 5:
                minR = 6;
                maxR = 8; //do group a range of records
                break;
              case 6:
                minR = maxR = onSelectedChartIndex + 3; //shift to 3 as case 5
                break;
              case 7:
              case 8:
                minR = maxR =
                    onSelectedChartIndex + 4; //skip tempiture so shift to 4
                break;
            }
            if (record.activityType >= minR && record.activityType <= maxR) {
              if (onSelectedChartIndex < 7) {
                Duration diff = rdt.difference(curChatDate);
                if (diff.inDays >= 0 && diff.inDays <= 6) {
                  recordsFiltered.add(record);
                }
              } else if (recordsFiltered.length < 7) {
                recordsFiltered.add(record);
              }
            }
          }
        } else {
          //do nothing
        }
      });
    }
  }

  void updateSelectedDateOfPregnancyRecord() {
    pregnancyRecordsFiltered.clear();
    pregnancyRecords.forEach((element) {
      DateTime eleDT = DateTime.parse(element.datetime);
      //Check and get the today only
      if (eleDT.day == curDailyDate.day &&
          eleDT.difference(curDailyDate).inDays == 0) {
        pregnancyRecordsFiltered.add(element);
      }
    });
  }

  void sectionChange(int sectionTo) {
    curSectionIdx = sectionTo;
    refreshFilters();
  }

  void refreshFilters() {
    if (curSectionIdx == 1 && myData.borned == 0) {
      updateSelectedDateOfPregnancyRecord();
    } else {
      updateFilteringRecords();
    }
  }

  void changeDailyDate(bool shiftBack) {
    if (shiftBack) {
      curDailyDate = curDailyDate.subtract(const Duration(days: 1));
    } else {
      curDailyDate = curDailyDate.add(const Duration(days: 1));
    }

    setState(() {
      refreshFilters();
    });
  }

  void changeChatDateRange(bool shiftBack) {
    if (onSelectedChartIndex >= 7) {
      //TODO : change the dataRange
    } else {
      int offset = curChatDate.timeZoneOffset.inHours;
      if (shiftBack) {
        curChatDate = curChatDate.subtract(Duration(days: 7, hours: offset));
      } else {
        curChatDate = curChatDate.add(Duration(days: 7, hours: offset));
      }
    }

    setState(() {
      refreshFilters();
    });
  }

  void changeFilter(int filterTo) {
    if (curSectionIdx == 1) {
      onSelectedIndex = filterTo;
      // String filteringKey = filters[filterTo];
      // print('Filter by : $filteringKey');
    } else {
      onSelectedChartIndex = filterTo;

      String filteringKey = (myData.borned == 1
          ? filtersChart[filterTo]
          : filtersChartNotBore[filterTo]);

      print('Filter by : $filteringKey');
    }

    if (!isChartModeNeedShow()) {
      onSelectedChartMode = chartMode.first;
    }

    setState(() {
      refreshFilters();
    });
  }

  void changeChartMode(String modeTo) {
    onSelectedChartMode = modeTo;
    setState(() {
      refreshFilters();
    });
  }

  bool isChartModeNeedShow() {
    if (myData.borned == 1 && onSelectedChartIndex <= 4) {
      return true;
    }
    return false;
  }

  String getChartUnit() {
    if (chartMode.indexOf(onSelectedChartMode) == 0) {
      if (onSelectedChartIndex == 7) {
        // height
        return 'cm';
      } else if (onSelectedChartIndex == 8) {
        // weight
        return 'kg';
      }
      return 'hr';
    } else {
      if (onSelectedChartIndex >= 4 && onSelectedChartIndex <= 5 ||
          onSelectedChartIndex == 9) {
        return 'hr';
      }
    }
    return DailyRecord.getTypeUnit(onSelectedChartIndex);
  }

  double getChartMaxY() {
    if (onSelectedChartIndex >= 4 && onSelectedChartIndex <= 5 ||
        onSelectedChartIndex == 9) {
      return 24;
    }
    return 600;
  }

  String getChatDateRangeBarText() {
    if (onSelectedChartIndex >= 7) {
      return 'Last 7 Times Record';
    }

    DateTime rangeEnd = curChatDate.add(const Duration(days: 6));
    return DateFormat.yMMMd().format(curChatDate) +
        ' - ' +
        DateFormat.yMMMd().format(rangeEnd);
  }

  void pushPostCreatingView() {
    Navigator.pushNamed(context, '/postCreate');
  }

  Future<T?> pushCreateRecordView<T extends Object?>({DailyRecord? inRecord}) {
    if (inRecord != null) {
      return Navigator.push(
          context,
          PageTransition(
              child: DailyRecordCreate.onEdit(myData,
                  key: new Key(new Uuid().toString()), record: inRecord),
              type: PageTransitionType.bottomToTop));
    }

    return Navigator.push(
        context,
        PageTransition(
            child:
                DailyRecordCreate(myData, key: new Key(new Uuid().toString())),
            type: PageTransitionType.bottomToTop));
  }

  Future<T?> pushCreatePregnancyRecord<T extends Object?>(
      {PregnancyDailyRecord? inRecord}) {
    print('add Pregnancy record');

    if (inRecord != null) {
      return Navigator.push(
          context,
          PageTransition(
              child: PregnancyRecordCreate.onEdit(myData,
                  key: new Key(new Uuid().toString()), record: inRecord),
              type: PageTransitionType.bottomToTop));
    }

    return Navigator.push(
        context,
        PageTransition(
            child: PregnancyRecordCreate(
              myData,
              key: new Key(new Uuid().toString()),
              recordDate: curDailyDate,
            ),
            type: PageTransitionType.bottomToTop));
  }

  void createWakeDailyRecord(DailyRecord sleepRecord) async {
    ///Solution - 2
    Navigator.push(
        context,
        PageTransition(
            child: DailyRecordCreate.makeAwake(myData,
                key: new Key(new Uuid().toString()), record: sleepRecord),
            type: PageTransitionType.bottomToTop));
  }

  _scrollListener() {
    if (mainContentListController.offset >
            MediaQuery.of(context).size.height / 3 &&
        tapBarOnShow) {
      tapBarOnShow = false;
      setState(() {});
    } else if (mainContentListController.offset < 10 && !tapBarOnShow) {
      tapBarOnShow = true;
      setState(() {});
    }
  }

  List<String>? getSegmentOptions() {
    return ['Time', 'Amount'];
  }

  double getChartHeight() {
    return MediaQuery.of(context).size.height -
        globalDataStore.getResponsiveSize((topBarHeight + topBarOffSet) +
            (tapBarHeight + (tapBarPadding * 2) + tapBarOffSet) +
            (chatMonthBarHeight +
                (isChartModeNeedShow() ? chatTypeBarHeight : 0) +
                chatModeSwitchBarHeight) +
            chartAmountAxieLabelHeight);
  }

/*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/

  void loadDailyRecords() async {
    if (childChartGuids.length == 0) {
      childChartGuids =
          await widget.getChildChartGuidDatas(myData.gender == 'Girl');
    }

    records.clear();
    await widget.getDailyDatas().then((value) {
      value!.forEach((element) {
        if (element.userID.compareTo(myData.id) == 0) {
          records.add(element);
        }
      });

      setState(() {
        refreshFilters();
      });
    });
  }

  void loadPregnancyRecords() async {
    pregnancyRecords.clear();
    pregnancyRecordsFiltered.clear();
    await widget.getPregnancyDatas().then((value) {
      value!.forEach((element) {
        if (element.userID.compareTo(myData.id) == 0) {
          pregnancyRecords.add(element);
        }
      });

      setState(() {
        refreshFilters();
      });
    });
  }

  void loadPostRecords() async {
    postRecords.clear();
    await widget.getPostDatas().then((value) {
      value!.forEach((element) {
        postRecords.add(element);

        if (element.postOwnerID.compareTo(myData.id) == 0) {
          postRecordsFiltered.add(element);
        }
      });
      setState(() {});
    });
  }

  void loadAppPushrecords() {
    //this for demo
    if (appPushList.length < 2) {
      List<List<String>> demoContent = [
        [
          AppPushInfo.types[0],
          'Blook in app news/ baby care informations/ recommendation'
        ],
        [AppPushInfo.types[1], 'Somebody started following you.'],
        [AppPushInfo.types[2], 'Somebody started following you.'],
        [AppPushInfo.types[3], 'Somebody requested to follow you. '],
        [
          AppPushInfo.types[4],
          'Welcome somebody, we are really excited that you are arrived safe and sound!'
        ],
        [AppPushInfo.types[5], 'Somebody added 6 news photos.'],
        [
          AppPushInfo.types[5],
          'Somebody likes your comment: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...'
        ],
        [
          AppPushInfo.types[5],
          'Somebody, Somebody, Somebody and 32 others liked your post.'
        ],
      ];

      for (int i = 0; i < demoContent.length; i++) {
        DateTime demoPostTime =
            DateTime.now().toUtc().add(Duration(minutes: i));
        appPushList.add(AppPushInfo(
            id: new Uuid().toString(),
            postDatetime: demoPostTime.toString(),
            type: demoContent[i].first,
            content: demoContent[i].last));
      }

      //TODO : Send local push?

    }
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileID = prefs.getString('selectedProfile') ?? '';
    profiledatas.clear();
    await widget.getProfileDatas().then((value) {
      value!.forEach((element) {
        profiledatas.add(element);
      });

      Future.forEach(profiledatas, (element) {
        var data = element as ProfileData;
        print('stored profile : $data ??' + data.id + ' , ' + data.name);
        if (data.id.compareTo(profileID) == 0) {
          myData = data;
        }
      });

      datasConsolidated();
    });

    localRecordNeedUpdate();
  }

  void loadPregnacyDatas() async {
    if (pregnancyGuids.length == 0) {
      pregnancyGuids = await widget.getPregnancyGuideDatas();
    }

    if (pregnancyChartGuids.length == 0) {
      pregnancyChartGuids = await widget.getPregnancyChartGuideDatas();
    }
  }

  void localRecordNeedUpdate() async {
    loadPostRecords();
    loadAppPushrecords();
    if (myData.borned == 1) {
      loadDailyRecords();
    } else {
      loadPregnacyDatas();
      loadPregnancyRecords();
    }
  }

  void datasConsolidated() {
    if (dataConSolid.isNotEmpty) {
      dataConSolid.clear();
    }

    //set 2 cell in row
    for (var index = 0; index < profiledatas.length; index++) {
      if ((index == 0 || index % 2 == 0) && index < profiledatas.length) {
        if (index + 1 < profiledatas.length) {
          //case have 2 cell with datas
          dataConSolid.add({
            'data1': profiledatas[index],
            'data2': profiledatas[index + 1],
          });
        } else {
          //case have 2 cell with only single data info
          dataConSolid.add(
              {'data1': profiledatas[index], 'data2': const ProfileData()});
        }
      }
    }

    if (profiledatas.length % 2 == 0) {
      //do add the create profile
      dataConSolid.add({'data1': const ProfileData()});
    }
  }

  void changeProfile() {
    loadUserData();
  }

  @override
  void initState() {
    super.initState();
    changeProfile();
    globalDataStore.changeNotifier.addListener(changeProfile);
    globalDataStore.changeNotifier.addListener(localRecordNeedUpdate);
    mainContentListController.addListener(_scrollListener);

    /// Init curChatDate
    {
      DateTime nowDT =
          DateTime.parse(DateTime.now().toUtc().toString().split(' ').first);
      int curWeek = nowDT.weekday;
      curDailyDate = nowDT;
      if (myData.borned == 1) {
        curChatDate = nowDT.subtract(
            Duration(days: curWeek, hours: nowDT.timeZoneOffset.inHours));
      } else {
        DateTime endur = DateTime.parse(myData.birthday);
        curChatDate = endur.subtract(Duration(
            days: endur.day - (32 * 7),
            hours: nowDT.timeZoneOffset.inHours)); //wk9
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    globalDataStore.changeNotifier.removeListener(changeProfile);
    globalDataStore.changeNotifier.removeListener(localRecordNeedUpdate);
    mainContentListController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(232, 235, 237, 1),
        body: Stack(
          children: [
            //Topbar
            if (curSectionIdx == 0 || curSectionIdx == 3) ...[
              Positioned(
                  top: 0,
                  child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      height: globalDataStore
                          .getResponsiveSize(topBarHeight + topBarOffSet),
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(topBarOffSet)),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                                globalDataStore.getResponsiveSize(8)),
                            child: Image(
                              image: AssetImage('assets/images/blook_logo.png'),
                            ),
                          ),
                          Spacer(),
                          Container(
                              width: globalDataStore.getResponsiveSize(24),
                              margin: EdgeInsets.only(
                                  right: globalDataStore.getResponsiveSize(20)),
                              child: tapButtonWidget(() {
                                print('export page call');
                                Navigator.pushNamed(context, '/exploreUsers');
                              }, 'assets/images/icon_explore_fd.png')),
                          Container(
                              width: globalDataStore.getResponsiveSize(24),
                              margin: EdgeInsets.only(
                                  right: globalDataStore.getResponsiveSize(20)),
                              child: tapButtonWidget(() {
                                print('DM page call');
                                Navigator.pushNamed(
                                    context, '/directMessageUserList');
                              }, 'assets/images/icon_message.png')),
                          // Container(
                          //     width: globalDataStore.getResponsiveSize(50),
                          //     child: tapButtonWidget(
                          //         () {}, 'assets/images/icon_search.png')),
                        ],
                      ))),
            ] else if (curSectionIdx == 2) ...[
              Positioned(
                  top: 0,
                  child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      height: globalDataStore
                          .getResponsiveSize(topBarHeight + topBarOffSet),
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(topBarOffSet)),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: globalDataStore.getResponsiveSize(20)),
                            child: Text(
                              'Insight',
                              style: TextStyle(
                                  fontSize:
                                      globalDataStore.getResponsiveSize(30),
                                  fontFamily: 'SFProText-Bold',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.24),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ))),
            ] else ...[
              Positioned(
                  top: 0,
                  child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      height: globalDataStore
                          .getResponsiveSize(topBarHeight + topBarOffSet),
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(topBarOffSet)),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: globalDataStore.getResponsiveSize(20)),
                            child: Text(
                              myData.nickName,
                              style: TextStyle(
                                  fontSize:
                                      globalDataStore.getResponsiveSize(30),
                                  fontFamily: 'SFProText-Bold',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.24),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          if (myData.borned == 1) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      globalDataStore.getResponsiveSize(4)),
                              child: Image(
                                height: globalDataStore.getResponsiveSize(30),
                                image: AssetImage('assets/images/icon_' +
                                    myData.gender.toLowerCase() +
                                    '.png'),
                              ),
                            ),
                          ] else ...[
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        globalDataStore.getResponsiveSize(4)),
                                margin: EdgeInsets.only(
                                    left:
                                        globalDataStore.getResponsiveSize(10)),
                                child: Text(
                                  'is on the way',
                                  style: TextStyle(
                                      color: myData.colorOfGender(),
                                      fontSize:
                                          globalDataStore.getResponsiveSize(16),
                                      fontFamily: 'SF Pro',
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.33),
                                )),
                          ],

                          //Self-Profile
                          if (curSectionIdx == 4) ...[
                            Container(
                                width: globalDataStore.getResponsiveSize(30),
                                margin: EdgeInsets.only(
                                    left: globalDataStore.getResponsiveSize(0),
                                    right:
                                        globalDataStore.getResponsiveSize(5)),
                                child: TextButton(
                                  onPressed: () {
                                    //TODO : Call up the profiles selection panel
                                    setState(() {
                                      needShowProfileListView = true;
                                    });
                                  },
                                  child: Image(
                                      height:
                                          globalDataStore.getResponsiveSize(24),
                                      image: AssetImage(
                                          'assets/images/u_angle-down.png')),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: globalDataStore
                                              .getResponsiveSize(2))),
                                )),
                          ],
                          Spacer(),

                          //Self-Profile
                          if (curSectionIdx == 4) ...[
                            Container(
                                width: globalDataStore.getResponsiveSize(24),
                                margin: EdgeInsets.only(
                                    right:
                                        globalDataStore.getResponsiveSize(20)),
                                child: tapButtonWidget(
                                    () {}, 'assets/images/icon_menu.png')),
                          ] else ...[
                            if (myData.borned == 0) ...[
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                        globalDataStore.getResponsiveSize(10)),
                                child: Text(
                                  myData.daysStrOfAge(),
                                  style: TextStyle(
                                      color: Color.fromRGBO(241, 163, 135, 1),
                                      fontSize:
                                          globalDataStore.getResponsiveSize(16),
                                      fontFamily: 'SFProText',
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Container(
                                  width: globalDataStore.getResponsiveSize(24),
                                  margin: EdgeInsets.only(
                                      right: globalDataStore
                                          .getResponsiveSize(20)),
                                  child: tapButtonWidget(() {
                                    // print('DM page call');
                                    // Navigator.pushNamed(
                                    //     context, '/directMessageUserList');
                                  }, 'assets/images/u_calendar-alt.png')),
                            ] else ...[
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                        globalDataStore.getResponsiveSize(20)),
                                child: Text(
                                  myData.daysStrOfAge(),
                                  style: TextStyle(
                                      color: myData.colorOfGender(),
                                      fontSize:
                                          globalDataStore.getResponsiveSize(16),
                                      fontFamily: 'SFProText',
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ]
                          ]
                        ],
                      ))),
            ],

            //All Posts
            if (curSectionIdx == 0) ...[
              Positioned(
                  top: widget
                      .getResponsivePositioning((topBarHeight + topBarOffSet)),
                  child: createNewPostBlock(
                      MediaQuery.of(context).size.width,
                      globalDataStore.getResponsiveSize(inputFieldHeight),
                      globalDataStore.getResponsiveSize(inputFieldpadding),
                      myData,
                      pushPostCreatingView)),
              //Content
              Positioned(
                  top: widget.getResponsivePositioning(
                      (topBarHeight + topBarOffSet + inputFieldHeight)),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore.getResponsiveSize(
                            (topBarHeight + topBarOffSet) + inputFieldHeight),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: HexColor('#F4F4F5')),
                    child: ListView(
                      controller: mainContentListController,
                      padding: EdgeInsets.only(top: 0),
                      children: List.generate(postRecords.length, (index) {
                        return postBlock(
                          postRecords[index],
                          globalDataStore.getResponsiveSize(10),
                          MediaQuery.of(context).size.width,
                          (postData) {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: PostDetail(postData,
                                        key: new Key(new Uuid().toString())),
                                    type: PageTransitionType.rightToLeft));
                          },
                          (postData) {
                            widget.pushImageZoomingView(
                                postData.postMediaLink, context);
                          },
                        );
                      }),
                    ),
                  )),
            ],
            //Daily
            if (curSectionIdx == 1) ...[
              Positioned(
                  top: widget
                      .getResponsivePositioning((topBarHeight + topBarOffSet)),
                  child: dateTimeSwitchBar(
                      MediaQuery.of(context).size.width,
                      globalDataStore.getResponsiveSize(dailyMonthBarHeight),
                      globalDataStore.getResponsiveSize(16),
                      globalDataStore.getCustomFormatDateTime(curDailyDate),
                      () {
                    changeDailyDate(true);
                  }, () {
                    changeDailyDate(false);
                  })),
              if (myData.borned == 1) ...[
                Positioned(
                    top: widget.getResponsivePositioning(
                        (topBarHeight + topBarOffSet + dailyMonthBarHeight)),
                    child: filterSwitchBar(
                        MediaQuery.of(context).size.width,
                        globalDataStore.getResponsiveSize(dailyTypeBarHeight),
                        globalDataStore.getResponsiveSize(14),
                        filters,
                        onSelectedIndex,
                        changeFilter)),
                Positioned(
                    top: widget.getResponsivePositioning((topBarHeight +
                        topBarOffSet +
                        dailyMonthBarHeight +
                        dailyTypeBarHeight)),
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          globalDataStore.getResponsiveSize(
                              (topBarHeight + topBarOffSet) +
                                  (tapBarHeight + tapBarOffSet) +
                                  (dailyMonthBarHeight + dailyTypeBarHeight)),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: HexColor('#F4F4F5')),
                      child: (recordsFiltered.length > 0)
                          ? ListView(
                              controller: mainContentListController,
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      globalDataStore.getResponsiveSize(10)),
                              children: List.generate(
                                  recordsFiltered.length + 1, (index) {
                                if (index == recordsFiltered.length) {
                                  return createDailyRecordButton(
                                      pushCreateRecordView);
                                }
                                return dailyRecordBlock(recordsFiltered[index],
                                    globalDataStore.getResponsiveSize(15),
                                    (dailyData) {
                                  pushCreateRecordView(inRecord: dailyData);
                                }, createWakeDailyRecord);
                              }),
                            )
                          : noRecordColume(pushCreateRecordView),
                    )),
              ] else ...[
                ////TODO : for not yet born
                Positioned(
                  top: widget.getResponsivePositioning(
                      (topBarHeight + topBarOffSet + dailyMonthBarHeight)),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore.getResponsiveSize(
                            (topBarHeight + topBarOffSet) +
                                dailyMonthBarHeight),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(20)),
                    // decoration: BoxDecoration(color: Colors.amber),
                    child: (myData
                                .calculateWeekForPregnancyStage(curDailyDate) >=
                            2)
                        ? notBornDailyRecordGuideLine(
                            pregnancyGuids,
                            pregnancyRecordsFiltered,
                            pushCreatePregnancyRecord, () {
                            pushCreatePregnancyRecord(
                                inRecord: pregnancyRecordsFiltered.first);
                          }, () {
                            widget.showFunctionWillProvideSoon(context);
                          }, (strVal) {
                            widget.pushImageZoomingView(strVal, context);
                          }, mainContentListController,
                            weeks: myData
                                .calculateWeekForPregnancyStage(curDailyDate),
                            bottomOffset: (tapBarOffSet + 10))
                        : Column(
                            //No record view
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: globalDataStore
                                        .getResponsiveSize(111.41)),
                                child: Image(
                                    height: globalDataStore
                                        .getResponsiveSize(74.59),
                                    image: AssetImage(
                                        'assets/images/blook_logo.png')),
                              ),
                              Image(
                                  height: globalDataStore.getResponsiveSize(40),
                                  image: AssetImage(
                                      'assets/images/icon_noRecord_kid.png')),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: globalDataStore
                                          .getResponsiveSize(15)),
                                  child: Text(
                                    'Welcome to the start of pregnancy journey',
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 54, 88, 1),
                                        fontFamily: 'SFProText',
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w600,
                                        fontSize: globalDataStore
                                            .getResponsiveSize(16)),
                                  )),
                              Container(
                                  margin: EdgeInsets.only(
                                      bottom: globalDataStore
                                          .getResponsiveSize(30)),
                                  child: Text(
                                    'Before week 2, you aren\'t technically pregnant yet,\nbut it\'s an important time of preparation. ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                        fontFamily: 'SFProText',
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w600,
                                        fontSize: globalDataStore
                                            .getResponsiveSize(12)),
                                  )),
                            ],
                          ),
                  ),
                ),
              ],
            ],
            //Chat
            if (curSectionIdx == 2) ...[
              if (myData.borned == 1) ...[
                //Chart date range bar
                Positioned(
                    top: widget.getResponsivePositioning(
                        (topBarHeight + topBarOffSet)),
                    child: dateTimeSwitchBar(
                        MediaQuery.of(context).size.width,
                        globalDataStore.getResponsiveSize(chatMonthBarHeight),
                        globalDataStore.getResponsiveSize(16),
                        getChatDateRangeBarText(), () {
                      changeChatDateRange(true);
                    }, () {
                      changeChatDateRange(false);
                    })),
                //Types filter bar
                Positioned(
                    top: widget.getResponsivePositioning(
                        (topBarHeight + topBarOffSet + chatMonthBarHeight)),
                    child: filterSwitchBar(
                        MediaQuery.of(context).size.width,
                        globalDataStore.getResponsiveSize(chatTypeBarHeight),
                        globalDataStore.getResponsiveSize(14),
                        filtersChart,
                        onSelectedChartIndex,
                        changeFilter)),
                //Segment
                if (isChartModeNeedShow()) ...[
                  Positioned(
                      top: widget.getResponsivePositioning((topBarHeight +
                          topBarOffSet +
                          chatMonthBarHeight +
                          chatTypeBarHeight)),
                      child: segment(
                          MediaQuery.of(context).size.width,
                          chatModeSwitchBarHeight,
                          chartMode,
                          onSelectedChartMode, (strVal) {
                        changeChartMode(strVal);
                      }, backgroundColor: Colors.white)),
                ],

                //Chart BG
                Positioned(
                    top: widget.getResponsivePositioning((topBarHeight +
                        topBarOffSet +
                        chatMonthBarHeight +
                        (isChartModeNeedShow() ? chatTypeBarHeight : 0) +
                        (chatModeSwitchBarHeight + chartAmountAxieLabelOffset) +
                        chartAmountAxieLabelHeight)),
                    child: Container(
                      // decoration: BoxDecoration(color: Colors.blue),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          left: globalDataStore.getResponsiveSize(45),
                          right: globalDataStore.getResponsiveSize(40),
                          top: globalDataStore.getResponsiveSize(10)),
                      child: Stack(
                        children: [
                          Column(
                            children: List.generate(24, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: (index % 2 == 0
                                        ? Colors.white
                                        : Color.fromRGBO(250, 250, 250, 1))),
                                height: getChartHeight() / 26.1,
                                // child: Row(
                                //   children: List.generate(6, (index) {
                                //     return Container(
                                //       margin: index == 0
                                //           ? EdgeInsets.only(left: 20)
                                //           : EdgeInsets.zero,
                                //       width: (MediaQuery.of(context).size.width -
                                //               globalDataStore.getResponsiveSize(
                                //                   45 + 20 + 40)) /
                                //           7,
                                //       height: double.maxFinite,
                                //       decoration: BoxDecoration(
                                //           border: Border(right: BorderSide())),
                                //     );
                                //   }),
                                // ),
                              );
                            }),
                          )
                        ],
                      ),
                    )),
                //Chart
                Positioned(
                  top: widget.getResponsivePositioning((topBarHeight +
                      topBarOffSet +
                      chatMonthBarHeight +
                      (isChartModeNeedShow() ? chatTypeBarHeight : 0) +
                      (chatModeSwitchBarHeight - chartAmountAxieLabelOffset) +
                      30)),
                  left: 0,
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Container(
                          height: globalDataStore
                              .getResponsiveSize(chartAmountAxieLabelHeight),
                          width: globalDataStore.getResponsiveSize(40),
                          alignment: Alignment.bottomRight,
                          child: Text(
                            getChartUnit(),
                            style: TextStyle(
                                fontSize: globalDataStore.getResponsiveSize(11),
                                fontFamily: 'SFProText',
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(0, 0, 0, 1),
                                letterSpacing: -0.1),
                          ),
                        ),
                        Container(
                          height: getChartHeight(),
                          width: MediaQuery.of(context).size.width -
                              globalDataStore
                                  .getResponsiveSize(50), //horiz + right
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  globalDataStore.getResponsiveSize(15)),
                          padding: EdgeInsets.only(
                              right: globalDataStore.getResponsiveSize(5),
                              top: globalDataStore.getResponsiveSize(10)),
                          // decoration: BoxDecoration(color: Colors.white),
                          child: chartMode.indexOf(onSelectedChartMode) == 0
                              ? (onSelectedChartIndex < 7
                                  ? timeChartSpotStyle(
                                      recordsFiltered, curChatDate)
                                  : childWHLineChart(childChartGuids,
                                      recordsFiltered, onSelectedChartIndex))
                              : amountBarChart(recordsFiltered, curChatDate,
                                  getChartMaxY(), getChartUnit()),
                        ),
                      ])),
                ),
              ] else ...[
                //Types filter bar
                Positioned(
                    top: widget.getResponsivePositioning(
                        (topBarHeight + topBarOffSet)),
                    child: filterSwitchBar(
                        MediaQuery.of(context).size.width,
                        globalDataStore.getResponsiveSize(chatTypeBarHeight),
                        globalDataStore.getResponsiveSize(14),
                        filtersChartNotBore,
                        onSelectedChartIndex,
                        changeFilter)),
                //Filtering
                Positioned(
                  top: widget.getResponsivePositioning(
                      (topBarHeight + topBarOffSet + chatTypeBarHeight)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: globalDataStore.getResponsiveSize(10),
                        vertical: globalDataStore.getResponsiveSize(10)),
                    width: MediaQuery.of(context).size.width,
                    height: (MediaQuery.of(context).size.height -
                            globalDataStore.getResponsiveSize((topBarHeight +
                                topBarOffSet +
                                (chatTypeBarHeight) +
                                (tapBarHeight + tapBarOffSet)))) /
                        2,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              globalDataStore.getResponsiveSize(15)),
                          color: Color.fromRGBO(244, 124, 132, 1)),
                      child: Image(
                          image: AssetImage(
                              'assets/images/Pregnancy_Week_by_Week_Guide/nbInsightChart_' +
                                  onSelectedChartIndex.toString() +
                                  '.png')),
                    ),
                  ),
                ),
//Chart BG

                // Positioned(
                //     top: widget.getResponsivePositioning((topBarHeight +
                //             topBarOffSet +
                //             chatTypeBarHeight +
                //             chartAmountAxieLabelOffset) +
                //         (MediaQuery.of(context).size.height -
                //                 globalDataStore.getResponsiveSize(
                //                     (topBarHeight +
                //                         topBarOffSet +
                //                         (chatTypeBarHeight) +
                //                         (tapBarHeight + tapBarOffSet)))) /
                //             2),
                //     child: Container(
                //       // decoration: BoxDecoration(color: Colors.blue),
                //       width: MediaQuery.of(context).size.width,
                //       height: (MediaQuery.of(context).size.height -
                //               globalDataStore.getResponsiveSize((topBarHeight +
                //                   topBarOffSet +
                //                   (chatTypeBarHeight) +
                //                   (tapBarHeight + tapBarOffSet)))) /
                //           2,
                //       padding: EdgeInsets.only(
                //           left: globalDataStore.getResponsiveSize(30),
                //           right: globalDataStore.getResponsiveSize(15),
                //           top: globalDataStore.getResponsiveSize(15)),
                //       child: Stack(
                //         children: [
                //           Column(
                //             children: List.generate(24, (index) {
                //               return Container(
                //                 decoration: BoxDecoration(
                //                     color: (index % 2 == 0
                //                         ? Colors.white
                //                         : Color.fromRGBO(250, 250, 250, 1))),
                //                 height: ((MediaQuery.of(context).size.height -
                //                             globalDataStore.getResponsiveSize(
                //                                 (topBarHeight +
                //                                     topBarOffSet +
                //                                     (chatTypeBarHeight) +
                //                                     (tapBarHeight +
                //                                         tapBarOffSet) +
                //                                     chartAmountAxieLabelHeight +
                //                                     chartAmountAxieLabelOffset))) /
                //                         2) /
                //                     26.1,
                //                 // child: Row(
                //                 //   children: List.generate(6, (index) {
                //                 //     return Container(
                //                 //       margin: index == 0
                //                 //           ? EdgeInsets.only(left: 20)
                //                 //           : EdgeInsets.zero,
                //                 //       width: (MediaQuery.of(context).size.width -
                //                 //               globalDataStore.getResponsiveSize(
                //                 //                   45 + 20 + 40)) /
                //                 //           7,
                //                 //       height: double.maxFinite,
                //                 //       decoration: BoxDecoration(
                //                 //           border: Border(right: BorderSide())),
                //                 //     );
                //                 //   }),
                //                 // ),
                //               );
                //             }),
                //           )
                //         ],
                //       ),
                //     )),
                //Chart
                Positioned(
                    top: widget.getResponsivePositioning(
                        (topBarHeight + topBarOffSet + chatTypeBarHeight) +
                            (MediaQuery.of(context).size.height -
                                    globalDataStore.getResponsiveSize(
                                        (topBarHeight + topBarOffSet) +
                                            (chatTypeBarHeight) +
                                            (Platform.isIOS
                                                ? (chatTypeBarHeight)
                                                : 0) +
                                            (tapBarHeight + tapBarOffSet))) /
                                2),
                    child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Container(
                            height: globalDataStore
                                .getResponsiveSize(chartAmountAxieLabelHeight),
                            width: globalDataStore.getResponsiveSize(25),
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'cm',
                              style: TextStyle(
                                  fontSize:
                                      globalDataStore.getResponsiveSize(11),
                                  fontFamily: 'SFProText',
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  letterSpacing: -0.1),
                            ),
                          ),
                          Container(
                            height: ((MediaQuery.of(context).size.height -
                                    globalDataStore.getResponsiveSize(
                                        (topBarHeight +
                                            topBarOffSet +
                                            (chatTypeBarHeight) +
                                            (tapBarHeight + tapBarOffSet) +
                                            chartAmountAxieLabelOffset))) /
                                2),
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    globalDataStore.getResponsiveSize(0)),
                            padding: EdgeInsets.only(
                                left: globalDataStore.getResponsiveSize(0),
                                right: globalDataStore.getResponsiveSize(15),
                                top: globalDataStore.getResponsiveSize(10)),
                            // decoration: BoxDecoration(color: Colors.white),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Container(
                                  // decoration: BoxDecoration(color: Colors.blue),
                                  width: MediaQuery.of(context).size.width * 2,
                                  height: ((MediaQuery.of(context).size.height -
                                          globalDataStore.getResponsiveSize(
                                              (topBarHeight +
                                                  topBarOffSet +
                                                  (chatTypeBarHeight) +
                                                  (tapBarHeight +
                                                      tapBarOffSet) +
                                                  chartAmountAxieLabelOffset))) /
                                      2),
                                  child: Stack(
                                    children: [
                                      Container(
                                        // decoration: BoxDecoration(color: Colors.blue),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2,

                                        padding: EdgeInsets.only(
                                            left: globalDataStore
                                                .getResponsiveSize(30),
                                            right: globalDataStore
                                                .getResponsiveSize(0),
                                            top: globalDataStore
                                                .getResponsiveSize(0)),
                                        child: Stack(
                                          children: [
                                            Column(
                                              children:
                                                  List.generate(24, (index) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      color: (index % 2 == 0
                                                          ? Colors.white
                                                          : Color.fromRGBO(250,
                                                              250, 250, 1))),
                                                  height: ((MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height -
                                                              globalDataStore.getResponsiveSize((topBarHeight +
                                                                  topBarOffSet +
                                                                  (chatTypeBarHeight) +
                                                                  (tapBarHeight +
                                                                      tapBarOffSet) +
                                                                  chartAmountAxieLabelHeight +
                                                                  chartAmountAxieLabelOffset))) /
                                                          2) /
                                                      26.1,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: ((MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                globalDataStore.getResponsiveSize(
                                                    (topBarHeight +
                                                        topBarOffSet +
                                                        (chatTypeBarHeight) +
                                                        (tapBarHeight +
                                                            tapBarOffSet) +
                                                        chartAmountAxieLabelOffset))) /
                                            2),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2,
                                        child: pregnancyLineChart(
                                            pregnancyChartGuids,
                                            pregnancyRecords,
                                            DateTime.parse(myData.birthday),
                                            onSelectedChartIndex),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ])))
              ]
            ],
            //Notificates List
            if (curSectionIdx == 3) ...[
              Positioned(
                  top: widget
                      .getResponsivePositioning((topBarHeight + topBarOffSet)),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore
                            .getResponsiveSize((topBarHeight + topBarOffSet)),
                    width: MediaQuery.of(context).size.width,
                    // decoration: BoxDecoration(color: Colors.amberAccent),
                    child: ListView(
                      controller: mainContentListController,
                      padding: EdgeInsets.only(
                          top: 10,
                          bottom: (appPushList.length < 9
                              ? globalDataStore.getResponsiveSize(
                                  tapBarHeight + tapBarOffSet)
                              : 0)),
                      children: List.generate(appPushList.length, (index) {
                        return notificationRecordBlk(appPushList[index],
                            (infoData) {
                          print('notification push interating => id ? ' +
                              infoData.userid +
                              ' , typeIndex ? ' +
                              infoData.typeIndex().toString());

                          switch (infoData.typeIndex()) {
                            case 0:
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: PostDetail(PostData(),
                                              key: new Key(
                                                  new Uuid().toString())),
                                          type: PageTransitionType.rightToLeft))
                                  .then((value) {
                                //remove this record from list
                                if (appPushList.contains(infoData)) {
                                  appPushList.remove(infoData);
                                  setState(() {});
                                }
                              });
                              break;
                            case 1:
                              Navigator.pushNamed(context, '/postCreate')
                                  .then((value) {
                                //remove this record from list
                                if (appPushList.contains(infoData)) {
                                  appPushList.remove(infoData);
                                  setState(() {});
                                }
                              });
                              break;
                            case 2:
                            case 3:
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: ProfilePushView(
                                              ProfileData(
                                                  birthday: '2020-01-01',
                                                  gender: 'Girl',
                                                  nickName: 'DemoBaby1234'),
                                              key: new Key(
                                                  new Uuid().toString())),
                                          type: PageTransitionType.rightToLeft))
                                  .then((value) {
                                //remove this record from list
                                if (appPushList.contains(infoData)) {
                                  appPushList.remove(infoData);
                                  setState(() {});
                                }
                              });
                              break;
                            case 4:
                              if (appPushList.contains(infoData)) {
                                appPushList.remove(infoData);
                                setState(() {});
                              }
                              break;
                          }
                        });
                      }),
                    ),
                  )),
            ],
            //User profile detials
            if (curSectionIdx == 4) ...[
              //Short Info
              Positioned(
                  top: widget
                      .getResponsivePositioning((topBarHeight + topBarOffSet)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: globalDataStore
                        .getResponsiveSize(profileShortDetailFieldHeight),
                    // decoration: BoxDecoration(color: Colors.amber),
                    child: userShortInfo(
                        globalDataStore
                            .getResponsiveSize(profileShortDetailFieldHeight),
                        MediaQuery.of(context).size.width,
                        myData, () {
                      print('Edit Profile');
                      Navigator.push(
                          context,
                          PageTransition(
                              child: ProfileEditing.eixit(myData,
                                  notBorn: myData.borned == 0,
                                  key: new Key(new Uuid().toString())),
                              type: PageTransitionType.rightToLeft));
                    }, () {
                      Navigator.pushNamed(context, '/photoAlbum');
                    }, context),
                  )),
              //Create new post
              Positioned(
                  top: widget.getResponsivePositioning(
                      (topBarHeight + topBarOffSet) +
                          profileShortDetailFieldHeight),
                  child: createNewPostBlock(
                      MediaQuery.of(context).size.width,
                      globalDataStore.getResponsiveSize(inputFieldHeight),
                      globalDataStore.getResponsiveSize(inputFieldpadding),
                      myData,
                      pushPostCreatingView)),
              //Content
              Positioned(
                  top: widget.getResponsivePositioning((topBarHeight +
                      topBarOffSet +
                      inputFieldHeight +
                      profileShortDetailFieldHeight)),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore.getResponsiveSize(
                            (topBarHeight + topBarOffSet) +
                                inputFieldHeight +
                                profileShortDetailFieldHeight),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: HexColor('#F4F4F5')),
                    child: postRecordsFiltered.length > 0
                        ? ListView(
                            controller: mainContentListController,
                            padding: EdgeInsets.only(
                                top: 0,
                                bottom: globalDataStore.getResponsiveSize(
                                    postRecordsFiltered.length > 1
                                        ? 0
                                        : tapBarHeight + tapBarOffSet)),
                            children: List.generate(postRecordsFiltered.length,
                                (index) {
                              return postBlock(
                                postRecordsFiltered[index],
                                globalDataStore.getResponsiveSize(10),
                                MediaQuery.of(context).size.width,
                                (postData) {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: PostDetail(postData,
                                              key: new Key(
                                                  new Uuid().toString())),
                                          type:
                                              PageTransitionType.rightToLeft));
                                },
                                (postData) {
                                  widget.pushImageZoomingView(
                                      postData.postMediaLink, context);
                                },
                              );
                            }),
                          )
                        : myProfileNoRecordColume(),
                  )),
            ],

            //Tapbar
            AnimatedPositioned(
                bottom: tapBarOnShow
                    ? globalDataStore.getResponsiveSize(tapBarOffSet)
                    : -100,
                width: MediaQuery.of(context).size.width,
                duration: Duration(milliseconds: 500),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: globalDataStore.getResponsiveSize(20)),
                  padding: EdgeInsets.symmetric(
                      horizontal: globalDataStore.getResponsivePositioning(15),
                      vertical: globalDataStore
                          .getResponsivePositioning(tapBarPadding)),
                  decoration: BoxDecoration(
                      color: HexColor('#0C3658'),
                      borderRadius: BorderRadius.all(Radius.circular(
                          globalDataStore.getResponsiveSize(20)))),
                  height: globalDataStore.getResponsiveSize(tapBarHeight),
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      tapButtonWidget(() {
                        setState(() {
                          sectionChange(0);
                        });
                      },
                          'assets/images/tabbar_icon_1' +
                              (curSectionIdx == 0 ? '_on' : '') +
                              ".png",
                          padding: 5),
                      Spacer(),
                      tapButtonWidget(() {
                        setState(() {
                          sectionChange(1);
                        });
                      },
                          'assets/images/tabbar_icon_2' +
                              (curSectionIdx == 1 ? '_on' : '') +
                              ".png",
                          padding: 5),
                      Spacer(),
                      tapButtonWidget(() {
                        setState(() {
                          sectionChange(2);
                        });
                      },
                          'assets/images/tabbar_icon_3' +
                              (curSectionIdx == 2 ? '_on' : '') +
                              ".png",
                          padding: 5),
                      Spacer(),
                      tapButtonWidget(() {
                        setState(() {
                          sectionChange(3);
                        });
                      },
                          'assets/images/tabbar_icon_4' +
                              (curSectionIdx == 3 ? '_on' : '') +
                              ".png",
                          padding: 5),
                      Spacer(),
                      tapButtonWidget(() {
                        setState(() {
                          sectionChange(4);
                        });
                      }, myData.profilePic,
                          padding: 3,
                          clip: true,
                          fitHeight: false,
                          onSelected: curSectionIdx == 4),
                    ],
                  ),
                )),

            //// ParentInfo block
            if (needShowProfileListView) ...[
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.75),
                    ),
                    child: Column(children: [
                      Spacer(),
                      Container(
                        height: globalDataStore
                            .getResponsiveSize(profileListViewHeight),
                        padding: EdgeInsets.only(
                            top: globalDataStore.getResponsiveSize(15)),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.75),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    globalDataStore.getResponsiveSize(16)),
                                topRight: Radius.circular(
                                    globalDataStore.getResponsiveSize(16)))),
                        child: Column(
                          children: [
                            //floating block title
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                  vertical:
                                      globalDataStore.getResponsiveSize(20),
                                  horizontal: globalDataStore
                                      .getResponsivePositioning(20)),
                              padding: EdgeInsets.only(),
                              child: Stack(
                                children: [
                                  Container(
                                    height:
                                        globalDataStore.getResponsiveSize(24),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'My Kid’s Profile',
                                      style: TextStyle(
                                          color: Color.fromRGBO(13, 54, 88, 1),
                                          fontSize: globalDataStore
                                              .getResponsiveSize(16),
                                          fontFamily: 'SFProText',
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2),
                                    ),
                                  ),
                                  Positioned(
                                      right: 0,
                                      child: Container(
                                        height: globalDataStore
                                            .getResponsiveSize(24),
                                        width: globalDataStore
                                            .getResponsiveSize(24),
                                        child: TextButton(
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero),
                                            onPressed: () {
                                              setState(() {
                                                needShowProfileListView = false;
                                              });
                                            },
                                            child: Image(
                                              height: globalDataStore
                                                  .getResponsiveSize(24),
                                              image: AssetImage(
                                                  'assets/images/icon_close3.png'),
                                            )),
                                      ))
                                ],
                              ),
                            ),
                            Expanded(
                                // height: getHeightOfView(1 - bottomZoneSize()),
                                // decoration: BoxDecoration(color: Colors.green),
                                child: GridView.count(
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    crossAxisCount: 1,
                                    childAspectRatio: (globalDataStore
                                            .getResponsiveSize(317) /
                                        globalDataStore
                                            .getResponsiveSize(162)), //252x162
                                    shrinkWrap: true,
                                    primary: true,
                                    padding: EdgeInsets.only(
                                        top: globalDataStore
                                            .getResponsiveTopPositioning(0),
                                        bottom: 0),
                                    clipBehavior: Clip.antiAlias,
                                    children: //[new ProfileGridCell((id) {})]
                                        List.generate(dataConSolid.length,
                                            (index) {
                                      if (dataConSolid[index]['data2'] !=
                                          null) {
                                        return getProfileGridDoubleCellRoll(
                                            (fileID) async {
                                          //TODO : set selected Profile
                                          await widget
                                              .setSelectedProfile(fileID)
                                              .then((isSuccess) {
//push with existing data
                                            if (fileID.length > 0) {
                                              // print('fileID ? ' + fileID);
                                              widget.setSelectedProfile(fileID);
                                              changeProfile();
                                            } else {
                                              widget
                                                  .showFunctionWillProvideSoon(
                                                      context);
                                            }
                                          });
                                        },
                                            data1: dataConSolid[index]['data1']
                                                as ProfileData,
                                            data2: dataConSolid[index]['data2']
                                                as ProfileData,
                                            existingID: myData.id);
                                      } else {
                                        return Center(child:
                                            getProfileGridSingleCellRoll(
                                                (fileID) {
                                          widget.showFunctionWillProvideSoon(
                                              context);
                                        }));
                                      }
                                    }))),
                          ],
                        ),
                      )
                    ]),
                  ))
            ]
          ],
        ));
  }
}

//All layout widgets
Widget noRecordColume(VoidCallback buttonOnPress,
    {String title = 'Not yet recorded today',
    String contentLine =
        'Click “+” button to record your kid’s\ndaily / particular activities',
    bool needAddButton = true}) {
  return Column(
    //No record view
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        height: globalDataStore.getResponsiveSize(40),
        child: Image(image: AssetImage('assets/images/icon_noRecord_kid.png')),
      ),
      Container(
          margin: EdgeInsets.symmetric(
              vertical: globalDataStore.getResponsiveSize(15)),
          child: Text(
            title,
            style: TextStyle(
                color: Color.fromRGBO(14, 54, 88, 1),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                fontSize: globalDataStore.getResponsiveSize(16)),
          )),
      Container(
          margin:
              EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(30)),
          child: Text(
            contentLine,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                fontSize: globalDataStore.getResponsiveSize(12)),
          )),
      if (needAddButton) ...[createDailyRecordButton(buttonOnPress)]
    ],
  );
}

/// Profiles widget

Widget myProfileNoRecordColume(
    {String title = 'No recorded',
    String contentLine =
        'Make new post to share you and your kid’s\ndaily happiness moments',
    bool needAddButton = true,
    VoidCallback? buttonOnPress}) {
  return Column(
    //No record view
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        height: globalDataStore.getResponsiveSize(40),
        child: Image(image: AssetImage('assets/images/icon_noRecord_kid.png')),
      ),
      Container(
          margin: EdgeInsets.symmetric(
              vertical: globalDataStore.getResponsiveSize(15)),
          child: Text(
            title,
            style: TextStyle(
                color: Color.fromRGBO(14, 54, 88, 1),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                fontSize: globalDataStore.getResponsiveSize(16)),
          )),
      Container(
          margin:
              EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(70)),
          child: Text(
            contentLine,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                fontSize: globalDataStore.getResponsiveSize(12)),
          )),
    ],
  );
}
