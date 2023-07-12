import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/dataObjects/pregnancy.dart';
import 'package:app_devbase_v1/pages/afterLogin/pregnancyRecordCreate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


/// TODO : use BarChartRodStackItem
Widget pregnancyLineChart(List<PregnancyChartGuid> chartGuids,
    List<PregnancyDailyRecord> coreData, DateTime start, int filter,
    {double maxY = 100, String unit = 'cm'}) {
  double maxXPad = 3;
  double maxX = 26 + maxXPad; //chart lenght
  LineChart chart;
  List<LineChartBarData> chartDatas = [];

  if (coreData.length == 0) {
    // return Container();
    coreData.add(new PregnancyDailyRecord(datetime: DateTime.now().toString()));
  }

  //add the basic range
  {
    List<FlSpot> SpotRodsBl = [];
    List<FlSpot> SpotRodsBh = [];
    List<FlSpot> SpotRodsBc = []; //base compare line
    List<FlSpot> SpotRodsDa = [];
    {
      // if (index >= 1)
      for (int index = 1; index < maxX - 1; index++) {
        //handle baserange
        if (index <= chartGuids.length) {
          PregnancyChartGuid obj = chartGuids[index - 1];
          double nMaxY = 0;

          switch (filter) {
            case 0:
              SpotRodsBc.add(FlSpot(index.toDouble(), obj.crl));
              nMaxY = obj.crl;
              break;
            case 1:
              SpotRodsBl.add(
                  FlSpot(index.toDouble(), obj.getUpLowBPD(true))); // base low
              SpotRodsBh.add(FlSpot(
                  index.toDouble(), obj.getUpLowBPD(false))); // base height
              nMaxY = obj.getUpLowBPD(true);
              break;
            case 2:
              SpotRodsBl.add(
                  FlSpot(index.toDouble(), obj.getUpLowHC(true))); // base low
              SpotRodsBh.add(FlSpot(
                  index.toDouble(), obj.getUpLowHC(false))); // base height
              nMaxY = obj.getUpLowHC(true);
              break;
            case 3:
              SpotRodsBl.add(
                  FlSpot(index.toDouble(), obj.getUpLowFL(true))); // base low
              SpotRodsBh.add(FlSpot(
                  index.toDouble(), obj.getUpLowFL(false))); // base height
              nMaxY = obj.getUpLowFL(true);
              break;
            case 4:
              SpotRodsBl.add(
                  FlSpot(index.toDouble(), obj.getUpLowAC(true))); // base low
              SpotRodsBh.add(FlSpot(
                  index.toDouble(), obj.getUpLowAC(false))); // base height
              nMaxY = obj.getUpLowAC(true);
              break;
          }
          if (index == chartGuids.length - 1) {
            maxY = nMaxY * 1.1;
          }
        }
      }

      //handle user record
      coreData.forEach((element) {
        //x = date
        String exactDate = element.datetime.split(' ').first;
        DateTime dExact = DateTime.parse(exactDate);
        DateTime dWeek14 = start.subtract(Duration(days: 26 * 7));
        double x = dExact.difference(dWeek14).inDays.toDouble() / 7;
        double y = 0;
        switch (filter) {
          case 0:
            y = element.crl;
            break;
          case 1:
            y = element.bpd;
            break;
          case 2:
            y = element.hc;
            break;
          case 3:
            y = element.fl;
            break;
          case 4:
            y = element.ac;
            break;
        }
        if (x >= 0 && y > 0) SpotRodsDa.add(FlSpot(x, y));
      });

      if (filter > 0) {
//add all datas -- base low & height
        chartDatas.add(LineChartBarData(
          spots: SpotRodsBl, isCurved: true,
          // barWidth: 2,
          colors: [Colors.transparent],
          dotData: FlDotData(
            show: false,
          ),
        ));
        chartDatas.add(LineChartBarData(
          spots: SpotRodsBh, isCurved: true,
          // barWidth: 2,
          colors: [Colors.transparent],
          dotData: FlDotData(
            show: false,
          ),
        ));
      } else {
        chartDatas.add(LineChartBarData(
          spots: SpotRodsBc, isCurved: true,
          // barWidth: 2,
          colors: [Colors.blue],
          dotData: FlDotData(
            show: true,
          ),
        ));
      }

      //add all datas -- base anayls
      chartDatas.add(LineChartBarData(
        spots: SpotRodsDa, isCurved: true,
        // barWidth: 2,
        colors: [Color.fromRGBO(229, 96, 32, 1)],
        dotData: FlDotData(
          show: true,
        ),
      ));
      print('timeChart data init done =-=-=-=-=-');
    }

//Final init the chart
    chart = LineChart(LineChartData(
      lineBarsData: chartDatas,
      lineTouchData: LineTouchData(enabled: false),
      maxY: maxY,
      minY: 0,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
            showTitles: true,
            // getTitlesWidget: (value) {
            //   if (value > 0) {
            //     int dt = (13 + value).toInt();
            //     return 'wk' + dt.toString();
            //   }
            //   return '';
            // },
            // getTextStyles: (context, value) {
            //   return TextStyle(
            //       fontSize: globalDataStore.getResponsiveSize(11),
            //       fontFamily: 'SFProText',
            //       fontStyle: FontStyle.normal,
            //       fontWeight: FontWeight.w400,
            //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
            //       letterSpacing: -0.1);
            // },
            interval: 1),
        leftTitles: SideTitles(
          showTitles: true,
          interval: (maxY / 50 >= 1 ? 10 : (maxY / 10 >= 1 ? 3 : 1.5)),
          // getTextStyles: (context, value) {
          //   return TextStyle(
          //       fontSize: globalDataStore.getResponsiveSize(11),
          //       fontFamily: 'SFProText',
          //       fontStyle: FontStyle.normal,
          //       fontWeight: FontWeight.w400,
          //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
          //       letterSpacing: -0.1);
          // },
        ),
        topTitles: SideTitles(),
        rightTitles: SideTitles(),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(show: false),
      betweenBarsData: [
        if (filter > 0) ...[
          BetweenBarsData(
            fromIndex: 0,
            toIndex: 1,
            colors: [Colors.red.withOpacity(0.3)],
          )
        ]
      ],
    )
        // swapAnimationDuration: animDuration,
        );
  }

  return chart;
}

Widget childWHLineChart(List<ChildChartGuid> chartGuids,
    List<DailyRecord> coreData, int onSelectedChartIndex,
    {double maxY = 120, String unit = 'cm'}) {
  maxY = onSelectedChartIndex == 7 ? 120 : 48;
  double maxXPad = 2;
  double maxXVPad = 0.5; //shift the position
  double maxX = 7 + maxXPad; //chart lenght
  LineChart chart;
  List<LineChartBarData> chartDatas = [];

  // if (coreData.length == 0) {
  //   return Container();
  // }

  //add the basic range
  {
    List<FlSpot> SpotRodsBl = [];
    List<FlSpot> SpotRodsBh = [];
    List<FlSpot> SpotRodsBc = []; //base compare line
    List<FlSpot> SpotRodsDa = [];
    {
      // if (index >= 1)
      for (int index = 1; index < maxX; index++) {
        //handle baserange
        if (index <= chartGuids.length) {
          ChildChartGuid obj = chartGuids[index];

          MeasureDataSet mds =
              onSelectedChartIndex == 7 ? obj.height : obj.weight;

          if (index <= maxX - maxXPad) {
            SpotRodsBc.add(FlSpot(index.toDouble() + maxXVPad, mds.median));
          }
          SpotRodsBl.add(FlSpot(index.toDouble(), mds.SDp3)); // base low
          SpotRodsBh.add(FlSpot(index.toDouble(), mds.SDn3)); // base height
        }
      }

      //handle user record
      coreData.forEach((element) {
        //x = date
        double x = coreData.indexOf(element).toDouble() + 1 + maxXVPad;
        double y = element.amount.toDouble();
        if (x >= 0 && y > 0) SpotRodsDa.add(FlSpot(x, y));
      });

//add all datas -- base low & height
      chartDatas.add(LineChartBarData(
        spots: SpotRodsBl, isCurved: true,
        // barWidth: 2,
        colors:[ Colors.transparent],
        dotData: FlDotData(
          show: false,
        ),
      ));
      chartDatas.add(LineChartBarData(
        spots: SpotRodsBh, isCurved: true,
        // barWidth: 2,
        colors:[ Colors.transparent],
        dotData: FlDotData(
          show: false,
        ),
      ));

      chartDatas.add(LineChartBarData(
        spots: SpotRodsBc,
        barWidth: 5,
        colors:[ Color.fromRGBO(0, 119, 192, 1)],
        dotData: FlDotData(
          show: true,
        ),
      ));

      //add all datas -- base anayls
      if (SpotRodsDa.length > 2) {
        chartDatas.add(LineChartBarData(
          spots: SpotRodsDa, isCurved: true,
          // barWidth: 2,
          colors:[ Color.fromRGBO(229, 96, 32, 1)],
          dotData: FlDotData(
            show: true,
          ),
        ));
      }

      print('timeChart data init done =-=-=-=-=-');
    }

//Final init the chart
    chart = LineChart(LineChartData(
      lineBarsData: chartDatas,
      lineTouchData: LineTouchData(enabled: false),
      maxY: maxY,
      minY: 0,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: 
        SideTitles(
            showTitles: true,
            // getTitlesWidget: (value, meta) {
              
            // },
            // getTextStyles: (context, value) {
            //   return TextStyle(
            //       fontSize: globalDataStore.getResponsiveSize(11),
            //       fontFamily: 'SFProText',
            //       fontStyle: FontStyle.normal,
            //       fontWeight: FontWeight.w400,
            //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
            //       letterSpacing: -0.1);
            // },
            interval: 0.5),
        
        leftTitles: SideTitles(
          showTitles: true,
          interval: (maxY / 50 >= 1 ? 10 : (maxY / 10 >= 1 ? 3 : 1.5)),
          // getTextStyles: (context, value) {
          //   return TextStyle(
          //       fontSize: globalDataStore.getResponsiveSize(11),
          //       fontFamily: 'SFProText',
          //       fontStyle: FontStyle.normal,
          //       fontWeight: FontWeight.w400,
          //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
          //       letterSpacing: -0.1);
          // },
        ),
        topTitles: SideTitles(),
        rightTitles: SideTitles(),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(show: false),
      betweenBarsData: [
        BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          colors:[ Color.fromRGBO(241, 163, 135, 0.1)],
        )
      ],
    )
        // swapAnimationDuration: animDuration,
        );
  }

  return chart;
}

/// barChart -  Amount / bar
Widget amountBarChart(
    List<DailyRecord> coreData, DateTime start, double maxY, String unit) {
  BarChart chart;
  List<BarChartGroupData> chartDatas = [];
  DateTime endDur = start.add(Duration(days: 6)); //for a week
  double maxX = 7;

  var barTouchData = BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.transparent,
      tooltipPadding: const EdgeInsets.all(0),
      tooltipMargin: 0,
      getTooltipItem: (
        BarChartGroupData group,
        int groupIndex,
        BarChartRodData rod,
        int rodIndex,
      ) {
        return BarTooltipItem(
          
          rod.y.round().toString() + unit,
          const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 11,
              fontStyle: FontStyle.normal),
        );
      },
    ),
  );

  //add the basic range
  {
    for (int index = 0; index < maxX; index++) {
      // if (index >= 1)
      {
        List<BarChartRodData>? barRods = [];
        coreData.forEach((element) {
          //x = date
          String exactDate = element.datetime.split(' ').first;
          DateTime dExact = DateTime.parse(exactDate);
          DateTime d = DateTime.parse(element.datetime);
          double x = dExact.difference(start).inDays.toDouble();
          //y = time
          double y = element.amount.toDouble();
          // if (x == index) {
          //   barRods.add(BarChartRodData(
          //       y: y,
          //       borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          //       colors:[ [
          //         x % 2 == 0
          //             ? Color.fromRGBO(229, 96, 32, 1)
          //             : Color.fromRGBO(249, 173, 27, 1)
          //       ]));
          // }
        });

        BarChartGroupData nSpot = BarChartGroupData(
            x: index, barRods: barRods, showingTooltipIndicators: [0]);
        chartDatas.add(nSpot);
      }
    }
    print('timeChart data init done =-=-=-=-=-');

//Final init the chart
    chart = BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: barTouchData,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            // getTitlesWidget: (value) {
            //   DateTime dt = start.add(Duration(days: value.toInt()));
            //   return DateFormat.Md().format(dt);
            // },
            // getTextStyles: (context, value) {
            //   return TextStyle(
            //       fontSize: globalDataStore.getResponsiveSize(11),
            //       fontFamily: 'SFProText',
            //       fontStyle: FontStyle.normal,
            //       fontWeight: FontWeight.w400,
            //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
            //       letterSpacing: -0.1);
            // },
          ),
          
          leftTitles: SideTitles(
            showTitles: true,
            interval: maxY >= 100 ? 50 : 3,
            // getTextStyles: (context, value) {
            //   return TextStyle(
            //       fontSize: globalDataStore.getResponsiveSize(11),
            //       fontFamily: 'SFProText',
            //       fontStyle: FontStyle.normal,
            //       fontWeight: FontWeight.w400,
            //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
            //       letterSpacing: -0.1);
            // },
          ),
          topTitles: SideTitles(),
          rightTitles: SideTitles(),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: chartDatas,
        gridData: FlGridData(show: false),
      ),
      // swapAnimationDuration: animDuration,
    );
  }

  return chart;
}

Widget timeChartSpotStyle(List<DailyRecord> coreData, DateTime start) {
  ScatterChart chart;
  List<ScatterSpot> scatterSpots = [];
  DateTime endDur = start.add(Duration(days: 6)); //for a week
  //add the basic range
  {
    coreData.forEach((element) {
      //x = date
      DateTime d = DateTime.parse(element.datetime);
      double x = d.difference(start).inDays.toDouble() + 1;
      //y = time
      double y = d.hour.toDouble();
      if (element.datetimeDuration > 0) {
        for (int dur = 0; dur < element.datetimeDuration; dur += 5) {
          ScatterSpot nSpot = ScatterSpot(x, y + dur / 60);
          scatterSpots.add(nSpot);
        }
      } else {
        //default mark one
        ScatterSpot nSpot = ScatterSpot(x, y);
        scatterSpots.add(nSpot);
      }
    });

    chart = ScatterChart(
      ScatterChartData(
        scatterSpots: scatterSpots,
        minX: 0,
        maxX: 8,
        minY: 0,
        maxY: 24,
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: false,
        ),
        titlesData: FlTitlesData(
            // show: true,
            leftTitles: SideTitles(
              showTitles: true,
              interval: 3,
              // getTitlesWidget: (value) {
              //   if (value >= 1 && value <= 24) {
              //     return value.toInt().toString();
              //   }
              //   return '';
              // },
              // getTextStyles: (context, value) {
              //   return TextStyle(
              //       fontSize: globalDataStore.getResponsiveSize(11),
              //       fontFamily: 'SFProText',
              //       fontStyle: FontStyle.normal,
              //       fontWeight: FontWeight.w400,
              //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
              //       letterSpacing: -0.1);
              // },
            ),
            rightTitles: SideTitles(),
            topTitles: SideTitles(),
            bottomTitles: SideTitles(
                showTitles: true,
                // getTitlesWidget: (value) {
                //   if (value >= 1 && value <= 7) {
                //     DateTime dt = start.add(Duration(days: value.toInt() - 1));
                //     return DateFormat.Md().format(dt);
                //   }
                //   return '';
                // },
                // getTextStyles: (context, value) {
                //   return TextStyle(
                //       fontSize: globalDataStore.getResponsiveSize(11),
                //       fontFamily: 'SFProText',
                //       fontStyle: FontStyle.normal,
                //       fontWeight: FontWeight.w400,
                //       colors:[ Color.fromRGBO(0, 0, 0, 0.5),
                //       letterSpacing: -0.1);
                // },
                // margin: 0,
                interval: 1),),
        scatterTouchData: ScatterTouchData(
          enabled: false,
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  return chart;
}
