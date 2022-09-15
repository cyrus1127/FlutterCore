class DailyRecord {
  DailyRecord(
      {this.id = '',
      this.datetime = '',
      this.datetimeEnd = '',
      this.datetimeDuration = 0,
      this.activityType = -1,
      this.activityKey = '',
      this.activity = '',
      this.quanity = '',
      this.amount = 0,
      this.amountMark = '',
      this.notes = '',
      this.userID = ''});
  final String id;
  late String datetime;
  late String datetimeEnd;
  late int datetimeDuration;
  final int activityType;
  final String activityKey;
  final String activity;
  late String quanity;
  late int amount;
  final String amountMark;
  late String notes;
  final String userID;

  DailyRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        datetime = json['datetime'],
        datetimeEnd = json['datetimeEnd'],
        datetimeDuration = json['datetimeDuration'],
        activityType = json['activityType'],
        activityKey = json['activityKey'],
        activity = json['activity'],
        quanity = json['quanity'],
        amount = json['amount'],
        amountMark = json['amountMark'],
        notes = json['notes'],
        userID = json['userID'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'datetime': datetime,
        'datetimeEnd': datetimeEnd,
        'datetimeDuration': datetimeDuration,
        'activityType': activityType,
        'activityKey': activityKey,
        'activity': activity,
        'quanity': quanity,
        'amount': amount,
        'amountMark': amountMark,
        'notes': notes,
        'userID': userID
      };

  String getImagePath({bool isEdit = false}) {
    if (activityType == 0) {
      return 'assets/images/' +
          activityKey +
          '_' +
          quanity.toLowerCase() +
          (isEdit ? '_edit' : '') +
          '.png';
    } else if (activityType == 1) {
      return 'assets/images/' + activityKey + (isEdit ? '_edit' : '') + '.png';
    }
    return 'assets/images/' + activityKey + '.png';
  }

  static Map<String, Map<String, String>> typesMap = {
    'nurse feed': {
      'name': 'Nursed Feed',
      'amount': 'Amount (Optional)',
      'unit': 'ml',
      'quantity': 'Left/Right/Both',
      'time': 'mins'
    },
    'pumping': {
      'name': 'Pumping',
      'amount': 'Amount',
      'unit': 'ml',
      'quantity': 'Left/Right/Both',
      'time': 'mins'
    },
    'feed': {
      'name': 'Pumping / Formula Feed',
      'amount': 'Amount',
      'unit': 'ml',
      'quantity': 'Pumping/Formula',
      'time': ''
    },
    'solids': {
      'name': 'Solids Food',
      'amount': 'Amount',
      'unit': 'ml',
      'quantity': '',
      'time': ''
    },
    'sleep': {
      'name': 'Sleep',
      'amount': '',
      'unit': '', //'hh:mm',
      'quantity': '',
      'time': ''
    },
    'wake': {
      'name': 'Wake',
      'amount': '',
      'unit': '', //'hh:mm',
      'quantity': '',
      'time': 'mins'
    },
    'pee': {
      'name': 'Pee',
      'amount': '',
      'unit': 'ml',
      'quantity': 'Less/Normal/Many',
      'time': ''
    },
    'poop': {
      'name': 'Poop',
      'amount': '',
      'unit': 'ml',
      'quantity': 'Less/Normal/Many',
      'time': ''
    },
    'pee poop': {
      'name': 'Both pee & poop',
      'amount': '',
      'unit': 'ml',
      'quantity': 'Less/Normal/Many',
      'time': ''
    },
    'bath': {
      'name': 'Bath',
      'amount': '',
      'unit': '',
      'quantity': '',
      'time': ''
    },
    'temperature': {
      'name': 'Temperature',
      'amount': 'Temperature',
      'unit': '°C',
      'quantity': '',
      'time': ''
    },
    'height': {
      'name': 'Height',
      'amount': 'Height',
      'unit': 'cm',
      'quantity': '',
      'time': ''
    },
    'weight': {
      'name': 'Weight',
      'amount': 'Weight',
      'unit': 'kg',
      'quantity': '',
      'time': ''
    },
  };

  static Map<String, String>? getTypeBy(String name) {
    return typesMap[name];
  }

  static Map<String, String>? getType(int index) {
    return typesMap[typesMap.keys.elementAt(index)];
  }

  static String getTypeName(int index) {
    return getType(index)!['name'] ?? '';
  }

  static String getTypeUnit(int index) {
    return getType(index)!['unit'] ?? '';
  }
}

class ChildChartGuid {
  const ChildChartGuid(
      this.monthIDX, this.year, this.month, this.height, this.weight);

  final int monthIDX;
  final int year;
  final int month;
  final MeasureDataSet height;
  final MeasureDataSet weight;
}

class MeasureDataSet {
  const MeasureDataSet(this.L, this.M, this.S, this.SD, this.SDn3, this.SDn2,
      this.SDn1, this.median, this.SDp3, this.SDp2, this.SDp1);

  final double L;
  final double M;
  final double S;
  final double SD; //height only

  final double SDn3;
  final double SDn2;
  final double SDn1;
  final double median;
  final double SDp3;
  final double SDp2;
  final double SDp1;
}
