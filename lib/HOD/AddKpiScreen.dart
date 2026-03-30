import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:epams/Url.dart';

class AddKpiScreen extends StatefulWidget {
  const AddKpiScreen({super.key});

  @override
  State<AddKpiScreen> createState() => _AddKpiScreenState();
}

class _AddKpiScreenState extends State<AddKpiScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kpiNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _draftSubName = TextEditingController();
  final TextEditingController _draftSubWeight = TextEditingController();

  int? selectedSession;
  int? selectedEmpType;

  List sessions = [];
  List empTypes = [];
  List subKpis = [];
  List overview = [];

  bool loading = false;
  int? openKpiId;

  final String baseUrl = "$Url/kpi";

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  /// LOAD SESSIONS + EMP TYPES
  Future<void> loadInitialData() async {

    final s = await http.get(Uri.parse("$baseUrl/sessions"));
    final e = await http.get(Uri.parse("$baseUrl/emptypes"));

    setState(() {
      sessions = jsonDecode(s.body);
      empTypes = jsonDecode(e.body);
    });
  }

  /// LOAD KPI OVERVIEW
  Future<void> loadOverview() async {

    if (selectedSession == null || selectedEmpType == null) return;

    setState(() => loading = true);

    final res = await http.get(
        Uri.parse("$baseUrl/view-weights/$selectedSession/$selectedEmpType"));

    if (res.statusCode == 200) {
      setState(() {
        overview = jsonDecode(res.body);
      });
    }

    setState(() => loading = false);
  }

  /// ADD DRAFT SUB KPI
  void addSubDraft() {

    if (_draftSubName.text.isEmpty || _draftSubWeight.text.isEmpty) {
      show("Enter Sub KPI name and weight");
      return;
    }

    setState(() {

      subKpis.add({
        "Name": _draftSubName.text,
        "Weight": int.parse(_draftSubWeight.text)
      });

      _draftSubName.clear();
      _draftSubWeight.clear();
    });
  }

  void removeSubDraft(int i) {
    setState(() => subKpis.removeAt(i));
  }

  /// CREATE KPI
  Future<void> createKpi() async {

    if (!_formKey.currentState!.validate()) return;

    final body = {
      "KPIName": _kpiNameController.text,
      "EmployeeTypeId": selectedEmpType,
      "SessionId": selectedSession,
      "RequestedKPIWeight": int.parse(_weightController.text),
      "SubKPIs": subKpis
    };

    final res = await http.post(
      Uri.parse("$baseUrl/create-with-weight"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {

      show("KPI Created");

      setState(() {
        subKpis.clear();
        _kpiNameController.clear();
        _weightController.clear();
      });

      loadOverview();
    }
  }

  /// ADD SUB KPI TO EXISTING KPI
  Future<void> addSubKpiDynamic(int kpiId) async {

    TextEditingController name = TextEditingController();
    TextEditingController weight = TextEditingController();

    showDialog(
        context: context,
        builder: (_) {

          return AlertDialog(

            title: const Text("Add Sub KPI"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(controller: name, decoration: const InputDecoration(hintText: "Name")),

                TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Weight"))

              ],
            ),

            actions: [

              TextButton(

                onPressed: () async {

                  final body = {
                    "KpiId": kpiId,
                    "SessionId": selectedSession,
                    "Name": name.text,
                    "NewWeight": int.parse(weight.text)
                  };

                  await http.post(
                      Uri.parse("$baseUrl/add-subkpi-dynamic"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(body));

                  Navigator.pop(context);

                  loadOverview();
                },

                child: const Text("Add"),
              )
            ],
          );
        });
  }

  /// DELETE SUB KPI
  Future<void> deleteSubKpi(int subId) async {

    await http.delete(
        Uri.parse("$baseUrl/delete-subkpi/$selectedSession/$subId"));

    loadOverview();
  }

  /// DELETE MAIN KPI
  Future<void> deleteMainKpi(int kpiId) async {

    await http.delete(
        Uri.parse("$baseUrl/delete-main-kpi/$selectedSession/$kpiId"));

    loadOverview();
  }

  /// EDIT KPI NAME
  Future<void> editKpi(int id, String name) async {

    await http.put(
        Uri.parse("$baseUrl/edit-kpi-name/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(name));

    loadOverview();
  }

  /// EDIT SUB KPI NAME
  Future<void> editSub(int id, String name) async {

    await http.put(
        Uri.parse("$baseUrl/edit-subkpi-name/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(name));

    loadOverview();
  }

  void show(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("KPI Configuration")),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              buildCreateCard(),

              const SizedBox(height: 20),

              const Text("Live KPI Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              loading
                  ? const CircularProgressIndicator()
                  : buildOverview()

            ],
          ),
        ),
      ),
    );
  }

  /// CREATE CARD
  Widget buildCreateCard() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            dropdown(sessions, selectedSession, "Session", (v) {
              setState(() => selectedSession = v);
              loadOverview();
            }, true),

            dropdown(empTypes, selectedEmpType, "Employee Type", (v) {
              setState(() => selectedEmpType = v);
              loadOverview();
            }, false),

            input(_kpiNameController, "KPI Name"),
            input(_weightController, "Weight", number: true),

            const Divider(),

            Row(
              children: [
                Expanded(child: input(_draftSubName, "Sub KPI", required: false)),
                const SizedBox(width: 10),
                Expanded(child: input(_draftSubWeight, "Weight", number: true, required: false))
              ],
            ),

            ElevatedButton(
                onPressed: addSubDraft,
                child: const Text("Add Sub KPI")),

            ...subKpis.asMap().entries.map((e) {

              int i = e.key;
              var s = e.value;

              return ListTile(
                title: Text(s['Name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${s['Weight']}%"),
                    IconButton(
                        onPressed: () => removeSubDraft(i),
                        icon: const Icon(Icons.delete,color: Colors.red))
                  ],
                ),
              );
            }),

            ElevatedButton(
                onPressed: createKpi,
                child: const Text("Save KPI"))

          ],
        ),
      ),
    );
  }

  /// KPI OVERVIEW
  Widget buildOverview() {

    return ListView.builder(

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: overview.length,

      itemBuilder: (_, i) {

        var k = overview[i];
        bool open = openKpiId == k['kpiId'];

        return Card(

          child: Column(

            children: [

              ListTile(

                title: Text(k['kpiName']),
                subtitle: Text("${k['totalKpiWeight']}%"),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => addSubKpiDynamic(k['kpiId'])),

                    IconButton(
                        icon: const Icon(Icons.delete,color: Colors.red),
                        onPressed: () => deleteMainKpi(k['kpiId'])),

                    Icon(open ? Icons.expand_less : Icons.expand_more)

                  ],
                ),

                onTap: () {
                  setState(() {
                    openKpiId = open ? null : k['kpiId'];
                  });
                },
              ),

              if (open)

                Column(

                  children: [

                    ...k['subKpis'].map<Widget>((s) => ListTile(
                      title: Text(s['subKpiName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${s['weight']}%"),
                          IconButton(
                              icon: const Icon(Icons.delete,color: Colors.red),
                              onPressed: () => deleteSubKpi(s['subKpiId']))
                        ],
                      ),
                    ))
                  ],
                )
            ],
          ),
        );
      },
    );
  }

  Widget dropdown(List list, int? value, String hint, Function(int?) onChange, bool session) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: DropdownButtonFormField<int>(

        value: value,
        hint: Text(hint),

        items: list.map((e) {

          return DropdownMenuItem<int>(
            value: e['id'],
            child: Text(session ? e['name'] : e['type']),
          );

        }).toList(),

        onChanged: onChange,

        validator: (v) => v == null ? "Required" : null,

        decoration: const InputDecoration(border: OutlineInputBorder()),

      ),
    );
  }

  Widget input(TextEditingController c, String h,
      {bool number=false, bool required=true}) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: TextFormField(

        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,

        validator: required
            ? (v) => v == null || v.isEmpty ? "Required" : null
            : null,

        decoration: InputDecoration(
            hintText: h,
            border: const OutlineInputBorder()),

      ),
    );
  }
}