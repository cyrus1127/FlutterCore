import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/dataObjects/dailyRecord.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:intl/intl.dart';

/// TODO : use BarChartRodStackItem
Widget childWHLineChart(List<ChildChartGuid> chartGuids,
    List<DailyRecord> coreData, int onSelectedChartIndex,
    {double maxY = 120, String unit = 'cm'}) {
  maxY = onSelectedChartIndex == 7 ? 120 : 48;
  double maxX_pad = 2;
  double maxXV_pad = 0.5; //shift the position
  double maxX = 7 + maxX_pad; //chart lenght
  LineChart chart;
  List<LineChartBarData> chartDatas = [];

  // if (coreData.length == 0) {
  //   return Container();
  // }

  //add the basic range
  {
    List<FlSpot> SpotRods_bl = [];
    List<FlSpot> SpotRods_bh = [];
    List<FlSpot> SpotRods_bc = []; //base compare line
    List<FlSpot> SpotRods_da = [];
    {
      // if (index >= 1)
      for (int index = 1; index < maxX; index++) {
        //handle baserange
        if (index <= chartGuids.length) {
          ChildChartGuid obj = chartGuids[index];

          MeasureDataSet mds =
              onSelectedChartIndex == 7 ? obj.height : obj.weight;

          if (index <= maxX - maxX_pad) {
            SpotRods_bc.add(FlSpot(index.toDouble() + maxXV_pad, mds.median));
          }
          SpotRods_bl.add(FlSpot(index.toDouble(), mds.SDp3)); // base low
          SpotRods_bh.add(FlSpot(index.toDouble(), mds.SDn3)); // base height
        }
      }

      //handle user record
      coreData.forEach((element) {
        //x = date
        double x = coreData.indexOf(element).toDouble() + 1 + maxXV_pad;
        double y = element.amount.toDouble();
        if (x >= 0 && y > 0) SpotRods_da.add(FlSpot(x, y));
      });

//add all datas -- base low & height
      chartDatas.add(LineChartBarData(
        spots: SpotRods_bl, isCurved: true,
        // barWidth: 2,
        colors: [Colors.transparent],
        dotData: FlDotData(
          show: false,
        ),
      ));
      chartDatas.add(LineChartBarData(
        spots: SpotRods_bh, isCurved: true,
        // barWidth: 2,
        colors: [Colors.transparent],
        dotData: FlDotData(
          show: false,
        ),
      ));

      chartDatas.add(LineChartBarData(
        spots: SpotRods_bc,
        barWidth: 5,
        colors: [Color.fromRGBO(0, 119, 192, 1)],
        dotData: FlDotData(
          show: true,
        ),
      ));

      //add all datas -- base anayls
      if (SpotRods_da.length > 2) {
        chartDatas.add(LineChartBarData(
          spots: SpotRods_da, isCurved: true,
          // barWidth: 2,
          colors: [Color.fromRGBO(229, 96, 32, 1)],
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
        bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              if (value > 0 && value % 1 != 0) {
                int dt = (value).toInt();
                return dt.toString();
              }
              return '';
            },
            getTextStyles: (context, value) {
              return TextStyle(
                  fontSize: globalDataStore.getResponsiveSize(11),
                  fontFamily: 'SFProText',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  letterSpacing: -0.1);
            },
            interval: 0.5),
        leftTitles: SideTitles(
          showTitles: true,
          interval: (maxY / 50 >= 1 ? 10 : (maxY / 10 >= 1 ? 3 : 1.5)),
          getTextStyles: (context, value) {
            return TextStyle(
                fontSize: globalDataStore.getResponsiveSize(11),
                fontFamily: 'SFProText',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                letterSpacing: -0.1);
          },
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
          colors: [Color.fromRGBO(241, 163, 135, 0.1)],
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
          DateTime d_exact = DateTime.parse(exactDate);
          DateTime d = DateTime.parse(element.datetime);
          double x = d_exact.difference(start).inDays.toDouble();
          //y = time
          double y = element.amount.toDouble();
          if (x == index) {
            barRods.add(BarChartRodData(
                y: y,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                colors: [
                  x % 2 == 0
                      ? Color.fromRGBO(229, 96, 32, 1)
                      : Color.fromRGBO(249, 173, 27, 1)
                ]));
          }
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
            getTitles: (value) {
              DateTime dt = start.add(Duration(days: value.toInt()));
              return DateFormat.Md().format(dt);
            },
            getTextStyles: (context, value) {
              return TextStyle(
                  fontSize: globalDataStore.getResponsiveSize(11),
                  fontFamily: 'SFProText',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  letterSpacing: -0.1);
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: maxY >= 100 ? 50 : 3,
            getTextStyles: (context, value) {
              return TextStyle(
                  fontSize: globalDataStore.getResponsiveSize(11),
                  fontFamily: 'SFProText',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  letterSpacing: -0.1);
            },
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
              // getTitles: (value) {
              //   if (value >= 1 && value <= 24) {
              //     return value.toInt().toString();
              //   }
              //   return '';
              // },
              getTextStyles: (context, value) {
                return TextStyle(
                    fontSize: globalDataStore.getResponsiveSize(11),
                    fontFamily: 'SFProText',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    letterSpacing: -0.1);
              },
            ),
            rightTitles: SideTitles(),
            topTitles: SideTitles(),
            bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (value) {
                  if (value >= 1 && value <= 7) {
                    DateTime dt = start.add(Duration(days: value.toInt() - 1));
                    return DateFormat.Md().format(dt);
                  }
                  return '';
                },
                getTextStyles: (context, value) {
                  return TextStyle(
                      fontSize: globalDataStore.getResponsiveSize(11),
                      fontFamily: 'SFProText',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      letterSpacing: -0.1);
                },
                margin: 0,
                interval: 1)),
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
