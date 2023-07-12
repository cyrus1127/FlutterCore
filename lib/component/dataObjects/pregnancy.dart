class PregnancyGuid {
  PregnancyGuid(
      this.week,
      this.nameState,
      this.nameState_tc,
      this.lenght,
      this.lenght_unit,
      this.lenght_unit_tc,
      this.weight,
      this.weight_unit,
      this.weight_unit_tc,
      {this.questions_hl,
      this.questions_dv})
      : super();

  final int week;
  final String nameState;
  final String nameState_tc;
  final String lenght;
  final String lenght_unit;
  final String lenght_unit_tc;
  final String weight;
  final String weight_unit;
  final String weight_unit_tc;
  late List<Map<String, String>>? questions_hl; //highlight
  late List<Map<String, String>>? questions_dv; //develop

  int nubmerOfQuests({bool typeHighLight = true}) {
    return typeHighLight ? questions_hl!.length : questions_dv!.length;
  }

  List<String>? questAwnser(int index,
      {bool typeHighLight = true, bool isTC = false}) {
    List<Map<String, String>>? qlist =
        typeHighLight ? questions_hl : questions_dv;

    if (qlist != null) {
      if (index >= 0 && index < qlist.length) {
        List<String> nR = [];
        String qKey = 'q' + (isTC ? '_tc' : '');
        String aKey = 'a' + (isTC ? '_tc' : '');
        Map<String, String> ele = qlist[index];
        nR.add(ele[qKey] ?? '');
        nR.add(ele[aKey] ?? '');
        return nR;
      }
    }

    return null;
  }

  void addQuestWithAwnser(
      String nType, String nQ, String nA, String nQTC, String nATC) {
    if (questions_hl == null) questions_hl = [];
    if (questions_dv == null) questions_dv = [];
    bool isHighlight = nType.compareTo('Highlights') == 0;

    if (isHighlight) {
      questions_hl!.add({"q": nQ, "a": nA, "q_tc": nQTC, "a_tc": nATC});
    } else {
      questions_dv!.add({"q": nQ, "a": nA, "q_tc": nQTC, "a_tc": nATC});
    }

    // print('add nType?' + nType + '  Q' + questions!.length.toString());
  }
}

class PregnancyChartGuid {
  const PregnancyChartGuid(
      {this.week = 0,
      this.crl = 0,
      this.brd = 0,
      this.brd_range = 0,
      this.hc = 0,
      this.hc_range = 0,
      this.fl = 0,
      this.fl_range = 0,
      this.ac = 0,
      this.ac_range = 0});

  final double week;
  final double crl;
  final double brd;
  final double brd_range;
  final double hc;
  final double hc_range;
  final double fl;
  final double fl_range;
  final double ac;
  final double ac_range;

  double getUpLowBPD(bool getUp) {
    return brd + (getUp ? brd_range : -brd_range);
  }

  double getUpLowHC(bool getUp) {
    return hc + (getUp ? hc_range : -hc_range);
  }

  double getUpLowFL(bool getUp) {
    return fl + (getUp ? fl_range : -fl_range);
  }

  double getUpLowAC(bool getUp) {
    return ac + (getUp ? ac_range : -ac_range);
  }
}
