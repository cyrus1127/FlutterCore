import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// final AudioPlayer audioPlayer = AudioPlayer();
// final AudioPlayer effectPlayer = AudioPlayer();
final AppTimeGlobalDataStore globalDataStore = AppTimeGlobalDataStore();

class ResponsiveStatefulWidget extends StatefulWidget {
  final String target;

  const ResponsiveStatefulWidget({required Key? key, this.target = ''})
      : super(key: key);

  ResponsiveStatefulWidget.clean({this.target = ''});

  TextStyle getCustomFontStyle(String code) {
    return TextStyle(
      fontFamily: 'dummy',
      fontSize: 20,
      color: HexColor(code),
    );
  }

  double getSingleRatio(double targetWidth, double origialWidth) {
    return targetWidth / origialWidth;
  }

  double getResponsiveTopPositioning(double pos) {
    // if (globalDataStore.curRatio_h == 1) return pos;
    return (globalDataStore.curRatio_h > 1 ? 1 : globalDataStore.curRatio_h) *
        pos;
  }

  double getResponsivePositioning(double pos) {
    // if (globalDataStore.BestRatio() == 1) return pos;
    // return pos - (globalDataStore.BestRatio() * pos);
    return (globalDataStore.BestRatio() * pos);
  }

  double getResponsiveSize(double lenght) {
    return globalDataStore.BestRatio() * lenght;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

// class _ResponsiveStatefulWidgetState extends State<ResponsiveStatefulWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Material();
//   }
// }

///Globel cache
class AppTimeGlobalDataStore {
  final ChangeNotifier changeNotifier = ChangeNotifier();
  bool isNewDemoAccount = false;
  String accountName = "";

/* =-=-=-=-=-=-=-=-=-= Scaling Ratio =-=-=-=-=-=-=-=-=-=-= */

  double curRatio_w = -1;
  double curRatio_h = -1;
  double BestRatio() {
    if (curRatio_w < 0 || curRatio_h < 0) {
      return 1;
    }
    return min(curRatio_w, curRatio_h); //base on iPhone 8p
  }

  void UpdateRatio(BuildContext context) {
    curRatio_w = MediaQuery.of(context).size.width / 414;
    curRatio_h = MediaQuery.of(context).size.height / 762;
  }

  double getResponsiveTopPositioning(double pos) {
    // if (globalDataStore.curRatio_h == 1) return pos;
    return (globalDataStore.curRatio_h > 1 ? 1 : globalDataStore.curRatio_h) *
        pos;
  }

  double getResponsivePositioning(double pos) {
    // if (globalDataStore.BestRatio() == 1) return pos;
    // return pos - (globalDataStore.BestRatio() * pos);
    return (globalDataStore.BestRatio() * pos);
  }

  double getResponsiveSize(double lenght) {
    return globalDataStore.BestRatio() * lenght;
  }

/* =-=-=-=-=-=-=-=-=-= Common functions =-=-=-=-=-=-=-=-=-=-= */

  String getTimeDiff(String dateStr) {
    if (dateStr.length > 0) {
      DateTime getDate = DateTime.parse(dateStr);

      Duration diff = DateTime.now().difference(getDate);
      if (diff.inSeconds > 0) {
        if (diff.inDays > 0) {
          int d = diff.inDays;
          return '$d days';
        } else if (diff.inHours > 0) {
          int h = diff.inHours;
          return '$h hs';
        } else if (diff.inMinutes > 0) {
          int m = diff.inMinutes;
          return '$m ms';
        } else {
          int s = diff.inSeconds;
          return '$s s';
        }
      }
    }
    return '0s';
  }

  String getCustomFormatDateTime(DateTime inDate) {
    Duration diff = inDate.difference(DateTime.now());
    String isTodayStr =
        (diff.inDays == 0 && DateTime.now().day == inDate.day ? "Today " : "");
    String easyFormat = DateFormat.yMMMEd().format(inDate);
    List<String> split = easyFormat.split(",");

    return isTodayStr + split.first + ',' + split[1] + split[2];
  }

  double objToDouble(dynamic inData) {
    return double.parse(inData.toString());
  }

  /*
  =-=-=-=-=

   */

  List<dynamic> collectionData = []; //preload data store for collection view
  // List<String> catNips = []; //local datas

/* =-=-=-=-=-=-=-=-=-= PlayerPref =-=-=-=-=-=-=-=-=-=-= */
  Future<bool> AddCatNip(String type) async {
    String key = 'CATNIPS';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> catNips = prefs.getStringList(key) ?? [];
    catNips.add(type);
    return prefs.setStringList(key, catNips);
  }

  Future<List<String>> GetCatNips() async {
    String key = 'CATNIPS';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<bool> DeductCatNips(List<String> nips) async {
    String key = 'CATNIPS';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> catNips = prefs.getStringList(key) ?? [];
    if (catNips.length >= nips.length) {
      for (var nip in nips) {
        catNips.remove(nip);
      }
      return prefs.setStringList(key, catNips);
    }
    return Future<bool>.value(false);
  }

  Future<bool> FillPower(int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _currectPower = prefs.getInt("POWER")!;
    if (_currectPower < 5) {
      return prefs.setInt(
          "POWER", (_currectPower + amount > 5 ? 5 : _currectPower + amount));
    }

    return Future<bool>.value(false);
  }

  /* =-=-=-=-=-=-=-=-=-= Data request =-=-=-=-=-=-=-=-=-=-= */

/* Type id : 1 = catNip , 2 = collection , 3 = puzzle */
  // ignore: non_constant_identifier_names
  Future<dynamic> GetCurrentItemsByType(int itemType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String randomID = prefs.getString('randomid') ?? "";

    final http.Response response = await http.get(
      Uri.parse('https://api.donutahmeow.com/player/package?randomid=' +
          randomID +
          '&itemType=' +
          itemType.toString()),
      headers: <String, String>{},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder();
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      print(result.toString());

      return Future<dynamic>.value(result);
    } else {
      // If the server did not return a 201 CREATED response,then throw an exception.
      print(" request(" +
          response.request!.url.toString() +
          ")  failed => reason " +
          jsonDecode(response.body));
      return Future<dynamic>.value(null);
    }
  }

// ignore: non_constant_identifier_names
  Future<bool> UseCatNip(int itemID, int amount) async {
    return UseItemsByType(1, itemID, amount);
  }

// ignore: non_constant_identifier_names
  Future<bool> UseItemsByType(int itemType, int itemID, int amount) async {
    String dataBody = "{\"itemid\":" +
        itemID.toString() +
        ",\"itemType\":" +
        itemType.toString() +
        "} }";
    final http.Response response = await ActionRequest('USE_ITEM', dataBody);

    print(response.statusCode);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder();
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      print(result.toString());

      return Future<bool>.value(true);
    } else {
      // If the server did not return a 201 CREATED response,then throw an exception.
      print(" request(" +
          response.request!.url.toString() +
          ")  failed => reason " +
          response.body);
      return Future<bool>.value(false);
    }
  }

// ignore: non_constant_identifier_names
  Future<http.Response> ActionRequest(
      String actionTypeName, String dataBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String randomID = prefs.getString('randomid') ?? "";

    String _itemData = "{\"randomid\":\"" +
        randomID +
        "\", \"type\":\"" +
        actionTypeName +
        "\",\"data\":" +
        dataBody +
        "}";
    final http.Response response = await http.post(
        Uri.parse('https://api.donutahmeow.com/player/action'),
        headers: <String, String>{},
        body: _itemData);

    return response;
  }

  /*
  =-=-=-=-=

   */

  AppTimeGlobalDataStore();
}
