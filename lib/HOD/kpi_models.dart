import 'dart:convert';

class AddKpiDto {
  final String kpiName;
  final int sessionId;
  final int employeeTypeId;
  final int requestedKpiWeight;
  final List<SubKpiDto> subKPIs;

  AddKpiDto({
    required this.kpiName,
    required this.sessionId,
    required this.employeeTypeId,
    required this.requestedKpiWeight,
    required this.subKPIs,
  });

  Map<String, dynamic> toJson() => {
    "KPIName": kpiName,
    "SessionId": sessionId,
    "EmployeeTypeId": employeeTypeId,
    "RequestedKPIWeight": requestedKpiWeight,
    "SubKPIs": subKPIs.map((x) => x.toJson()).toList(),
  };
}

class SubKpiDto {
  String name;
  int weight;

  SubKpiDto({required this.name, required this.weight});

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Weight": weight,
  };
}