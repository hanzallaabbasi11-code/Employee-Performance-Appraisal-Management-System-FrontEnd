class SubKpi {
  final String name;
  final int score;
  final int total;

  SubKpi({required this.name, required this.score, required this.total});

  factory SubKpi.fromJson(Map<String, dynamic> json) {
    return SubKpi(
      name: json['Name'],
      score: json['Score'],
      total: json['Total'],
    );
  }
}

class Kpi {
  final String name;
  final int score;
  final int total;
  final List<SubKpi> subKpis;

  Kpi({required this.name, required this.score, required this.total, required this.subKpis});

  factory Kpi.fromJson(Map<String, dynamic> json) {
    var subKpisJson = json['SubKpis'] as List;
    List<SubKpi> subKpisList = subKpisJson.map((e) => SubKpi.fromJson(e)).toList();

    return Kpi(
      name: json['Name'],
      score: json['Score'],
      total: json['Total'],
      subKpis: subKpisList,
    );
  }
}

class Performance {
  final List<Kpi> kpis;
  final int overallPercentage;
  final int obtainedPoints;
  final int totalPoints;

  Performance({
    required this.kpis,
    required this.overallPercentage,
    required this.obtainedPoints,
    required this.totalPoints,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    var kpisJson = json['Kpis'] as List;
    List<Kpi> kpiList = kpisJson.map((e) => Kpi.fromJson(e)).toList();

    return Performance(
      kpis: kpiList,
      overallPercentage: json['OverallPercentage'],
      obtainedPoints: json['ObtainedPoints'],
      totalPoints: json['TotalPoints'],
    );
  }
}