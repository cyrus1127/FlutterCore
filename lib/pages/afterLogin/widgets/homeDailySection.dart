import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/dataObjects/pregnancy.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/pregnancyRecordCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/widgets/parts.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

Widget dailyRecordBlock(
    DailyRecord data,
    double layoutMargin,
    Function(DailyRecord) cellOnPressed,
    Function(DailyRecord) wakeBtnOnPressed) {
  //datetime
  DateTime dateTime = DateTime.parse(data.datetime);
  //other fields
  String name = data.activity;
  String amount = data.amount.toString() + ' ' + data.amountMark;
  if (data.activityType <= 1) {
    name = data.activity + ' (' + data.quanity + ') ';
    amount = data.datetimeDuration.toString() + ' mins';
  } else if (data.activityType == 5) {
    dateTime = DateTime.parse(data.datetimeEnd);
    amount = data.datetimeDuration.toString() + ' mins';
  }

  //handle Datetime formating
  String fullTimeMark = DateFormat.jm().format(dateTime);
  String dayNiteMark = fullTimeMark.split(" ").last;
  String timeMark = fullTimeMark.split(" ").first;
  if (timeMark.length < 5) timeMark = '0' + fullTimeMark.split(" ").first;

  return Container(
    height: 52,
    margin: EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(8)),
    padding: EdgeInsets.only(left: globalDataStore.getResponsiveSize(20)),
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        Text(
          dayNiteMark,
          style: TextStyle(
              fontFamily: 'SFProText-Medium',
              fontSize: 12,
              letterSpacing: -0.19,
              fontWeight: FontWeight.w500),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              timeMark,
              style: TextStyle(
                  fontFamily: 'SFProText-Medium',
                  fontSize: globalDataStore.getResponsiveSize(18),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500),
            )),
        Container(
            margin: EdgeInsets.only(
                left: globalDataStore.getResponsiveSize(5),
                right: globalDataStore.getResponsiveSize(15)),
            padding: EdgeInsets.symmetric(
                vertical: globalDataStore.getResponsiveSize(10),
                horizontal: globalDataStore.getResponsiveSize(0)),
            child: PhysicalModel(
              clipBehavior: Clip.antiAlias,
              color: Color.fromRGBO(245, 172, 43, 1),
              child: Image(image: AssetImage(data.getImagePath())),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            )),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
                fontFamily: 'SFProText-Medium',
                fontSize: globalDataStore.getResponsiveSize(14),
                fontStyle: FontStyle.normal,
                letterSpacing: -0.19,
                fontWeight: FontWeight.w500),
          ),
        ),
        if (data.activityType == 4) ...[
          ///sleep
          if (data.datetimeEnd == 'null') ...[
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                onPressed: () {
                  wakeBtnOnPressed(data);
                },
                child: Container(
                  width: globalDataStore.getResponsiveSize(56),
                  height: globalDataStore.getResponsiveSize(28),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(14, 54, 88, 1),
                      borderRadius: BorderRadius.circular(
                          globalDataStore.getResponsiveSize(6.93))),
                  margin: EdgeInsets.only(
                      left: globalDataStore.getResponsiveSize(5)),
                  padding: EdgeInsets.symmetric(
                      horizontal: globalDataStore.getResponsiveSize(12),
                      vertical: globalDataStore.getResponsiveSize(4)),
                  alignment: Alignment.center,
                  child: Text(
                    'Wake',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFProText',
                        fontSize: globalDataStore.getResponsiveSize(12),
                        fontStyle: FontStyle.normal,
                        letterSpacing: -0.15,
                        fontWeight: FontWeight.w600),
                  ),
                ))
          ]
        ] else ...[
          Text(
            amount,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontFamily: 'SFProText-Medium',
                fontSize: globalDataStore.getResponsiveSize(14),
                letterSpacing: 0.24,
                fontWeight: FontWeight.w500),
          ),
        ],
        Container(
          width: globalDataStore.getResponsiveSize(24),
          padding: EdgeInsets.symmetric(
              vertical: globalDataStore.getResponsiveSize(15), horizontal: 0),
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
            onPressed: () {
              cellOnPressed(data);
            },
            child:
                Image(image: AssetImage('assets/images/icon_arrow_right2.png')),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              left: globalDataStore.getResponsiveSize(5),
              right: globalDataStore.getResponsiveSize(10)),
          width: globalDataStore.getResponsiveSize(5),
          height: globalDataStore.getResponsiveSize(5),
          decoration: BoxDecoration(
              color: (data.activityType == 4 || data.activityType == 5
                  ? Color.fromRGBO(14, 54, 88, 1)
                  : Colors.transparent),
              borderRadius:
                  BorderRadius.circular(globalDataStore.getResponsiveSize(5))),
        )
      ],
    ),
  );
}

Widget notBornDailyRecordGuideLine(
    List<PregnancyGuid> datas,
    List<PregnancyDailyRecord> filters,
    VoidCallback addButtonPressed,
    VoidCallback editButtonPressed,
    VoidCallback shareButtonPressed,
    Function(String) imageScaleBtnOnPressed,
    ScrollController scrollListener,
    {int weeks = 0,
    double bottomOffset = 0}) {
  PregnancyGuid curDatas = datas[0];
  for (PregnancyGuid d in datas) {
    if (d.week == weeks) {
      curDatas = d;
      break;
    }
  }

  String recordIllustrationImagePath =
      'assets/images/Pregnancy_Record_Illustration_Cut_Assets/';

  if (weeks >= 2) {
    if (weeks >= 40) {
      recordIllustrationImagePath = recordIllustrationImagePath +
          'pregnancy_almost_there.png'; //default : after 40weeks
    } else {
      String translation = '';
      if (weeks >= 8 && weeks <= 20) translation = '_en';
      recordIllustrationImagePath = recordIllustrationImagePath +
          'pregnancy_week_' +
          weeks.toString() +
          translation +
          '.png';
    }
  } else {
    recordIllustrationImagePath =
        recordIllustrationImagePath + 'pregnancy_week_2.png';
  }

  String guideImagePath_top =
      'assets/images/Pregnancy_Week_by_Week_Guide/pregnancy-week-2_square.png';
  String guideImagePath =
      'assets/images/Pregnancy_Week_by_Week_Guide/2-weeks-pregnant_square.png';
  if (weeks >= 2) {
    if (weeks > 41) {
      guideImagePath_top =
          'assets/images/Pregnancy_Week_by_Week_Guide/pregnancy-week-41_square.png';
      guideImagePath =
          'assets/images/Pregnancy_Week_by_Week_Guide/41-weeks-pregnant_square.png';
    } else {
      guideImagePath_top =
          'assets/images/Pregnancy_Week_by_Week_Guide/pregnancy-week-' +
              weeks.toString() +
              '_square.png';
      guideImagePath = 'assets/images/Pregnancy_Week_by_Week_Guide/' +
          weeks.toString() +
          '-weeks-pregnant_square.png';
    }
  }

  Widget lwM(bool isLenght, String val, String unit) {
    return Column(
      children: [
        Image(
            height: globalDataStore.getResponsiveSize(48),
            image: AssetImage(
                'assets/images/pregnancy_' + (isLenght ? 'h' : 'w') + '.png')),
        Container(
            margin: EdgeInsets.symmetric(
                vertical: globalDataStore.getResponsiveSize(5)),
            child: Text(
              isLenght ? 'Length' : 'Weight',
              style: TextStyle(
                  color: Color.fromRGBO(14, 54, 88, 1),
                  fontFamily: 'SFProText',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  fontSize: globalDataStore.getResponsiveSize(16)),
            )),
        Text(
          isLenght ? 'head to bottom' : '',
          style: TextStyle(
              fontFamily: 'SFProText',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: globalDataStore.getResponsiveSize(12)),
        ),
        Text(
          val,
          style: TextStyle(
              fontFamily: 'SFProText',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: globalDataStore.getResponsiveSize(30)),
        ),
        Text(
          unit,
          style: TextStyle(
              fontFamily: 'SFProText',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: globalDataStore.getResponsiveSize(12)),
        ),
      ],
    );
  }

  Widget rI(Widget childImage) {
    return PhysicalModel(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(
            Radius.circular(globalDataStore.getResponsiveSize(15))),
        child: childImage);
  }

  Widget qaList(Color coreColor, String iconPath, {bool typeHighLight = true}) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: globalDataStore.getResponsiveSize(20)),
      padding: EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(20)),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color.fromRGBO(196, 196, 196, 1)))),
      child: Column(
          children: List.generate(
              curDatas.nubmerOfQuests(typeHighLight: typeHighLight),
              (elementIdx) {
        List<String> qa = curDatas.questAwnser(elementIdx,
                isTC: false, typeHighLight: typeHighLight) ??
            [];
        return qa.length > 0
            ? Column(
                children: [
                  Row(children: [
                    Image(
                        height: globalDataStore.getResponsiveSize(24),
                        image: AssetImage(iconPath)),
                    Container(
                      margin: EdgeInsets.only(
                          left: globalDataStore.getResponsiveSize(5)),
                      child: Text(qa.first,
                          style: TextStyle(
                              color: coreColor,
                              fontFamily: 'SFProText',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              fontSize: globalDataStore.getResponsiveSize(12))),
                    )
                  ]),
                  Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.only(
                        top: globalDataStore.getResponsiveSize(5),
                        bottom: globalDataStore.getResponsiveSize(10)),
                    child: Text(qa.last,
                        style: TextStyle(
                            fontFamily: 'SFProText',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            fontSize: globalDataStore.getResponsiveSize(12))),
                  )
                ],
              )
            : Container();
      })),
    );
  }

  Widget recordList(String title, double data) {
    return Container(
      height: globalDataStore.getResponsiveSize(52),
      margin: EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(10)),
      padding: EdgeInsets.symmetric(
          vertical: globalDataStore.getResponsiveSize(12),
          horizontal: globalDataStore.getResponsiveSize(20)),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 2,
                color: Color.fromRGBO(0, 0, 0, 0.1))
          ],
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(globalDataStore.getResponsiveSize(15))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(data.toString() + 'cm'),
        ],
      ),
    );
  }

  return ListView(
    controller: scrollListener,
    padding: EdgeInsets.only(
        top: globalDataStore.getResponsiveSize(10),
        bottom: globalDataStore.getResponsiveSize(bottomOffset)),
    children: [
      rI(Image(image: AssetImage(guideImagePath_top))),

      //Record reminder
      Container(
        margin: EdgeInsets.symmetric(
            vertical: globalDataStore.getResponsiveSize(10)),
        padding: EdgeInsets.only(
            bottom: globalDataStore
                .getResponsiveSize(weeks >= 14 && weeks <= 40 ? 15 : 0)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(196, 196, 196, 1)))),
        child: Column(
          children: [
            Column(
              //No record view
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (filters.length > 0) ...[
                  ///TODO :

                  MaterialButton(
                    onPressed: () async {
                      ///TODO : scale ??
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                      height: globalDataStore.getResponsiveSize(258),
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(
                          vertical: globalDataStore.getResponsiveSize(10)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              globalDataStore.getResponsiveSize(15)),
                          color: Color.fromRGBO(255, 255, 255, 0.5)),
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
                          image: loadImageAsset(filters[0].photoPath),
                        ),
                      ),
                    ),
                  ),
                  //Recorded datas
                  recordList('CRL, Cephalo-rump Length', filters[0].crl),
                  recordList('BPD, Biparietal Diameter', filters[0].bpd),
                  recordList('HC, Head Circumference', filters[0].hc),
                  recordList('FL, Femer Length', filters[0].fl),
                  recordList('AC, Abdominal Circumference', filters[0].ac),
                  Container(
                    height: globalDataStore.getResponsiveSize(24),
                    margin: EdgeInsets.symmetric(
                        vertical: globalDataStore.getResponsiveSize(10)),
                    padding: EdgeInsets.symmetric(
                      horizontal: globalDataStore.getResponsiveSize(45),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        postActionButtonWidget(
                            editButtonPressed, 'fi_edit', 'Edit'),
                        postActionButtonWidget(
                            shareButtonPressed, 'fi_share-2', 'Share'),
                      ],
                    ),
                  )
                ] else ...[
                  Image(
                      height: globalDataStore.getResponsiveSize(48),
                      image: AssetImage('assets/images/icon_noRecord_kid.png')),
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: globalDataStore.getResponsiveSize(5)),
                      child: Text(
                        'Record a moment',
                        style: TextStyle(
                            color: Color.fromRGBO(14, 54, 88, 1),
                            fontFamily: 'SFProText',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontSize: globalDataStore.getResponsiveSize(16)),
                      )),
                  if (weeks >= 14 && weeks <= 40) ...[
                    Container(
                        margin: EdgeInsets.only(
                            bottom: globalDataStore.getResponsiveSize(15)),
                        child: Text(
                          'Record every moment when you go to client prenatal care...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'SFProText',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              fontSize: globalDataStore.getResponsiveSize(12)),
                        )),
                    createDailyRecordButton(addButtonPressed, paddingWidth: 0)
                  ] else ...[
                    Container(
                        margin: EdgeInsets.only(
                            bottom: globalDataStore.getResponsiveSize(15)),
                        child: Text(
                          'After first trimester, allow to record every moment\nwhen you go to client prenatal care...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'SFProText',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              fontSize: globalDataStore.getResponsiveSize(12)),
                        )),
                  ]
                ]
              ],
            ),
          ],
        ),
      ),

      //Size of Stage
      if (recordIllustrationImagePath.length > 0) ...[
        Container(
            margin: EdgeInsets.symmetric(
                vertical: globalDataStore.getResponsiveSize(5)),
            alignment: Alignment.center,
            child: Text(
              curDatas.nameState,
              style: TextStyle(
                  color: Color.fromRGBO(14, 54, 88, 1),
                  fontFamily: 'SFProText',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  fontSize: globalDataStore.getResponsiveSize(16)),
            )),
        Image(image: AssetImage(recordIllustrationImagePath)),
        Container(
          margin: EdgeInsets.symmetric(
              vertical: globalDataStore.getResponsiveSize(20)),
          padding:
              EdgeInsets.only(bottom: globalDataStore.getResponsiveSize(20)),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color.fromRGBO(196, 196, 196, 1)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              lwM(true, curDatas.lenght, curDatas.lenght_unit),
              lwM(false, curDatas.weight, curDatas.weight_unit),
            ],
          ),
        )
      ],

      //Highlight
      if (recordIllustrationImagePath.length > 0) ...[
        Center(
          child: Text(
            'Highlights this week',
            style: TextStyle(
                color: Color.fromRGBO(13, 54, 88, 1),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
                fontSize: globalDataStore.getResponsiveSize(16)),
          ),
        ),
        qaList(Color.fromRGBO(245, 172, 45, 1),
            'assets/images/u_lightbulb-alt.png')
      ],

      //Baby developer
      if (recordIllustrationImagePath.length > 0) ...[
        Center(
          child: Text(
            'Baby development at ' + weeks.toString() + ' weeks',
            style: TextStyle(
                color: Color.fromRGBO(13, 54, 88, 1),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
                fontSize: globalDataStore.getResponsiveSize(16)),
          ),
        ),
        qaList(Color.fromRGBO(241, 163, 135, 1), 'assets/images/u_kid.png')
      ],
      //The show case
      Center(
        child: Text(
          'Your body at ' + weeks.toString() + ' weeks',
          style: TextStyle(
              color: Color.fromRGBO(13, 54, 88, 1),
              fontFamily: 'SFProText',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: globalDataStore.getResponsiveSize(16)),
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(
            vertical: globalDataStore.getResponsiveSize(15)),
        child: Stack(
          children: [
            rI(Image(image: AssetImage(guideImagePath))),
            Positioned(
              bottom: globalDataStore.getResponsiveSize(10),
              right: globalDataStore.getResponsiveSize(10),
              child: Container(
                width: globalDataStore.getResponsiveSize(48),
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    imageScaleBtnOnPressed(guideImagePath);
                  },
                  child: Image(
                      height: globalDataStore.getResponsiveSize(48),
                      image:
                          AssetImage('assets/images/u_expand-arrows-alt.png')),
                ),
              ),
            )
          ],
        ),
      ),
      Center(
          child: Text(
        'Information source from https://www.babycenter.com/',
        style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            fontFamily: 'SFProText',
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
            fontSize: globalDataStore.getResponsiveSize(12)),
      ))
    ],
  );
}
